global class IAAI_UpdatePredictedPriceBatch implements Database.Batchable<sobject>,Database.AllowsCallouts {
    //public List<VPE_Listings__c> listings = new List<VPE_Listings__c>();
    //global IAAI_UpdatePredictedPriceBatch(List<VPE_Listings__c> newListings) {
    //    listings = newListings;
    //}
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,VIN__c,Model_Year__c, Make__c, Model__c,createddate, Mileage__c, Vehicle_Condition_Grade__c,Loss_Type_Code__c,Primary_Damage__c,Secondary_Damage__c,Engine_Status_Code__c,Assignment_Date__c,Predicted_Price__c,Predicted_Price_status__c  FROM VPE_Listings__c WHERE  Assignment_Date__c != null';
        //if( listings.size() > 0 ) {
        //    query = 'SELECT ID,VIN__c,Model_Year__c, Make__c, Model__c,Average_Sale_Price__c,Highest_Sale_Price__c,Lowest_Sale_Price__c FROM VPE_Listings__c WHERE MarketPlaceUpdate__c = false AND Id IN :listings order by Name desc';
        //}
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        system.debug('------atoken3----');
        list<VPE_Listings__c> listVPE = new list<VPE_Listings__c>();
        String aToken = IAAI_PredictedPriceCalloutClass.getToken();
        system.debug('------atoken----'+atoken);
        if(aToken != null){
         for(VPE_Listings__c v : records){
             listVPE.add(IAAI_PredictedPriceCalloutClass.getPredictedPrice(v,aToken));
             system.debug('------valueReturned---'+listVPE);
        }   
     }
         
        if(listVPE.size()>0){
            update listVPE;
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}