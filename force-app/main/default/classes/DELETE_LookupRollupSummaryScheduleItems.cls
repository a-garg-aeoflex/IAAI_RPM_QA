public class DELETE_LookupRollupSummaryScheduleItems implements Database.Batchable<sObject>, Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_LookupRollupSummaryScheduleItems(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_LookupRollupSummaryScheduleItems(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM dlrs__LookupRollupSummaryScheduleItems__c ORDER BY CreatedDate ASC Limit 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<dlrs__LookupRollupSummaryScheduleItems__c> lstLookupRollupSummaryScheduleItems = scope;
        database.delete(lstLookupRollupSummaryScheduleItems);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_Stock_Bids());
        }
    }
}