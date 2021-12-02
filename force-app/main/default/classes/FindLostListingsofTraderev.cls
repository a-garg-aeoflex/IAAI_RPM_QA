global class FindLostListingsofTraderev implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String partnerName = CustomConstants.TRADEREV;
        String status = CustomConstants.PENDING;
        String query;
        if( !Test.isRunningTest() ) {
            query = 'Select Id,Status_of_Listing__c From VPE_Listings__c Where VPE_Listing_Partner__r.Name =: partnerName AND Status_of_Listing__c =: status AND LastModifiedDate != LAST_N_DAYS:04';
        } else {
            query = 'Select Id,Status_of_Listing__c From VPE_Listings__c Where VPE_Listing_Partner__r.Name =: partnerName AND Status_of_Listing__c =: status';
        }
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> scope) {
        for( VPE_Listings__c vpl : scope ) {
            vpl.Status_of_Listing__c = 'Lost';
        }
        update scope;
    }
    global void finish(Database.BatchableContext bc) {
        
    }
    global void execute( SchedulableContext sc ) {
        Database.executeBatch(new FindLostListingsofTraderev());
    }
}