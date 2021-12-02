public class DELETE_VPE_Listing implements Database.Batchable<sObject> , Database.Stateful{
    private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_VPE_Listing(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_VPE_Listing(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM VPE_Listings__c ORDER BY CreatedDate ASC Limit '+LimitSize;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<VPE_Listings__c> lstIntegrationlogs = scope;
        database.delete(lstIntegrationlogs);
    }
    public void finish(Database.BatchableContext BC){
               
    }
}