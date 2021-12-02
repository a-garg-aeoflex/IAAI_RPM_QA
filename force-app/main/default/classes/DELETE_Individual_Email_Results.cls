global class  DELETE_Individual_Email_Results implements Database.Batchable<sObject>, Database.Stateful{
    
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Individual_Email_Results(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Individual_Email_Results(){}   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM et4ae5__IndividualEmailResult__c ORDER BY CreatedDate ASC LIMIT 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<et4ae5__IndividualEmailResult__c> IndividualEmailResult = scope;
        database.delete(IndividualEmailResult);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            Database.executeBatch(new DELETE_Stocks());
        }
    }
    
}