/*******************************************************************************************
* @Name         IAAI_UpdateVPEListingWithStock
* @Date         29/12/2020
* @Description  This class runs a process to link VPE listing records with Stock records based on their VIN number
*******************************************************************************************/
public class IAAI_UpdateVPEListingWithStockBatch implements Database.batchable<sObject>{
    
    /**************************************************************************************
    * @Description  This method retrieves all those VPE listing records that are not linked with any stock records
    *               and their VIN number is not empty
    **************************************************************************************/ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Stock_Lookup__c, VIN__c FROM VPE_Listings__c WHERE Stock_Lookup__c=null AND VIN__c!=null');
    }
    
    /**************************************************************************************
    * @Description  This method process all the retrieved VPE listing records and associate them to 
    *               appropriate stock records.
    **************************************************************************************/ 
    public void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        if(records!=null && !records.isEmpty()){
            Set<String> vinSet = new Set<String>();
            
            //Adds all the VPE Listing VIN numbers to a set
            for(VPE_Listings__c vpeListingRec: records){
                vinSet.add(vpeListingRec.VIN__c);
            }
            
            //Queries all the Stock records with the VIN number present in the Vin set coollection.
            List<Stock__c> stockList = [SELECT Id, VIN__c FROM Stock__c WHERE VIN__C IN :vinSet];
            
            if(stockList!= null && !stockList.isEmpty()){
                Map<String, Id> mapVinStockId = new Map<String, Id>(); // Map of String vs. Id - This will be used to store Stock Id against the VIN number.
                for(Stock__c stockRec: stockList){
                    mapVinStockId.put(stockRec.VIN__c, stockRec.Id);
                }
                
                //Update the VPE Listing records with the appropriate stock record with the matching VIN number.
                for(VPE_Listings__c vpeListingRec: records){
                    vpeListingRec.Stock_Lookup__c = mapVinStockId.get(vpeListingRec.VIN__c);
                }
                
                try{
                    update records;
                }
                catch(Exception ex){
                    System.debug('Insert failed in class IAAI_UpdateVPEListingWithStock execute method');
                    System.debug('ex.getMessage() = ' + ex.getMessage());
                    System.debug('ex.getLineNumber() = ' + ex.getLineNumber());
                    System.debug('ex.getStackTraceString() = ' + ex.getStackTraceString());
                    System.debug('ex.getTypeName() = ' + ex.getTypeName());
                    ex.setMessage('Insert failed in class IAAI_UpdateVPEListingWithStock execute method');
                }
            }
        }
    }
    
    /**************************************************************************************
    * @Description  This method is not being used but have to define it because of the Batchable interface.
    **************************************************************************************/ 
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}