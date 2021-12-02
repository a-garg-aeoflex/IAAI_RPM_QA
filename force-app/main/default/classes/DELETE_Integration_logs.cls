public class DELETE_Integration_logs implements Database.Batchable<sObject> , Database.Stateful{
     private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Integration_logs(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Integration_logs(){}     
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Integration_logs__c ORDER BY CreatedDate ASC Limit '+LimitSize;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Integration_logs__c> lstIntegrationlogs = scope;
        database.delete(lstIntegrationlogs);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_VPE_Listing());
        }
        
    }
}