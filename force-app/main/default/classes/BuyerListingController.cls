public class BuyerListingController {
    private static final String PARTNER_NAME = 'TRADEREV';
    private static final String PARTNER_AUTHENTICATION = 'TRADEREV_AUTHENTICATION';
    private static final String TRADEREV_BID_RESULT = 'TRADEREV_BID_RESULT';
    public static final String TRADEREV_BID_OFFER = 'TRADEREV_BID_OFFER';
    public static final String CARVIO = 'CARVIO';
    public static final String TRADEREV = 'TRADEREV';
    public static Boolean notFromBidButton = false;
    
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = VPE_Listings__c.Status_of_Listing__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static VPE_Listings__c fetchValueAndUpdateRecord(String st){
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe = [Select id, Vin__c,Average_Sale_Price__c,Highest_Sale_Price__c,Lowest_Sale_Price__c,MarketPlaceUpdate__c,Notes__c,Model_Year__c,Make__c,Model__c,Has_Keys__c  from VPE_Listings__c where id = : st];
        IAAI_Market_Value_Search i = new IAAI_Market_Value_Search();
        IAAI_Market_Value_Search.wrapVPEValue w;
        if(!Test.isRunningTest()){
            w = i.basicAuthCallout(vpe);
            
            vpe.Average_Sale_Price__c = decimal.valueOf(w.Average_Sale_Price);
            vpe.Highest_Sale_Price__c = decimal.valueOf(w.Highest_Sale_Price);
            vpe.Lowest_Sale_Price__c = decimal.valueOf(w.lowest_Sale_Price);
            vpe.Most_Recent_Sale_Date__c =  w.MOST_RECENT_SALE_DATE;
            vpe.MarketPlaceUpdate__c  = true;
        }
        update vpe;
        return vpe;
    }
    
    
    @AuraEnabled 
    public static VPE_Listing_Partner__c[] getListingPartnertList() {
        return [SELECT id,Name,Rules__c FROM VPE_Listing_Partner__c];
    }
    
    
    
    public static boolean carvioManualBid(Id sfdcid, String listingId, Double amountValue, Double minStartingBid, String auctionId){
        VPE_Listings__c vpeRecord;
        Double zeroValue = 0.01;
        if(sfdcid != null){
            vpeRecord = [Select id,VPE_Listing_Partner__c,Status_of_Listing__c,VPE_Listing_Partner__r.name from VPE_Listings__c where id = :sfdcid];
        }
        if(vpeRecord.VPE_Listing_Partner__r.name == CARVIO){
            IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c,Authtoken__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'CARVIOBID'] ;         
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(imdt.Endpoint__c+ listingId);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Authorization', imdt.Authtoken__c);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(60000);
            httpRequest.setBody('{"offer_amount":'+zeroValue+', "IS_LCU_UPDATE" : false, "status" : "Manual Bid Required"}'); 
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                response = h.send(httpRequest);
            } else {
                response.setStatusCode(200);
            }
            System.debug('ResponseBody----->>>'+response.getBody());
            VPE_Listings__c vpe = new VPE_Listings__c(Id=sfdcid); 
            if(response.getStatusCode()== 200){
                vpe.Original_Bid_Offer_Amount__c = amountValue;
                vpe.Status_of_Listing__c = 'Manual Bid Required';
                update vpe; 
                return true;
            }else{
                if(response.getBody().contains('expired')) {
                    vpe.Original_Bid_Offer_Amount__c = amountValue;
                    vpe.Status_of_Listing__c = 'Expired';
                    update vpe;   
                }
                return false;
            }
        } 
        else{
            VPE_Listings__c vpe = new VPE_Listings__c(); 
            vpe.Id = sfdcid; 
            vpe.Original_Bid_Offer_Amount__c = amountValue;
            vpe.Status_of_Listing__c = 'Pending';
            vpe.Bid_Offer_Submitted__c = true;
            update vpe; 
            return true; 
        }
        
    }
    
    @AuraEnabled
    public static boolean bidOffer(Id sfdcid, String listingId, Double amountValue, Double minStartingBid, String auctionId){
        VPE_Listings__c vpeRecord;
        Double zeroValue = 0.01;
        if(sfdcid != null){
            vpeRecord = [Select id,VPE_Listing_Partner__c,Status_of_Listing__c,VPE_Listing_Partner__r.name from VPE_Listings__c where id = :sfdcid];
        }
        if(vpeRecord.VPE_Listing_Partner__r.name == CARVIO){
            IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c,Authtoken__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'CARVIOBID'] ;         
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(imdt.Endpoint__c+ listingId);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Authorization', imdt.Authtoken__c);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(60000);
            httpRequest.setBody('{"offer_amount":'+amountValue+', "IS_LCU_UPDATE" : false}');
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                response = h.send(httpRequest);
            } else {
                response.setStatusCode(200);
            }
            System.debug('ResponseBody----->>>'+response.getBody());
            VPE_Listings__c vpe = new VPE_Listings__c(Id=sfdcid); 
            if(response.getStatusCode()== 200){
                vpe.Original_Bid_Offer_Amount__c = amountValue;
                vpe.Status_of_Listing__c = 'Pending';
                if(!notFromBidButton){
                	vpe.Bid_Offer_Submitted__c = true;
                	vpe.Bid_Submitter__c = UserInfo.getUserId();
                }
                update vpe; 
                return true;
            }else{
                if(response.getBody().contains('expired')) {
                    vpe.Original_Bid_Offer_Amount__c = amountValue;
                    vpe.Status_of_Listing__c = 'Expired';
                    update vpe;   
                }
                return false;
            }
        } 
        else{
            VPE_Listings__c vpe = new VPE_Listings__c(); 
            vpe.Id = sfdcid; 
            vpe.Original_Bid_Offer_Amount__c = amountValue;
            vpe.Status_of_Listing__c = 'Pending';
            
            if(!notFromBidButton){
                	vpe.Bid_Offer_Submitted__c = true;
                	vpe.Bid_Submitter__c = UserInfo.getUserId();
             }
            update vpe; 
            return true; 
        }
        
    }
    
    @AuraEnabled
    public static String makeTraderevBid(Id sfdcid, String listingId, Double amountValue, Double minStartingBid, String auctionId) {
        VPE_Listings__c vpeRecord;
        if(sfdcid != null){
            vpeRecord = [Select id,VPE_Listing_Partner__c,VPE_Listing_Partner__r.name from VPE_Listings__c where id = :sfdcid];
        }
        if(vpeRecord.VPE_Listing_Partner__r.name == TRADEREV){
            IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c,Authtoken__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = :TRADEREV_BID_OFFER];
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(imdt.Endpoint__c);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('authenticationToken', imdt.Authtoken__c);
            httpRequest.setMethod('POST');
            if( auctionId == 'NOT_AVAILABLE') {
                httpRequest.setBody('{"proxyBidList": [ { "tradeId": '+listingId+', "startingBidAmount": '+minStartingBid+', "proxyBidAmount": '+amountValue+' }]}');
            } else {
                httpRequest.setBody('{"proxyBidList": [ { "tradeId": '+listingId+', "auctionId": '+auctionId+', "startingBidAmount": '+minStartingBid+', "proxyBidAmount": '+amountValue+' }]}');   
            }
            System.debug('body-->'+httpRequest.getBody());
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                response = h.send(httpRequest);
            } else {
                response.setStatusCode(202);
                response.setBody('{"requestId":"dededec9-f5d6-4778-88f9-a7a8c2b64757"}');
            }
            if( response.getStatusCode() == 202 ) {
                String dataToGetBidResult = '';
                JSONParser parser = JSON.createParser(response.getBody());
                while( parser.nextToken() != null ) {
                    if( parser.getCurrentName() == 'requestId' && parser.getCurrentToken() == JSONToken.VALUE_STRING ) {
                        dataToGetBidResult = '{"requestId":"'+parser.getText()+'"}';
                    }
                }
                return dataToGetBidResult;
            } else {
                return 'BID_NOT_ACCEPTED';
            }
        }
        else {
            return 'WRONG_PARTNER';
        }
    }
    public static void autoBidCheck(Set<Id> vpId){
        Decimal calculatedPrice;
        List<VPE_Listings__c > vpeListings =[SELECT Id,VPE_Listing_Partner__r.Name,VPE_Listing_Partner__c,Wholesale_ACV__c,VPE_Listing_Partner__r.of_Value__c, Predicted_Price__c,Listing_Id__c,Original_Bid_Offer_Amount__c,Starting_Bid__c,Auction_Id__c, Model_Year__c,Mileage__c,Retail_ACV__c,Make__c FROM VPE_Listings__c WHERE ID =: vpId ];
        List<VPE_Listings__c> manualList = new List<VPE_Listings__c>();
         Map<Id, VPE_Listing_Partner__c> partnerMap = new Map<Id, VPE_Listing_Partner__c>([SELECT Id, Name, Year_Limit__c, Price_Limit__c, Mileage_Limit__c,
                                                                                          Make_Value__c, Auto_Bid_Eligible__c, Vehicle_Condition_Grade__c,
                                                                                          Reference_Value__c,of_Value__c 
                                                                                          FROM VPE_Listing_Partner__c ORDER BY CreatedDate DESC]);
        for(VPE_Listings__c vpeListing : vpeListings) {
            
            calculatedPrice= ListingTriggerHandler.calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
            System.debug('CalculatedPrice--->>'+calculatedPrice);
            if(vpeListing.VPE_Listing_Partner__r.Name == 'TRADEREV') {
                String requestId =  BuyerListingController.getBidResult(BuyerListingController.makeTraderevBid(vpeListing.Id, vpeListing.Listing_Id__c, Double.valueOf(calculatedPrice), Double.valueOf(vpeListing.Starting_Bid__c), vpeListing.Auction_Id__c));  
                System.debug('RequestId------>>'+requestId); 
                if(requestId != null) {
                    BuyerListingController.saveBidValue(vpeListing.Id,Integer.ValueOf(calculatedPrice)); 
                }  
            }
            else if(vpeListing.VPE_Listing_Partner__r.Name == 'CARVIO'){
                notFromBidButton = true;
                BuyerListingController.bidOffer(vpeListing.Id, vpeListing.Listing_Id__c, Double.valueOf(calculatedPrice), 0, null); 
                notFromBidButton= false;
            }
            else
            {
                vpeListing.Status_of_Listing__c = 'Manual Bid Required'; 
                vpeListing.Original_Bid_Offer_Amount__c = ListingTriggerHandler.calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
                manualList.add(vpeListing);
            }
        } 
        if(manualList.size() > 0){
            update manualList;
        }
    }
    
    public static void autoBidCheck(Set<Id> vpId, Boolean manualBidRequired){
        Decimal calculatedPrice;
        List<VPE_Listings__c > vpeListings =[SELECT Id,VPE_Listing_Partner__r.Name,VPE_Listing_Partner__c,Wholesale_ACV__c,VPE_Listing_Partner__r.of_Value__c, Predicted_Price__c,Listing_Id__c,Original_Bid_Offer_Amount__c,Starting_Bid__c,Auction_Id__c, Model_Year__c,Mileage__c,Retail_ACV__c,Make__c FROM VPE_Listings__c WHERE ID =: vpId ];
        List<VPE_Listings__c> manualList = new List<VPE_Listings__c>();
         Map<Id, VPE_Listing_Partner__c> partnerMap = new Map<Id, VPE_Listing_Partner__c>([SELECT Id, Name, Year_Limit__c, Price_Limit__c, Mileage_Limit__c,
                                                                                          Make_Value__c, Auto_Bid_Eligible__c, Vehicle_Condition_Grade__c,
                                                                                          Reference_Value__c,of_Value__c 
                                                                                          FROM VPE_Listing_Partner__c ORDER BY CreatedDate DESC]);
        for(VPE_Listings__c vpeListing : vpeListings) {
            
            calculatedPrice= ListingTriggerHandler.calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
            System.debug('CalculatedPrice--->>'+calculatedPrice);
            if(vpeListing.VPE_Listing_Partner__r.Name == 'TRADEREV') {
                String requestId =  BuyerListingController.getBidResult(BuyerListingController.makeTraderevBid(vpeListing.Id, vpeListing.Listing_Id__c, Double.valueOf(calculatedPrice), Double.valueOf(vpeListing.Starting_Bid__c), vpeListing.Auction_Id__c));  
                System.debug('RequestId------>>'+requestId); 
                if(requestId != null) {
                    BuyerListingController.saveBidValue(vpeListing.Id,Integer.ValueOf(calculatedPrice)); 
                }  
            }
            else if(vpeListing.VPE_Listing_Partner__r.Name == 'CARVIO'){
                if(manualBidRequired) {
                     BuyerListingController.carvioManualBid(vpeListing.Id, vpeListing.Listing_Id__c, Double.valueOf(calculatedPrice), 0, null);
                } else {
                    notFromBidButton = true;
                    BuyerListingController.bidOffer(vpeListing.Id, vpeListing.Listing_Id__c, Double.valueOf(calculatedPrice), 0, null);
                    notFromBidButton = false;
                }
            }
            else
            {
                vpeListing.Status_of_Listing__c = 'Manual Bid Required'; 
                vpeListing.Original_Bid_Offer_Amount__c = ListingTriggerHandler.calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
                manualList.add(vpeListing);
            }
        } 
        if(manualList.size() > 0){
            update manualList;
        }
    }
    
    @AuraEnabled
    public static Boolean saveBidValue( String recordId, Integer bidValue ) {
        VPE_Listings__c listingToBeUpdate = [SELECT Id, Original_Bid_Offer_Amount__c FROM VPE_Listings__c WHERE Id =: recordId LIMIT 1];
        if( listingToBeUpdate != null ) {
            listingToBeUpdate.Original_Bid_Offer_Amount__c = bidValue;
            listingToBeUpdate.Status_of_Listing__c = 'Pending';
            update listingToBeUpdate;
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static String getBidResult( String requestId ) {
        IAAI_VPE_Listing_Partner__mdt tradeAuth = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: PARTNER_AUTHENTICATION LIMIT 1];
        IAAI_VPE_Listing_Partner__mdt tradeBidResult = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: TRADEREV_BID_RESULT LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tradeAuth.Endpoint__c);
        req.setMethod('POST');
        req.setBody('grant_type=client_credentials&client_id='+tradeAuth.UserName__c+'&client_secret='+tradeAuth.Authtoken__c);
        HttpResponse refreshToken = new HttpResponse();
        if( !Test.isRunningTest() ) {
            refreshToken = http.send(req);
        } else {
            refreshToken.setStatusCode(200);
        }
        if( requestId != null ) {
            Http http1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(tradeBidResult.Endpoint__c);
            req1.setMethod('POST');
            System.debug('requestId-->'+requestId);
            req1.setBody(requestId);
            req1.setHeader('authenticationToken',tradeBidResult.Authtoken__c);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            HttpResponse response = new HttpResponse();
            if( !Test.isRunningTest() ) {
                response = http1.send(req1);
            } else {
                response.setStatusCode(200);
            }
            System.debug(response.getBody());
            if( response.getStatusCode() == 200 ) {
                return response.getBody();
            } else {
                return 'UNABLE_TO_RETRIEVE_RESULT';
            }
        }
        else {
            return 'INVALID_REQUEST_ID';   
        }
    }
    
    @AuraEnabled
    public static BuyerListingDataTableWrapper getBuyerPortalData(Decimal pageNumber, Decimal pageSize,String vpePartnerId,String listingStatuses, String startId, String endId, String type) {
     
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        Set<String> selectedListingStates = new Set<String>();
        if(listingStatuses != null || listingStatuses != ''){
            for(String s:listingStatuses.split(',')){
                if(s != ''){
                    selectedListingStates.add(s); 
                }
            }
        }
        
        String countQuery = 'SELECT count() FROM VPE_Listings__c ';
         if(vpePartnerId == 'All' && !selectedListingStates.isEmpty()){
                countQuery = countQuery + 'Where Status_of_Listing__c IN :selectedListingStates';
            }else if(vpePartnerId !='All' && selectedListingStates.isEmpty()){
                countQuery = countQuery + 'Where VPE_Listing_Partner__c =\''+vpePartnerId+'\'';
            }else if(vpePartnerId !='All' && !selectedListingStates.isEmpty()){
                countQuery = countQuery + 'Where VPE_Listing_Partner__c =\''+vpePartnerId+'\'' +' AND Status_of_Listing__c IN :selectedListingStates';
            }
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        //Total Records
        Integer totalRecords = Database.countQuery(countQuery);
        Integer recordEnd = pSize * pNumber;
        BuyerListingDataTableWrapper objDT =  new BuyerListingDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;

        String accountQuery = 'SELECT Id,Primary_Damage__c,Vehicle_Condition_Grade__c,Name,Starting_Bid__c,Top_Bid__c, Scheduled_Time_for_Auction__c, Mileage__c,Pickup_State__c,Predicted_Price__c,Provider_Name_Formula__c, Auction_Id__c,VPE_Listing_Partner__r.Name,Most_Recent_Sale_Date__c, VIN__c, Model_Year__c, Make__c, Model__c, Hyperlink__c,Vehicle_Image__c, Status_of_Listing__c, Provider_Name__c,Average_Sale_Price__c,Highest_Sale_Price__c,Lowest_Sale_Price__c,Wholesale_ACV__c,Retail_ACV__c,Provider_State__c,MarketPlaceUpdate__c,Bid_Offer_Submitted__c,Notes__c,VPE_Listing_Partner__r.Logo_URL__c,VPE_Listing_Partner__r.Listing_Partner_Type__c, VPE_Listing_Partner__c,Listing_Id__c,Original_Bid_Offer_Amount__c,VPE_Listing_Partner__r.Rules__c  FROM VPE_Listings__c ';
    
       
    
        if(type != 'init'){
        if(type == 'pre'){
            accountQuery = accountQuery +' where Id < \''+String.escapeSingleQuotes(endId)+'\''; 
         }else{
            accountQuery = accountQuery +' where Id > \''+String.escapeSingleQuotes(endId)+'\'';
          }
        }

        if(type != 'init'){
            if(vpePartnerId == 'All' && !selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'AND Status_of_Listing__c IN:selectedListingStates';
            }else if(vpePartnerId !='All' && selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'AND VPE_Listing_Partner__c =\''+vpePartnerId+'\'';
            }else if(vpePartnerId !='All' && !selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'AND VPE_Listing_Partner__c =\''+vpePartnerId+'\'' +' AND Status_of_Listing__c IN: selectedListingStates';
            }
        }else{
            if(vpePartnerId == 'All' && !selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'Where Status_of_Listing__c IN :selectedListingStates';
            }else if(vpePartnerId !='All' && selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'Where VPE_Listing_Partner__c =\''+vpePartnerId+'\'';
            }else if(vpePartnerId !='All' && !selectedListingStates.isEmpty()){
                accountQuery = accountQuery + 'Where VPE_Listing_Partner__c =\''+vpePartnerId+'\'' +' AND Status_of_Listing__c IN :selectedListingStates';
            }
        }
        
        if(type == 'init'){
            accountQuery = accountQuery +' ORDER BY Id LIMIT '+pageSize;
        }else if(type == 'pre'){
            accountQuery = accountQuery +' ORDER BY Id DESC LIMIT '+pageSize;
         }else if(type == 'next'){
            accountQuery = accountQuery +' ORDER BY Id LIMIT '+pageSize;
          }else if(type != 'init'){
              Integer a = integer.valueof(type) * integer.valueof(pageSize);
              accountQuery = accountQuery +' ORDER BY Id LIMIT '+pageSize+' OFFSET '+a ;
         }
        objDT.buyerListingList = Database.query(accountQuery);
        
        Integer numPages = integer.valueof(math.ceil(math.ceil(totalRecords)/pSize));
        objDT.PageCounter =  getPageCountChange(pNumber,pSize,numPages);
        return objDT;
    }

  
   
    /*
    *  When total number of records to display changes
    *  provide footer with new set of page counter info
    *  to display
    * */

    /*@AuraEnabled
    public static PGN_PageInfo getPageCountInfo(String pageCountInfo){
        
        Integer currentListCount = pageCountInfo != null && pageCountInfo != '' ? Integer.valueOf(pageCountInfo) : 10;
        
        PGN_PageInfo pgn = new PGN_PageInfo();        
        pgn.totalPages = ([SELECT COUNT() FROM VPE_Listings__c]/(currentListCount))+1;
        pgn.currentPageNumber = 1;
        List<Integer> cnt = new List<Integer>();
        for(Integer loop_var = 0;loop_var < pgn.totalPages;loop_var++){
            cnt.add(loop_var+1);
            if((loop_var+1) == 9)
                break;
        }
        pgn.pageCounter = cnt;
        
        return pgn;        
    }*/

    /*
    *  When page count change or next or previous button is clicked
    *  provide footer with new set of page counter info
    *  to display
    * */
    
    @AuraEnabled
    public static VPE_Listings__c getPredictivePrice(String listingId){
        VPE_Listings__c listingToBeUpdate = new VPE_Listings__c();
        try {
            VPE_Listings__c listing = [SELECT Id, Original_Bid_Offer_Amount__c, Name, VIN__c, createdDate, Model_Year__c, Make__c, Model__c,Predicted_Price__c,Predicted_Price_status__c,Engine_Status_Code__c, Assignment_Date__c,Mileage__c, Vehicle_Condition_Grade__c, Loss_Type_Code__c, Primary_Damage__c, Secondary_Damage__c  FROM VPE_Listings__c WHERE Id =:listingId];
            listingToBeUpdate = IAAI_PredictedPriceCalloutClass.getPredictedPrice(listing, IAAI_PredictedPriceCalloutClass.getToken());
            update listingToBeUpdate;   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listingToBeUpdate;
    }
    
    //@AuraEnabled
    public static List<Integer> getPageCountChange(Integer pageNumber,Integer currnetPagesCount,Integer totalPages){
      
        //PGN_PageInfo pgn = new PGN_PageInfo();
        //pgn.currentPageNumber = Integer.valueOf(pageNumber);
        //pgn.totalPages = Integer.valueOf(totalPages);

        List<Integer> cnt = new List<Integer>();

        if((Integer.valueOf(pageNumber)) <= Integer.valueOf(totalPages) && Integer.valueOf(pageNumber) != 1){
            for(Integer loop_var = (Integer.valueOf(pageNumber));loop_var < (Integer.valueOf(pageNumber)+9) && loop_var < (Integer.valueOf(totalPages)+1) ;loop_var++){
               cnt.add(loop_var);
            }
        }else if(Integer.valueOf(pageNumber) == 1){
            for(Integer loop_var = 1;loop_var < 10 && loop_var <= Integer.valueOf(totalPages);loop_var++){
               cnt.add(loop_var);
            }
        }else{
            if(Integer.valueOf(currnetPagesCount) >= Integer.valueOf(totalPages)){
                for(Integer loop_var = 1;loop_var < (Integer.valueOf(totalPages)+1);loop_var++){
                 cnt.add(loop_var);
                }
            }else{
                for(Integer loop_var = (Integer.valueOf(totalPages)-9);loop_var < (Integer.valueOf(totalPages)+1);loop_var++){
                   cnt.add(loop_var);
                }
            }
        }
        return cnt;
    }
 
    //Wrapper Class For BuyerListing DataTable  
    public class BuyerListingDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<VPE_Listings__c> buyerListingList {get;set;}
        @AuraEnabled
        public List<Integer> PageCounter {get;set;}
    }
    
    
    
    
}