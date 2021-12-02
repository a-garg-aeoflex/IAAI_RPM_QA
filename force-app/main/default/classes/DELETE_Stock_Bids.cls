public class DELETE_Stock_Bids implements Database.Batchable<sObject>, Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Stock_Bids(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Stock_Bids(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Stock_Bid__c ORDER BY CreatedDate ASC Limit 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Stock_Bid__c> lstStockBid = scope;
        database.delete(lstStockBid);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            //Database.executeBatch(new DELETE_Account());
            Database.executeBatch(new DELETE_Integration_logs());
        }
    }
}