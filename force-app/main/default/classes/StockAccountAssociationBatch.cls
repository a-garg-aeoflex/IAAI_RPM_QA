global class StockAccountAssociationBatch implements Database.Batchable<sObject> {
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
         
        //String query = 'SELECT Id,Buyer_ID__c, Buyer_Name__c,Provider_ID__c, Provider_Name__c  FROM Stock__c WHERE (Buyer_ID__c!= null OR Provider_ID__c!=null)';
        String query = Label.StockAccountAssociationQuery;
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Stock__c> stockList) {       
		
        Map<Id, Stock__c> mapStock = new Map<Id, Stock__c>();
        Map<String, List<Id>> mapBuyerStk = new Map<String, List<Id>> ();
        Map<String,List<Id>> mapProviderStk = new Map<String, List<Id>>();
        Map<String, Id> mapBIIDAcc = new Map<String, Id> ();
        List<Stock__c> lstStockToUpdateProvider = new List<Stock__c>();
        List<Stock__c> lstStockToUpdateBuyer = new List<Stock__c>();
         boolean containFlag  = false;
         
        for(Stock__c stk : stockList){        
            if(stk.Buyer_ID__c!= null && stk.Buyer_ID__c.startsWith('BUY-')){                
                if(mapBuyerStk.containsKey(stk.Buyer_ID__c)){
                    mapBuyerStk.get(stk.Buyer_ID__c).add(stk.Id);                    
                }else{
                    List<Id> lstBuyerStockId = new List<Id>();
                    lstBuyerStockId.add(stk.Id);
                    mapBuyerStk.put(stk.Buyer_ID__c, lstBuyerStockId);
                }                
                mapStock.put(stk.Id, stk); 
            }
            
            if(stk.Provider_ID__c!= null && stk.Provider_ID__c.startsWith('PRO-')){                
                if(mapProviderStk.containsKey(stk.Provider_ID__c)){
                    mapProviderStk.get(stk.Provider_ID__c).add(stk.Id);
                }else{
                    List<Id> lstProviderStockId = new List<Id>();
                    lstProviderStockId.add(stk.Id);
                    mapProviderStk.put(stk.Provider_ID__c, lstProviderStockId);
                }
                mapStock.put(stk.Id, stk);            
            }
        }
			
        for(Account acc : [SELECT Id, BI_ID__c FROM Account WHERE (BI_ID__c IN :mapBuyerStk.keySet() OR BI_ID__c IN :mapProviderStk.keySet())]){        
           mapBIIDAcc.put(acc.BI_ID__c, acc.Id);
        }
		
        for (String BIID : mapBIIDAcc.KeySet()){
            if(mapBuyerStk.containsKey(BIID)){              
                for(Id stkId : mapBuyerStk.get(biId)){
                    mapStock.get(stkId).Buyer_Name__c = mapBIIdAcc.get(biId);   
                    lstStockToUpdateBuyer.add(mapStock.get(stkId));  
                }
                
            }
            if(mapProviderStk.containsKey(BIID)){                
                for(Id stkId : mapProviderStk.get(biId)){
                    mapStock.get(stkId).Provider_Name__c = mapBIIdAcc.get(biId);    
                    lstStockToUpdateProvider.add(mapStock.get(stkId));  
                }
            }
        }
        
        
        try {
            // Update the Stock Record
            update lstStockToUpdateProvider;
            update lstStockToUpdateBuyer;
		} catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {       
  }
}