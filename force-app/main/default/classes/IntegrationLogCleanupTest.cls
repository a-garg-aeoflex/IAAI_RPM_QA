@isTest
public class IntegrationLogCleanupTest {
    @isTest static void shouldDeleteLogs(){
        TestDataFactory.createIntegrationLogs(true, 5, 'UPLOAD_LICENSE');
        List<Integration_logs__c> logsRemaining = [SELECT Id FROM Integration_Logs__c];
        for(Integration_logs__c log : logsRemaining){
            Test.setCreatedDate(log.Id, Datetime.now().addDays(-100));
        }

        Test.startTest();
        ID BatchProcessdId = Database.executeBatch(new IntegrationLogCleanupBatch());
        Test.stopTest();

        logsRemaining = [SELECT Id FROM Integration_Logs__c];
        System.assert(logsRemaining.size() == 0);
    }

    @isTest static void shouldDeleteLogsBulk(){
        TestDataFactory.createIntegrationLogs(true, 50, 'GET_LEXIS_NEXIS_CHECK');
        TestDataFactory.createIntegrationLogs(true, 50, 'UPLOAD_LICENSE');
        TestDataFactory.createIntegrationLogs(true, 50, 'UPDATE_EMPLOYEE_DOCUMENT');
        TestDataFactory.createIntegrationLogs(true, 50, 'Incoming Service Event');

        List<Integration_logs__c> logsRemaining = [SELECT Id FROM Integration_Logs__c];
        for(Integration_logs__c log : logsRemaining){
            Test.setCreatedDate(log.Id, Datetime.now().addDays(-100));
        }

        Test.startTest();
        ID BatchProcessdId = Database.executeBatch(new IntegrationLogCleanupBatch());
        Test.stopTest();

        logsRemaining = [SELECT Id FROM Integration_Logs__c];
        System.assert(logsRemaining.size() == 0);
    }


    @isTest static void shouldDeleteLogsNegative(){
        TestDataFactory.createIntegrationLogs(true, 5, 'Invalid Type!');

        List<Integration_logs__c> logsRemaining = [SELECT Id FROM Integration_Logs__c];
        for(Integration_logs__c log : logsRemaining){
            Test.setCreatedDate(log.Id, Datetime.now().addDays(-100));
        }

        Test.startTest();
        ID BatchProcessdId = Database.executeBatch(new IntegrationLogCleanupBatch());
        Test.stopTest();

        logsRemaining = [SELECT Id FROM Integration_Logs__c];
        System.assert(logsRemaining.size() != 0);
        System.assert(logsRemaining.size() == 5);
    }

    @isTest static void shouldDeleteWithinTimeFrame(){
        TestDataFactory.createIntegrationLogs(true, 5, 'GET_LEXIS_NEXIS_CHECK');
        TestDataFactory.createIntegrationLogs(true, 5, 'UPLOAD_LICENSE');
        TestDataFactory.createIntegrationLogs(true, 5, 'UPDATE_EMPLOYEE_DOCUMENT');
        TestDataFactory.createIntegrationLogs(true, 5, 'Incoming Service Event');
        List<Integration_logs__c> logsRemaining = [SELECT Id FROM Integration_Logs__c WHERE Transaction_Type__c = 'UPLOAD_LICENSE'];
        for(Integration_logs__c log : logsRemaining){
            Test.setCreatedDate(log.Id, Datetime.now().addDays(-100));
        }
        logsRemaining = [SELECT Id FROM Integration_Logs__c];
        System.assert(logsRemaining.size() == 20);

        Test.startTest();
        ID BatchProcessdId = Database.executeBatch(new IntegrationLogCleanupBatch());
        Test.stopTest();

        logsRemaining = [SELECT Id FROM Integration_Logs__c];
        System.assert(logsRemaining.size() == 15);
    }

    @isTest static void shouldScheduleJob(){       
        Test.startTest();
        IntegrationLogCleanupBatch cleanupJob = new IntegrationLogCleanupBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, cleanupJob);
        Test.stopTest();
   }
}