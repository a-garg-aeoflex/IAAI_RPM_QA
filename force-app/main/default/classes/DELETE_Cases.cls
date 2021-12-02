public class DELETE_Cases implements Database.Batchable<sObject>, Database.Stateful {
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Cases(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Cases(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Case ORDER BY CreatedDate ASC Limit 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Case> lstCase = scope;
        database.delete(lstCase);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_Tasks());
        }
    }
    
}