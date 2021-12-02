public class DELETE_Invitation implements Database.Batchable<sObject>, Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Invitation(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Invitation(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM medallia_xm__Invitation__c ORDER BY CreatedDate ASC Limit 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<medallia_xm__Invitation__c> lstInvitation = scope;
        database.delete(lstInvitation);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_LookupRollupSummaryScheduleItems());
        }
    }
}