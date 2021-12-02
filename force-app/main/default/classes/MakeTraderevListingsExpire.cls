global class MakeTraderevListingsExpire implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start( Database.BatchableContext bc ) {
        Set<String> statuses = new Set<String> {'Won','Lost', 'Expired'};
        String traderev = CustomConstants.TRADEREV;
        String query = 'SELECT Id, Status_of_Listing__c, Scheduled_Time_for_Auction__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = : traderev AND Status_of_Listing__c NOT IN :statuses';
        return Database.getQueryLocator(query);
    }
    global void execute( Database.BatchableContext bc, List<VPE_Listings__c> listings ) {
        if( listings.size() > 0 ) {
            for( VPE_Listings__c vpl : listings ) {
                if( vpl.Status_of_Listing__c == CustomConstants.ACTIVE ) {
                    if( System.now() > vpl.Scheduled_Time_for_Auction__c  ) {
                        vpl.Status_of_Listing__c = 'Expired';   
                    }
                }
                else {
                    vpl.Status_of_Listing__c = 'Expired';
                }
            }
            update listings;
        }
    }
    global void finish( Database.BatchableContext bc ) {
        
    }
    
    global void execute( SchedulableContext sc ) {
        Database.executeBatch(new MakeTraderevListingsExpire());
    }
}