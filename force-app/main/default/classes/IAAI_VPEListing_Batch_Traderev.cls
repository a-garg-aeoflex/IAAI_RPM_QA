global class IAAI_VPEListing_Batch_Traderev implements Database.Batchable<object>, Database.AllowsCallouts, Database.Stateful {
    public Map<Integer, String> tradeStateMapping = new Map<Integer, String>();
    VPE_Listing_Partner__c partnerDetail;
    private static VPE_Listings__c instance;
    public static final String TRADEREV_BID_OFFER = 'TRADEREV_BID_OFFER';
    public static final String PARTNER_NAME = 'TRADEREV';
    public static final String PARTNER_AUTHENTICATION = 'TRADEREV_AUTHENTICATION';
    public String apiCall = 'ACTIVE';
    public static final String ACTIVE = 'Active';
    public List<VPE_Listings__c> listingRecordsForAutomateBid = new List<VPE_Listings__c>();
    global IAAI_VPEListing_Batch_Traderev() {
        tradeStateMapping.put(1, 'active');
        tradeStateMapping.put(10, 'upcoming');
        tradeStateMapping.put(11, 'buy now');
        partnerDetail = [SELECT Id, Name, Bid_filtering_Value__c, Last_Batch_Ran_At__c, Call_Start_Time__c, Call_End_Time__c FROM VPE_Listing_Partner__c WHERE Name =: PARTNER_NAME];
        system.debug('partnerDetail '+partnerDetail);
    }
    global List<object> start(Database.BatchableContext bc)
    {
        List<object> finalData = new List<object>();
        List<tradeRevResponse> responseList = new List<tradeRevResponse>();
        
        system.debug('responseList '+responseList);
        if( partnerDetail != null ) {
            List<IAAI_VPE_Listing_Partner__mdt> partnerList = [Select DeveloperName,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =:PARTNER_NAME]; 
            IAAI_VPE_Listing_Partner__mdt tradeAuth = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: PARTNER_AUTHENTICATION LIMIT 1];
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tradeAuth.Endpoint__c);
            req.setMethod('POST');
            req.setBody('grant_type=client_credentials&client_id='+tradeAuth.UserName__c+'&client_secret='+tradeAuth.Authtoken__c);
            HttpResponse refreshToken = http.send(req);
            if ( partnerList.size() > 0 && partnerList != null ) {
                HttpRequest request = new HttpRequest();
                for (IAAI_VPE_Listing_Partner__mdt partner : partnerList) {
                    if ( partner.DeveloperName == PARTNER_NAME ) {
                        if( partnerDetail.Last_Batch_Ran_At__c != null ) {
                            if( partnerDetail.Last_Batch_Ran_At__c.Date().daysBetween(System.today()) > 0 ) {
                         		apiCall = 'UPCOMING';       
                                request.setEndpoint(partner.Endpoint__c+'/upcoming');   
                            } else {
                                request.setEndpoint(partner.Endpoint__c+'/active');
                            }
                        } else {
                            apiCall = 'UPCOMING';
                            request.setEndpoint(partner.Endpoint__c+'/upcoming');
                        }
                        request.setMethod('POST');
                        request.setHeader('authenticationToken',partner.Authtoken__c);
                        request.setHeader('Content-Type', 'application/json');
                        request.setHeader('Accept', 'application/json');
                        request.setBody('{"filter":{}}');
                    }
                    system.debug('request '+request.getBody());
                }
                HttpResponse response = http.send(request);
                responseList = parse(response.getBody()); 
                system.debug('responseList '+ responseList);
            }
        }
        return responseList;
    }
    global void execute(Database.BatchableContext bc,List<object> scope)
    {
        claim_values__mdt claimVal = [SELECT id, DeveloperName, value__c From claim_values__mdt Where DeveloperName =: PARTNER_NAME limit 1];
        System.debug('size--'+scope.size()+' APICall-->'+apiCall);
        Set<String> tradeIds = new Set<String>();
        List<tradeRevResponse> trrList = (List<tradeRevResponse>) scope;
        List<VPE_Listings__c> listName = new List<VPE_Listings__c>();
        VPE_Listings__c vpl = new VPE_Listings__c(); 
        if ( scope.size() > 0 && partnerDetail != null ) {
            for (tradeRevResponse trr : trrList) {
				Integer tempTopBid = (trr.topBidAmount != null) ? trr.topBidAmount : 0;
                Integer tempResponseMinStartBid = (trr.minStartingBid != null) ? trr.minStartingBid : 0;
                Integer tempMinStartingBid = (tempTopBid > tempResponseMinStartBid) ? tempTopBid : tempResponseMinStartBid;
                if( tempMinStartingBid < partnerDetail.Bid_Filtering_Value__c && trr.vehicleHistoryReport != null) {
                    tradeIds.add(trr.tradeId);
                    system.debug('trr.tradeId '+trr.tradeId);
                    // vpl.Provider_Name__c = trr.sellerName;	// Removed because of field Deprecated
                    vpl.Starting_Bid__c = trr.minStartingBid;
                    vpl.claim__c = claimVal.DeveloperName;
                    vpl.Top_Bid__C = trr.topBidAmount;
                    if( trr.sellerName != null ) {
                        List<String> tempName = trr.sellerName.split(' ');
                        if( tempName.size() > 0 ) {
                            vpl.Provider_First_Name__c = tempName[0];
                            tempName.remove(0);
                            vpl.Provider_Last_Name__c = String.join(tempName, ' ');
                        } else {
                            vpl.Provider_First_Name__c = trr.sellerName;
                        }
                    }
                    vpl.Listing_Id__c = trr.tradeId;
                    vpl.VIN__c = trr.vin;
                    vpl.Make__c= trr.make.name;
                    vpl.Mileage__c = trr.mileage;
                    vpl.Model__c= trr.model.name;
                    vpl.Model_Year__c= trr.year;
                    vpl.Scheduled_Time_for_Auction__c = trr.activeExpiryTime;
                    vpl.Vehicle_Image__c = trr.thumbnailURL;
                    if( trr.pickupAddress != null ){
                        vpl.Pickup_Address__c = trr.pickupAddress;
                        vpl.Pickup_Street__c = trr.pickupAddress.split(',')[0];
                        vpl.Pickup_City__c = trr.pickupAddress.split(',')[1];
                        vpl.Pickup_State__c = trr.pickupAddress.split(',')[2];
                        vpl.Pickup_Zip__c = trr.pickupAddress.split(',')[3];
                        vpl.Pickup_Country__c = trr.pickupAddress.split(',')[4];
                    }
                    vpl.Status_of_Listing__c = tradeStateMapping.get(trr.tradeState.tradeStateId);
                    vpl.Auction_Id__c = trr.auctionId;
                    if(partnerDetail != null){
                        vpl.VPE_Listing_Partner__c = partnerDetail.Id;
                    }
                    listName.add(vpl.clone(false,false,false,false));
                    vpl.clear();
                }
            }
        } 
        if( apiCall == 'UPCOMING' ) {
            system.debug('listName '+listName[0].Model__c);
            Map<String, VPE_Listings__c> traderevRecords = new Map<String, VPE_Listings__c>();
            system.debug('tradeIds '+ tradeIds);
           
         	List<VPE_Listings__c> recordsInSystem = [SELECT Id, Model__c,Listing_Id__c, Starting_Bid__c, Status_Of_Listing__c, Original_Bid_Offer_Amount__c, Bid_Offer_Submitted__c  
                                                     FROM VPE_Listings__c 
                                                     WHERE (Bid_Offer_Submitted__c = true 
                                                            AND Auction_Id__c != null 
                                                            AND Listing_Id__c IN :tradeIds)];
            System.debug('recordsInSystem->'+recordsInSystem.size());
            if( recordsInSystem.size() > 0 ) {
                for( VPE_Listings__c v : recordsInSystem ) {
                    traderevRecords.put(v.Listing_Id__c, v);
                }
            }
            system.debug('traderevRecords '+traderevRecords);
            if( recordsInSystem != null ) {
                for( VPE_Listings__c v : listName ) {
                    system.debug('VPE_Listings__c '+v);
                    if( traderevRecords.containsKey(v.Listing_Id__c) ) {
                        VPE_Listings__c traderevRecord = traderevRecords.get(v.Listing_Id__c);
                        if( v.Starting_Bid__c == traderevRecord.Starting_Bid__c ) {
                            listingRecordsForAutomateBid.add(traderevRecord);
                        } else {
                            v.Bid_Offer_Submitted__c = false;
                            v.Original_Bid_Offer_Amount__c = 0;
                        }
                    }
                }
            }
        }
        System.debug('Automate Bid-->'+listingRecordsForAutomateBid);
        if( listName.size() > 0 ) {
            upsert listName Listing_Id__c;
        }
    }
    global void finish(Database.BatchableContext bc) {
    	partnerDetail.Last_Batch_Ran_At__c = System.now();
        String startingPartOfBodyToBeSend = '{"proxyBidList":[';
        String endingPartOfBodyToBeSend = ']}';
        String bidObject = '';
        String finalBidObject = '';
        if( listingRecordsForAutomateBid.size() > 0 ) {
            for( VPE_Listings__c v : listingRecordsForAutomateBid ) {
                if( v.Starting_Bid__c != null ) {
                 	bidObject += '{"tradeId":'+v.Listing_Id__c+',"startingBidAmount":'+v.Starting_Bid__c+',"proxyBidAmount":'+v.Original_Bid_Offer_Amount__c+'},';   
                } else {
                    bidObject += '{"tradeId":'+v.Listing_Id__c+',"startingBidAmount":0.00,"proxyBidAmount":'+v.Original_Bid_Offer_Amount__c+'},';
                }
            }
            finalBidObject = bidObject.removeEnd(',');
        }
        if( bidObject != '' ) {
         	String finalBodyToBeSend = startingPartOfBodyToBeSend+finalBidObject+endingPartOfBodyToBeSend;
            IAAI_VPE_Listing_Partner__mdt tradeAuth = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: TRADEREV_BID_OFFER LIMIT 1];
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(tradeAuth.Endpoint__c);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('authenticationToken', tradeAuth.Authtoken__c);
            httpRequest.setMethod('POST');
            httpRequest.setBody(finalBodyToBeSend);
            HttpResponse response = new HttpResponse();
            if( !Test.isRunningTest() ) {
                response = h.send(httpRequest);
            } else {
                response.setStatusCode(202);
            }
            String requestId;
            if( response.getStatusCode() == 202 ) {
                JSONParser parser = System.JSON.createParser(response.getBody());
                while( parser.nextToken() != null ) {
                    if( parser.getCurrentName() == 'requestId' && parser.getCurrentToken() == JSONToken.VALUE_STRING ) {
                        requestId = parser.getText();
                    }
                }
                if( requestId != '' ) {
                    partnerDetail.Request_Id__c = requestId;
                    Datetime cronTime = System.now().addMinutes(2);
                    String day = string.valueOf(cronTime.day());
                    String month = string.valueOf(cronTime.month());
                    String hour = string.valueOf(cronTime.hour());
                    String second = string.valueOf(cronTime.second());
                    String year = string.valueOf(cronTime.year());
                    String minute = string.valueOf(cronTime.minute());
                    String strSchedule = '0 ' + minute + ' ' + hour + ' ' +day+ ' ' + month + ' ? ' + year;            
                    FetchAutomateBidResult f = new FetchAutomateBidResult();
                    if( !Test.isRunningTest() ) {
                        System.schedule('Get_Result_of_Automated_Bids', strSchedule, f);
                        IAAI_Blackbook_Batch bb = new IAAI_Blackbook_Batch();
                        Database.executeBatch(bb, 10);
                    }
                }
            }
        }
        update partnerDetail;
        Database.executeBatch(new IAAI_Blackbook_Batch(), 10);
    }
    public static List<tradeRevResponse> parse(String json){
        return (List<tradeRevResponse>) System.JSON.deserialize(json, List<tradeRevResponse>.class);
    }
    public class tradeRevResponse {
        String tradeId; // Listing_Id__c
        String auctionId;   // 
        tradeState tradeState;
        make make;
        odometer odometer;
        model model;
        Datetime dateAutoLaunch;   
        Datetime activeExpiryTime; // Scheduled_time_For_Auction__c 
        String vin;     // VIN__c
        String year;    // year__c
        Decimal mileage;    // Mileage
        String sellerName;   // Pr0vider_name__C
        String pickupAddress ; // "75 Wall Street, New York, NY, 10005, US", // Provider Address, need to split in different fields 
        Integer minStartingBid;  // Starting_Bid__c
        String thumbnailURL;   // Vehicle_image__c
        String vehicleHistoryReport;
        Integer topBidAmount; // Top Bid__c
    }
    public class tradeState {
        Integer tradeStateId; // 1    -> active, 10   -> upcoming, 11   -> buy now
    }
    public class make {
        Integer makeId; 
        String name;
    }
    public class odometer {
        String odometerId;
    }
    public class model{
        String name;
    }
}