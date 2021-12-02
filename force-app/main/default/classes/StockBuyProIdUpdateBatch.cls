global class StockBuyProIdUpdateBatch implements Database.Batchable<sObject> {
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
         
        /*SELECT Id,Buyer_ID__c, Buyer_Name__c,Provider_ID__c, Provider_Name__c FROM Stock__c 
		  WHERE ((Buyer_ID__c != null AND (NOT Buyer_Id__c like 'BUY-%'))
				Or (Provider_ID__c != null  AND (NOT Provider_ID__c Like 'PRO-%'))); */
        
		String query = Label.StockBuyProPrefixIdUpdateQuery;
		system.debug('query  = '+query);
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Stock__c> stockList) {       
		List<Stock__c> lstStockUpdate = new List<Stock__c>();
         system.debug('stockList size = '+stockList.size());  
        for(Stock__c objTempStock : stockList){
            system.debug(' objTempStock '+objTempStock.Id);
			if(String.isNotBlank(objTempStock.Buyer_ID__c) && String.isNotBlank(objTempStock.Provider_ID__c) && !objTempStock.Buyer_ID__c.startsWithIgnoreCase('BUY-') 
               && !objTempStock.Provider_ID__c.startsWithIgnoreCase('PRO-')){
				objTempStock.Buyer_ID__c = 'BUY-'+objTempStock.Buyer_ID__c;
				objTempStock.Provider_ID__c = 'PRO-'+objTempStock.Provider_ID__c;
				lstStockUpdate.add(objTempStock);
			}else if(String.isNotBlank(objTempStock.Buyer_ID__c) && !objTempStock.Buyer_ID__c.startsWithIgnoreCase('BUY-')){
				objTempStock.Buyer_ID__c = 'BUY-'+objTempStock.Buyer_ID__c;
				lstStockUpdate.add(objTempStock);
			}else if(String.isNotBlank(objTempStock.Provider_ID__c) && !objTempStock.Provider_ID__c.startsWithIgnoreCase('PRO-')){
				objTempStock.Provider_ID__c = 'PRO-'+objTempStock.Provider_ID__c;
				lstStockUpdate.add(objTempStock);
			}
			
		}
        system.debug('lstStockUpdate size = '+lstStockUpdate.size());
        
        try {
            if(!lstStockUpdate.isEmpty()){
				update lstStockUpdate;
			}
		} catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {    
        database.executeBatch(new StockAccountAssociationBatch());
  }
}