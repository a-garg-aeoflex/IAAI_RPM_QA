global class IAAI_Blackbook_Batch implements Database.Batchable<sobject>,   Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
         return Database.getQueryLocator(
            'SELECT ID,VIN__c,Wholesale_ACV__c,Retail_ACV__c,Blackbookupdated__c FROM VPE_Listings__c where Blackbookupdated__c = false  order by Name desc Limit 50000'
        );
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        List<VPE_Listings__c> listVPEToUpdate = new List<VPE_Listings__c>();
        Map<String,VPE_Listings__c> mapVinandVPElisting = new  Map<String,VPE_Listings__c>();
        for(VPE_Listings__c VPEL : records){
            mapVinandVPElisting.put(VPEL.VIN__c,VPEL);
        }
        IAAI_Blackbook_Value_Search blackbookapi = new IAAI_Blackbook_Value_Search();
        List<IAAI_Jason_parser.Body> listBody = new  List<IAAI_Jason_parser.Body>();
        system.debug('zgizigizig'+mapVinandVPElisting.keyset());
        listBody =  blackbookapi.basicAuthCallout(mapVinandVPElisting.keyset());
        
        for(IAAI_Jason_parser.Body b: listBody){
            if(mapVinandVPElisting.get(b.v) != null){
            VPE_Listings__c vlist = new VPE_Listings__c();
            vlist =  mapVinandVPElisting.get(b.v);
            vlist.Blackbookupdated__c = true;
            vlist.Wholesale_ACV__c = b.WholeACV;
            vlist.Retail_ACV__c = b.RetailACV;
           listVPEToUpdate.add(vlist); 
            }
        }
        
        if(listVPEToUpdate.size()>0){
            update listVPEToUpdate;
        }
        
     }     
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}