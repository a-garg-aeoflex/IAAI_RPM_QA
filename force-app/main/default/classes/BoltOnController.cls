public without Sharing class BoltOnController {
    @AuraEnabled (cacheable = true)
    public static List<VPE_Listings__c> dealerListingRecords( String contactId, Integer offsetValue ){
        return [SELECT Id, Name, Provider_Name__c, VIN__c, Make__c, Model_Year__c, Model__c, Mileage__c, CreatedDate, CreatedById, CreatedBy.Name, Original_Bid_Offer_Amount__c, Accept_Offer__c FROM VPE_Listings__c WHERE Contact__c =: contactId order by Accept_Offer__c DESC,Original_Bid_Offer_Amount__c DESC NULLS LAST,createddate DESC LIMIT 10 OFFSET :offsetValue];
    }
    @AuraEnabled
    public static List<VPE_Listings__c> createListing(List<VPE_Listings__c> data) {
        Integer dataSizeForBatch = 1000;
        if( Test.isRunningTest() ) {
            dataSizeForBatch = 5;
        }
        for (VPE_Listings__c vpl : data) {
            vpl.VPE_Listing_Partner__c = IAAI_BoltOnController.getCurrentListingPartner().Id;
        }
        if( data.size() <= dataSizeForBatch ) {
            upsert data Listing_Id__c; return data;
        } else {
            HandleBoltOnBulkListing hb = new HandleBoltOnBulkListing(data);
            database.executeBatch(hb);
            List<VPE_Listings__c> emptyListing = new List<VPE_Listings__c>();
            return emptyListing;
        }
    }

    @AuraEnabled
    public static Map<String, Object> createListingRecord(VPE_Listings__c listing){
        try {
            listing.VPE_Listing_Partner__c = IAAI_BoltOnController.getCurrentListingPartner().Id;
            upsert listing Listing_Id__c;
            return new Map<String, Object>{'success' => true};
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> doAcceptOffer(VPE_Listings__c listing){
        try {
            update listing;
            return new Map<String, Object> {'success' => true};
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> decodeVIN(String vin){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:VIN_Decoder?Vin='+vin+'&BusinessGroupId=1&FullDetails=1');
            request.setMethod('GET');
            request.setHeader('Applicationid', '{!$Credential.Username}');
            request.setHeader('AuthenticationKey', '{!$Credential.Password}');
           
            HttpResponse response = http.send(request);
            if(!Test.isRunningTest() && response.getStatusCode() == 200) {
                Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> parsedBody = (List<Object>) parsedResult.get('Body');
                return new Map<String, Object>{'success' => true, 'data' => parsedBody.get(0)};
            } else {return new Map<String, Object>{'success' => false};
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VPE_Listings__c> fetchListingsPendingForPickup(){
        try {
            return [SELECT Id, Name, VIN__c, Make__c, Model__c, Model_Year__c, Status_of_Listing__c, 
                    Stock_Lookup__c, Stock_Lookup__r.PICKUP_DATETIME__c,
                    Stock_Lookup__r.QUOTED_RELEASE_DATE__c, Stock_Lookup__r.DISPATCH_DATETIME__c FROM VPE_Listings__c 
                    WHERE CreatedById =:UserInfo.getUserId() AND Status_of_Listing__c = 'Won' 
                    ORDER BY Stock_Lookup__r.PICKUP_DATETIME__c DESC];
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveListing(VPE_Listings__c listing){
        try {
            listing.Listing_Id__C = UserInfo.getUserId()+listing.VIN__c;
            listing.VPE_Listing_Partner__c = IAAI_BoltOnController.getCurrentListingPartner().Id;
            upsert listing Listing_Id__c;
            return new Map<String, Object>{'success' => true, 'data' => listing};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}