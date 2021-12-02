global class FetchAutomateBidResult implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    private static final String PARTNER_NAME = 'TRADEREV';
    private static final String PARTNER_AUTHENTICATION = 'TRADEREV_AUTHENTICATION';
    private static final String TRADEREV_BID_RESULT = 'TRADEREV_BID_RESULT';
    Map<String, String> tradeIdVsResult = new Map<String, String>();
    public String requestId;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        TraderevBidResultList responseList = new TraderevBidResultList();
        Set<String> tradeIds = new Set<String>();
        String queryString = '';
        IAAI_VPE_Listing_Partner__mdt tradeAuth = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: PARTNER_AUTHENTICATION LIMIT 1];
        IAAI_VPE_Listing_Partner__mdt tradeBidResult = [Select DeveloperName,UserName__c,Endpoint__c,Authtoken__c From IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName =: TRADEREV_BID_RESULT LIMIT 1];
        VPE_Listing_Partner__c listingPartner = [Select Id, Request_Id__c from VPE_Listing_Partner__c where Name =: PARTNER_NAME LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tradeAuth.Endpoint__c);
        req.setMethod('POST');
        req.setBody('grant_type=client_credentials&client_id='+tradeAuth.UserName__c+'&client_secret='+tradeAuth.Authtoken__c);
        HttpResponse refreshToken = http.send(req);
        if( listingPartner != null ) {
            if( listingPartner.Request_Id__c != null ) {
                Http http1 = new Http();
                HttpRequest req1 = new HttpRequest();
                req1.setEndpoint(tradeBidResult.Endpoint__c);
                req1.setMethod('POST');
                req1.setBody('{"requestId":"'+listingPartner.Request_Id__c+'"}');
                req1.setHeader('authenticationToken',tradeBidResult.Authtoken__c);
                req1.setHeader('Content-Type', 'application/json');
                req1.setHeader('Accept', 'application/json');
                HttpResponse response = http1.send(req1);
                if( response.getStatusCode() == 200 ) {
                    responseList = parse(response.getBody());
                }
            }
        }
        if( responseList.resultList.size() > 0 ) {
            for( TraderevBidResult t : responseList.resultList ) {
                tradeIds.add(t.tradeId);
                tradeIdVsResult.put(t.tradeId, t.status);
            }
            queryString = 'SELECT Id, Original_Bid_Offer_Amount__c, Listing_Id__c, Bid_Offer_Submitted__c FROM VPE_Listings__c WHERE Listing_Id__c IN :tradeIds';
        }
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext bc,List<VPE_Listings__c> scope){
        if( scope.size() > 0 ) {
            List<VPE_Listings__c> listingToBeUpdate = new List<VPE_Listings__c>();
            for( VPE_Listings__c v : scope ) {
                if( tradeIdVsResult.get(v.Listing_Id__c) == 'failed' ) {
					v.Bid_Offer_Submitted__c = false;
                    v.Original_Bid_Offer_Amount__c = 0;
                    listingToBeUpdate.add(v);
                } else {
                    v.Status_of_Listing__c = 'Pending';
                    listingToBeUpdate.add(v);
                }
            }
            update listingToBeUpdate;
        }
    }
    global void finish(Database.BatchableContext bc) {
        List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Get_Result_of_Automated_Bids' LIMIT 1];
        if( ct.size() > 0 ) {
            System.abortJob(ct[0].Id);
        }
        VPE_Listing_Partner__c partner = [SELECT Id, Request_Id__c FROM VPE_Listing_Partner__c WHERE Name =: PARTNER_NAME LIMIT 1];
        if( partner != null ) {
            partner.Request_Id__c = null;
        	update partner;
        }
    }
    global void execute( SchedulableContext sc ) {
        System.debug('Scheduled Fire');
        Database.executeBatch(new FetchAutomateBidResult());
    }
    public static TraderevBidResultList parse(String json){
        return (TraderevBidResultList) System.JSON.deserialize(json, TraderevBidResultList.class);
    }
    public class TraderevBidResult {
        String tradeId;
        String auctionId;
        String status;
        String errorMessage;
    }
    public class TraderevBidResultList {
        List<TraderevBidResult> resultList;
    }
}