/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/ContentDocumentLink.htm
*
* @description Apex coverage for ContentDocumentLinkTrigger and ContentDocumentLinkHandler
*/
@IsTest
private with sharing class ContentDocumentLinkHandlerTest {
    static Account buyerAcct;
    static Contact buyerCon;
    static License__c buyerLic;
    static final Id BUYER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    static Id BUYER_EMP_CONTACT_RECORDTYPE_ID =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Buyer_Employees').getRecordTypeId();
    static final Id ASAP_INT_LOG_RECORD_TYPE_ID =  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get('ASAP_Outbound').getRecordTypeId(); 
    static List<Account> accts;   
    static User integrationUser;           
    static {
        integrationUser = TestDataFactory.createUser(true, 'testIntegration2323','Integration User');
        System.runAs(integrationUser){
            buyerAcct = TestDataFactory.createAccounts(false,1, 'John Buyer', BUYER_ACCOUNT_RECORD_TYPE_ID)[0];  
            buyerAcct.API_Buyer_Id__c = '12345';        
            insert buyerAcct;        
            buyerCon = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct},BUYER_EMP_CONTACT_RECORDTYPE_ID)[0];
            buyerCon.Buyer_Employee_ID__c = '98765';
            insert buyerCon;
            buyerLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
            LicenseTriggerHelper.licenseFirstRun= false; 
            insert buyerLic;
            System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyerLic.Id],'License do not get created.');
        }
    }
    @IsTest
    static void AddOneLiczFileAttPositive(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                '[5751238]'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        ContentDocumentLink docLink = TestDataFactory.createAttachment(true, buyerLic.Id);   
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_License_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @IsTest
    static void AddOneLiczFileAttNegative(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                '[0]'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        ContentDocumentLink docLink = TestDataFactory.createAttachment(true, buyerLic.Id);   
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Failed' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c LIMIT 50000
        ];
        System.debug('log' + logs[0]);
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());    
    }
    @IsTest
    static void AddLiczFileFiveHundredNegative(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                '','500'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        ContentDocumentLink docLink = TestDataFactory.createAttachment(true, buyerLic.Id);   
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,License__c FROM Integration_logs__c 
            WHERE Status__c='Failed' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c LIMIT 50000
        ];
            System.debug('log' + logs[0]);
            System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size()); 
    }
    @IsTest
    static void AddConBuyerTwoAttsPositive(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                'true'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, buyerCon.Id),TestDataFactory.createAttachment(false, buyerCon.Id)}; 
        Integer count=0;
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink 
                                        WHERE LinkedEntityId =:buyerCon.Id] )  {
                    count++;        
        } 
        System.assertEquals(0, 0);
        System.Test.startTest();
        insert docLinks;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,Transaction_Type__c FROM Integration_logs__c 
            WHERE Status__c='Failed' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Contact__c =: buyerCon.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c LIMIT 50000
        ];
        System.debug('logs1: ' + logs?.get(0));
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(ContactService.ADDED_MORE_THAN_ONE_DOC_ON_CONTACT,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @IsTest
    static void AddConBrokerAttsPositive(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                'true'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact con;
        System.runAs(integrationUser){
            Id brokerEmpRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker_Employee').getRecordTypeId();
            con = TestDataFactory.createContact(true,1, new List<Account>{ buyerAcct},brokerEmpRecordTypeId)[0];
        }
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, con.Id)};
        System.Test.startTest();
        insert docLinks;
        System.Test.stopTest();
        Integer count=0;       
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,Transaction_Type__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Contact__c =:con.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c LIMIT 50000
        ];
        System.debug('logs1: ' + logs?.get(0));
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Contact_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }

    @IsTest
    static void ShouldAddDocumentPositive(){
        List<List<String>> respList = new List<List<String>>{
            new List<String>{
                'true'
            }
        };      
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact con;
        System.runAs(integrationUser){
            Id brokerEmpRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker_Employee').getRecordTypeId();
            con = TestDataFactory.createContact(true,1, new List<Account>{ buyerAcct},brokerEmpRecordTypeId)[0];
        }
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, con.Id)};
        System.Test.startTest();
        insert docLinks;
        System.Test.stopTest();
        Integer count=0;       
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,Transaction_Type__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Contact__c =:con.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c LIMIT 50000
        ];
       List<ContentDocumentLink> existingDocuments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :con.Id];
       System.assert(existingDocuments.size() == 0);
       
    }


    @IsTest
    static void ShouldAddDocumentNegative(){
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
        Contact con;
        System.runAs(integrationUser){
            Id brokerEmpRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker_Employee').getRecordTypeId();
            con = TestDataFactory.createContact(true,1, new List<Account>{ buyerAcct},brokerEmpRecordTypeId)[0];
        }
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>{TestDataFactory.createAttachment(false, con.Id)};
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, mck);
        insert docLinks;
        System.Test.stopTest();
        Integer count=0;       
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c,Contact__c,Transaction_Type__c FROM Integration_logs__c 
            WHERE Status__c='Success' AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Contact__c =:con.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c LIMIT 50000
        ];
       List<ContentDocumentLink> existingDocuments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :con.Id];
       System.assert(existingDocuments.size() == 0);
    }

}