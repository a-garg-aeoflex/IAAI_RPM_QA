public class DELETE_Stocks implements Database.Batchable<sObject>, Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Stocks(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Stocks(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Stock__c ORDER BY CreatedDate ASC LIMIT 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Stock__c> lstStocks = scope;
        database.delete(lstStocks);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_Licenses());
        }
    }
    
}