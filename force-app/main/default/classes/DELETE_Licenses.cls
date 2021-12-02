public class DELETE_Licenses implements Database.Batchable<sObject>, Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Licenses(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Licenses(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM License__c ORDER BY CreatedDate ASC Limit 50000 ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<License__c> lstLicense = scope;
        database.delete(lstLicense);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_Email_Messages());
        }
    }
    
}