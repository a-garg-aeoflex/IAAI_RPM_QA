/*
* @author LevDigital
* @date 2021
*
* @group ASAP_Note__c
* @group-content ../../ApexDocContent/ASAP_Note__c.htm
*
* @description ASAPNoteService is called from the ASAPNoteTriggerHelper
*/
@Istest
public with sharing class ASAPNoteTriggerHelperTest {
    static Account buyerAcct;
    static Contact buyerCon;
    static User integrationUser;
    static final Id BUYER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    static final Id ASAP_INT_LOG_RECORD_TYPE_ID =  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get('ASAP_Outbound').getRecordTypeId(); 
    static {     

        integrationUser = TestDataFactory.createUser(true, 'testIntegration2323','Integration User');
        System.runAs(integrationUser){          
            buyerAcct = TestDataFactory.createAccounts(false,1, 'John Buyer', BUYER_ACCOUNT_RECORD_TYPE_ID)[0];  
            buyerAcct.API_BUYER_Id__c = '5';
            insert buyerAcct;
            buyerCon = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerCon.Buyer_Employee_ID__c = '98765';
            insert buyerCon;
        }
    }

    @Istest
    static void createNotePositive() {
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '"2021-04-20T17:26:24.583"'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);     
       
        System.Test.startTest();
        ASAP_Note__c asapNote = new  ASAP_Note__c
        (Account__c =buyerAcct.Id, Contact__c = buyerCon.Id, Ext_Date_Time_Created__c = System.Now(),Note_Details__c = 'Registration failed');
        insert asapNote;        
        System.Test.stopTest();
        System.assertEquals(1,[SELECT COUNT() FROM ASAP_Note__c WHERE Id=:asapNote.Id 
                                    AND Account__c=:buyerAcct.Id AND Contact__c =:buyerCon.Id AND ASAP_Id__c !=null]);
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='5' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c LIMIT 50000];
        System.debug('logs' + logs?.get(0));
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Note_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @Istest
    static void createNoteNoContactPositive() {
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '"2021-04-20T17:26:24.583"'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);     
       
        System.Test.startTest();
        ASAP_Note__c asapNote = new  ASAP_Note__c
        (Account__c =buyerAcct.Id, Ext_Date_Time_Created__c = System.Now(),Note_Details__c = 'Registration failed');
        insert asapNote;        
        System.Test.stopTest();
        System.assertEquals(1,[SELECT COUNT() FROM ASAP_Note__c WHERE Id=:asapNote.Id AND Contact__c =null AND ASAP_Id__c !=null]);

        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
        AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='5' 
        AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Note_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @Istest
    static void createNoteNoCreatedDateTime() {
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                ''
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);     
    
        System.Test.startTest();
        ASAP_Note__c asapNote = new  ASAP_Note__c
        (Account__c =buyerAcct.Id, Ext_Date_Time_Created__c = System.Now(),Note_Details__c = 'Registration failed');
        insert asapNote;        
        System.Test.stopTest();
        System.assertEquals(0,[SELECT COUNT() FROM ASAP_Note__c WHERE Id=:asapNote.Id AND ASAP_Id__c !=null]);

        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
        AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='5' 
        AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());
    }
    @Istest
    static void createNoteNegative() {
        List<List<String>> respList = new List<List<String>>{       
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            },
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);     
       
        System.Test.startTest();
        ASAP_Note__c asapNote = new ASAP_Note__c
        (Account__c =buyerAcct.Id, Contact__c = buyerCon.Id, Ext_Date_Time_Created__c = System.Now(),Note_Details__c = 'Registration failed');
        insert asapNote;        
        System.Test.stopTest();
        System.assertEquals(0,[SELECT COUNT() FROM ASAP_Note__c WHERE Id=:asapNote.Id AND ASAP_Id__c !=null]);

        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c 
            WHERE Status__c='Failed' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='5' 
        AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());    
        System.debug('logs' + logs?.get(0));
       
    }
}