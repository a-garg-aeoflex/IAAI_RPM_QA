global class IntegrationLogCleanupBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<String> transactionTypes = new List<String>();
        for(Transaction_Type_Setting__mdt tts : [ SELECT Id, Type__c, MasterLabel FROM Transaction_Type_Setting__mdt WHERE Type__c = 'IntegrationLogCleanup']){
            transactionTypes.add(tts.MasterLabel);
        }
        
        EnvironmentSetting__mdt envSetting = EnvironmentSetting__mdt.getInstance('IntegrationLogCleanup_Days_to_Delete');
        
        string query = 'SELECT Id FROM Integration_logs__c WHERE CreatedDate != LAST_N_DAYS:' + envSetting.Value__c + ' AND Transaction_Type__c in :transactionTypes';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Integration_logs__c> logs)
    {
        if(logs.size() > 0){
            delete logs;
        }
        
    }

    global void finish(Database.BatchableContext BC)
    {

    }


    //Scheduler - execute
    global void execute(SchedulableContext ctx)
    {
        IntegrationLogCleanupBatch b = new IntegrationLogCleanupBatch();
        database.executebatch(b);
    }
}