/**
* @author LevDigital
* @date 2020
*
* @group Lead
* @group-content ../../ApexDocContent/Contact.htm
*
* @description ApexCoverage for ContactTrigger,ContactTriggerDispatcher and ContactTriggerServices
*/
@IsTest
private with sharing class ContactTriggerServicesTest {
    static final Id ASAP_INT_LOG_RECORD_TYPE_ID =  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get('ASAP_Outbound').getRecordTypeId(); 
    static List<Account> accts;
    static List<Contact> cons;
    static User integrationUser;
    static {
        integrationUser = TestDataFactory.createUser(true, 'testIntegration2323','Integration User');
        accts = TestDataFactory.createAccounts(true,2, 'Salvage');
        accts = [Select Id,Broker_Owner__c,Name FROM Account];
        cons = TestDataFactory.createContact(false,2, accts);
        cons[0].Is_Owner__c = true;
        cons[0].Email = 'test@testiia.com';
         
    }
    @IsTest
    static void UpdateBuyerContactPositive(){
        Account acct;
        Contact con;
        System.runAs(integrationUser){
            acct  = TestDataFactory.createAccounts(false,1,'buyer1',ContactTriggerDispatcher.BUYER_ACCT_RECORDTYPE_ID)[0];        
            acct.API_BUYER_Id__c = '5';
            insert acct;
            con = TestDataFactory.createContact(true,1,new List<Account>{acct},ContactTriggerDispatcher.BUYER_EMP_CONTACT_RECORDTYPE_ID)[0];
        }
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{''}
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        ContactTriggerDispatcher.ContactFirstRun = true;
        con.firstName = 'Joe';
        update con;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c, Account__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='5' 
            AND Account__c =: acct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Api').Value__c LIMIT 50000];
        System.debug('logs' + logs?.get(0));
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Contact_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @IsTest
    static void newContactPositive(){

        System.Test.startTest();
        insert cons;
        System.Test.stopTest();

        List<Contact> brokerOwnerContacts = [Select Id,Name,Broker_Partner_User__c FROM Contact Where Broker_Partner_User__c != Null];
        System.assertEquals(1, brokerOwnerContacts.size());
        User brokeroOwnerUser = [Select Id FROM User WHERE Id=: brokerOwnerContacts[0].Broker_Partner_User__c LIMIT 1][0];

    }
  @IsTest
    static void newContactFrenchPositive(){

        System.Test.startTest();
        cons[0].Language_Code__c = 'Fre ';
        insert cons;
        System.Test.stopTest();

        List<Contact> brokerOwnerContacts = [Select Id,Name,Broker_Partner_User__c FROM Contact where Id =: cons[0].Id];
        System.assertEquals(1, brokerOwnerContacts.size());
        User brokeroOwnerUser = [Select Id,LanguageLocaleKey FROM User WHERE Id=: brokerOwnerContacts[0].Broker_Partner_User__c LIMIT 1][0];
        System.assertEquals('fr',  brokeroOwnerUser.LanguageLocaleKey);
    }
    @IsTest
    static void newConsSameAccountPositive(){

        System.Test.startTest();
        cons[0].AccountId = accts[0].Id;
        cons[1].AccountId = accts[0].Id;
        cons[1].Is_Owner__c = true;
        cons[1].Email = 'test2@testiia.com';
        insert cons;
        System.Test.stopTest();

        List<Contact> brokerOwnerContacts = [Select Id,Name,Broker_Partner_User__c FROM Contact Where Broker_Partner_User__c != Null];
        System.assertEquals(2, brokerOwnerContacts.size());
    }
    @IsTest
    static void newContactsUpdateNegative(){
        System.Test.startTest();
        String errMessage;
        try{
            cons[1].Is_Owner__c = true;
            cons[1].Email = 'test@testiia.com';
            insert cons;
        }
        Catch(Exception e){
            errMessage = e.getMessage();
        }
        System.Test.stopTest();

        List<Contact> brokerOwnerContacts = [Select Id,Name,Broker_Partner_User__c FROM Contact Where Broker_Partner_User__c != Null];
        System.assertEquals(0, brokerOwnerContacts.size());
        //System.assert(errMessage != null);

    }
    @IsTest
    static void BulkInsertContactsPositive(){
        Integer count = 100;
        List<Account> brokerAccounts = TestDataFactory.createAccounts(true,count, 'Salvage');
        for(Account brokerAccount:brokerAccounts){
            brokerAccount.isPartner = true;
        }
        update brokerAccounts;
        

        System.Test.startTest();
        List<Contact> brokerContacts = TestDataFactory.createContact(false,count, brokerAccounts);
        for(Integer i=0;i<count;i++){
            brokerContacts.get(i).Is_Owner__c = true;
            brokerContacts.get(i).Email = 'test' + String.Valueof(i) + '@testiia.com';
        }
        insert brokerContacts;
        System.Test.stopTest();

        List<Contact> brokerOwnerContacts = [Select Id,Name,Broker_Partner_User__c FROM Contact Where Broker_Partner_User__c != Null];
        System.assertEquals(count, brokerOwnerContacts.size());
    }
    @IsTest
    static void BulkUpdateContactsPositive(){
        Integer count = 200;
        List<Account> buyerAccounts;
        List<Contact> buyerContacts;
        System.runAs(integrationUser){
           
            buyerAccounts = TestDataFactory.createAccounts(true,count,'Buyer Account',ContactTriggerDispatcher.BUYER_ACCT_RECORDTYPE_ID);        
            System.debug(' buyerAccounts:' +  buyerAccounts.size());
            buyerContacts = TestDataFactory.createContact(true,count,buyerAccounts,ContactTriggerDispatcher.BUYER_EMP_CONTACT_RECORDTYPE_ID);
        }
        for(Integer i=0;i<count;i++){
            buyerContacts.get(i).firstName = 'Joe';
        }
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{''}
        };
        MultiMockUtility mck = new MultiMockUtility(); 
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
   
        ContactTriggerDispatcher.ContactFirstRun = true;
        System.Test.startTest();
        
        update buyerContacts;
        System.Test.stopTest();
        System.assertEquals(count, [SELECT COUNT() FROM Contact WHERE Id IN:buyerContacts AND FirstName='Joe' LIMIT 50000],'Integration logs do not equal 0');
        //Logs should be 0 since BSO APIs don't run in bulk mode
        System.assertEquals(0, [SELECT COUNT() FROM Integration_logs__c LIMIT 50000],'Integration logs do not equal 0');
    }
}