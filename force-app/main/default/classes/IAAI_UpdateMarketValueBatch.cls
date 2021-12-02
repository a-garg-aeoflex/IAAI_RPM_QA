global class IAAI_UpdateMarketValueBatch implements Database.Batchable<sobject>,Database.AllowsCallouts {
    public List<VPE_Listings__c> listings = new List<VPE_Listings__c>();
    global IAAI_UpdateMarketValueBatch(List<VPE_Listings__c> newListings) {
        listings = newListings;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,VIN__c,Model_Year__c, Make__c, Model__c, Has_Keys__c, Average_Sale_Price__c,Highest_Sale_Price__c,Lowest_Sale_Price__c,Most_Recent_Sale_Date__c,MarketPlaceUpdate__c,Claim__c FROM VPE_Listings__c WHERE MarketPlaceUpdate__c = false ORDER BY CreatedDate DESC';
        if( listings.size() > 0 ) {
            query = 'SELECT ID,VIN__c,Model_Year__c, Make__c, Model__c, Has_Keys__c,Average_Sale_Price__c,Highest_Sale_Price__c,Lowest_Sale_Price__c,Most_Recent_Sale_Date__c,MarketPlaceUpdate__c, Claim__c FROM VPE_Listings__c WHERE MarketPlaceUpdate__c = false AND Id IN :listings order by Name desc';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        list<VPE_Listings__c> listVPE = new list<VPE_Listings__c>();
        for(VPE_Listings__c v:records){
            IAAI_Market_Value_Search imvs = new IAAI_Market_Value_Search();
            IAAI_Market_Value_Search.wrapVPEValue ab = imvs.basicAuthCallout(v);
            v.Average_Sale_Price__c = decimal.valueOf(ab.Average_Sale_Price);
            v.Highest_Sale_Price__c = decimal.valueOf(ab.Highest_Sale_Price);
            v.Lowest_Sale_Price__c =  decimal.valueOf(ab.Lowest_Sale_Price);
            v.Most_Recent_Sale_Date__c = ab.MOST_RECENT_SALE_DATE;
            v.MarketPlaceUpdate__c = true;
            listVPE.add(v);
        } 
        if(listVPE.size()>0){
            update listVPE;
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}