global class VPECarvioExpireBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        datetime d = system.now().addHours(-24);
        String Expired = 'Expired';
        String Won = 'Won';
        String CARVIO = 'CARVIO';
        string uNum = ' ';
        String query = 'SELECT id, Bid_Offer_Submitted__c,Stock_ID__c, VPE_Listing_Partner__c, Status_of_Listing__c, VPE_Listing_Partner__r.Name, createdDate FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name =: CARVIO AND Status_of_Listing__c !=:Expired AND Status_of_Listing__c !=:Won AND Bid_Offer_Submitted__c = false AND ASAP_Updated__c = false AND (Stock_ID__c = null OR Stock_ID__c =\'\''+' ) AND createdDate <=:d';
        system.debug('query '+query);
        return  Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        // process each batch of records
        system.debug(records.size());
        List<VPE_Listings__c> lstVPE = new List<VPE_Listings__c>();
        for(VPE_Listings__c objVPeLsiting :records ){
            objVPeLsiting.Status_of_Listing__c = 'Expired';
            lstVPE.add(objVPeLsiting);
            
        }
        update lstVPE;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}