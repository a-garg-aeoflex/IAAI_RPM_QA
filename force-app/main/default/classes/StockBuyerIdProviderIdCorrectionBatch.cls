global class StockBuyerIdProviderIdCorrectionBatch implements Database.Batchable<sObject> {
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
         
        //String query = 'SELECT Id,Buyer_ID__c, Provider_ID__c  FROM Stock__c WHERE (Buyer_ID__c!= null OR Provider_ID__c!=null) and CreatedDate = today';
      String query = Label.StockBuyerIdProviderIdCorrectionTodayQuery;
       system.debug('query***'+query);
       
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Stock__c> stockList) {
        
     
       
        List<Stock__c> lstStockToUpdate = new List<Stock__c>();
        boolean containFlag  = false;
        
        for(Stock__c stk : stockList){ 
            
            if(stk.Buyer_ID__c!= null && !stk.Buyer_ID__c.startsWith('BUY-')){

                stk.Buyer_ID__c = 'BUY-'+stk.Buyer_ID__c;
                containFlag = true ;
                
            }
            if(stk.Provider_ID__c!= null && !stk.Provider_ID__c.startsWith('PRO-')){
                
                stk.Provider_ID__c = 'PRO-'+stk.Provider_ID__c;
                containFlag = true ;               
            }
            
            if(containFlag){
               lstStockToUpdate.add(stk); 
               containFlag = false;
            }       
            
        }
        
        
        try {
            // Update the Stock Record
            update lstStockToUpdate;
            
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {       
  }
}