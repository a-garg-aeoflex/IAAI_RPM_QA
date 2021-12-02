/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/License__c.htm
*
* @description LicenseServiceTest apex coverage for LicenseService
*/

@IsTest
private with sharing class LicenseServiceTest {
    static Account buyerAcct;
    static Contact buyerCon;
    static final Id BUYER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    static final Id ASAP_INT_LOG_RECORD_TYPE_ID =  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get('ASAP_Outbound').getRecordTypeId(); 
    static User integrationUser;
    static {
        integrationUser = TestDataFactory.createUser(true, 'testIntegration2323','Integration User');
        System.runAs(integrationUser){
            buyerAcct = TestDataFactory.createAccounts(false,1, 'John Buyer', BUYER_ACCOUNT_RECORD_TYPE_ID)[0];  
            buyerAcct.API_Buyer_Id__c = '12345';
            insert buyerAcct;
            buyerCon = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerCon.Buyer_Employee_ID__c = '98765';
            insert buyerCon;
        }
    }
    @IsTest
    static void insertOneLicPositive(){

        List<List<String>> respList = new List<List<String>>{                
            new List<String>{'[5751238]'}
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        insert buyerLic;
        System.Test.stopTest();
        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id AND ASAP_License_Id__c = '5751238'],'License do not get created.');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_License_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);

    }
    @IsTest
    static void insertOneLicRetryPositive(){

        List<List<String>> respList = new List<List<String>>{  
            new List<String>{'','500'},              
            new List<String>{'[5751238]'}
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        insert buyerLic;
        System.Test.stopTest();
        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id AND ASAP_License_Id__c = '5751238'],'License do not get created.');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_License_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);

    }
    @IsTest
    static void insertLicFiveHundredNegative(){

        List<List<String>> respList = new List<List<String>>{                
            new List<String>{'','500'},
            new List<String>{'','500'}
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        insert buyerLic;
        System.Test.stopTest();
        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id],'License do not get created.');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Failed' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());   

    }
    @IsTest
    static void insertUpdateOneLicPositive(){

        List<List<String>> respList = new List<List<String>>{                
            new List<String>{
                '[5751238]'
            },
            new List<String>{
                '[5751238]'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        
        System.Test.setMock(HttpCalloutMock.class, mck);
        insert buyerLic;
        System.Test.startTest();
        LicenseTriggerHelper.licenseFirstRun = true;
        update buyerLic;
        System.Test.stopTest();
        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id AND ASAP_License_Id__c = '5751238'],'License do not get created.');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_License_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }

    @IsTest
    static void ShouldDeleteLicenseFilePositive(){

        List<List<String>> respList = new List<List<String>>{                
            new List<String>{'[5751238]'}
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        System.Test.setMock(HttpCalloutMock.class, mck);
        LicenseTriggerHelper.licenseFirstRun = false;
        insert buyerLic;

        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id],'License do not get created.');
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, buyerLic.Id)}; 
        Test.startTest();
        insert docLinks;
        Test.stopTest();
        
    
        List<ContentDocumentLink> existingDocuments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :buyerLic.Id];
        System.assert(existingDocuments.size() == 0);
    }

    @IsTest
    static void ShouldDeleteLicenseFileNegative(){

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
        License__c buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
        System.Test.setMock(HttpCalloutMock.class, mck);
        LicenseTriggerHelper.licenseFirstRun = false;
        insert buyerLic;

        System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id],'License do not get created.');
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, buyerLic.Id)}; 
        Test.startTest();
        insert docLinks;
        Test.stopTest();
        
    
        List<ContentDocumentLink> existingDocuments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :buyerLic.Id];
        System.assert(existingDocuments.size() == 0);
    }



    
}