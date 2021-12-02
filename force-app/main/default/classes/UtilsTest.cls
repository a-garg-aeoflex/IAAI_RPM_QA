/*
* @author LevDigital
* @date 2020
*
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
*
* @description Apex coverage for Utils Class
*
*/
@IsTest
private with sharing class UtilsTest {
    static Account acct;
    static Contact con;
    static user u;
    static String assertion = 'assertion';
    static{
        acct = TestDataFactory.createAccounts(false,1, 'Salvage')[0];
        acct.BI_ID__c = '12123';
        acct.Buyer_Status__c= 'Pending Activation';
        insert acct;
        con = TestDataFactory.createContact(true,1, new List<Account>{acct})[0];
        EnvironmentSetting__mdt ENVIRONMENT_SETTING = [select Id,Label,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName ='CommunityProfileName' LIMIT 1][0];
        u = TestDataFactory.createUser(false,'John345345', ENVIRONMENT_SETTING.Value__c,con.Id);
        u.FirstName = 'test4574557';
        u.Phone = '123212321';
        insert u;
    }

    @IsTest
    static void encryptDecryptSuccess(){
        System.Test.startTest();
        String valueToEncrypt = 'My voice is my passport verify me.';
        String encrypted =  Utils.encrypt(valueToEncrypt);
        string decrypted = Utils.decrypt(encrypted);
        System.assertEquals(valueToEncrypt, decrypted);
        System.Test.stopTest();
    }
    @IsTest
    static void encryptDecryptAttributesSuccess(){
        System.Test.startTest();
        Map<String, String> attributes = new Map<String, String> {
            'Email' => 'test@test.com',
            'Firstname' => 'John',
            'LastName' => 'Doe',
            'LanguagePreference' => 'en-US',
            'PhoneNumber' => '1234564569',
            'Usertype' => 'test',
            'login' => 'test@test.com',
            'BuyerID' => '123213'
        };
        String encrypted =  Utils.setParms(JSON.serialize(attributes));
        List<Utils.Options> opts  =Utils.getParms(new List<String>{'Email','LastName'}, encrypted);
        System.assert(opts.size() >0,'Attributes are equal to zero ');
        System.Test.stopTest();
    }
    @IsTest
    static void loggedInUserAttributesPositive(){
        System.Test.startTest();
        System.runAs(u){
            List<Utils.Options> opts  =Utils.getLoggedONInfo(new List<String>{'Email','LastName','Firstname','PhoneNumber','BrokerId'});
            System.assert(opts.size() >0,'Attributes are equal to zero ');
        }        
        System.Test.stopTest();
    }
    @IsTest
    static void createIntegrationLogPositive(){
        System.Test.startTest();
        Integration_logs__c log = Utils.createIntegrationLog('{}','{}','Integration',true);
        System.Test.stopTest();
        System.assert(log != null,'Integration Log is null');

        
    }
    @IsTest
    static void returnTypePositive(){
        String temp ='test';
        Integer i =1;
        Double dbl =1.1;
        Decimal dec =1.1;
        System.Test.startTest();
        System.AssertEquals('String', utils.returnType(temp));
        System.AssertEquals('Integer',utils.returnType(i));
        System.AssertEquals('Double' ,utils.returnType(dbl));
        System.AssertEquals('List<Object>',utils.returnType(new List<String>{'test'}));
        System.AssertEquals('Date',utils.returnType(System.Today()));
        System.AssertEquals('DateTime',utils.returnType(System.Now()));
        System.Test.stopTest();
    }
    @IsTest
    static void ChangeDateTimeOffsetPostive(){
        System.runAs(u){
            System.Test.startTest();
            DateTime changedUpDt =Utils.ChangeDateTimeOffset('2020-10-15T09:03:04', 'America/Chicago');        
            System.Test.stopTest();
            System.assertEquals('10/15/2020 09:03:04',changedUpDt.format('MM/dd/yyyy HH:mm:ss'));             
        }
    }
    @IsTest
    static void DMLDeleteHelperListPositive(){
        System.Test.startTest();
        Contact conn = new Contact(firstName = 'John',lastName = 'Smith');
        insert conn;
        String errMsg = Utils.DMLDeleteHelperList(new List<Contact>{ conn}, 'deleted contact' + conn.Id);
        System.Test.stopTest();
        System.assert(String.isBlank(errMsg),'Error message is not blank: ' + errMsg);
    }
    @IsTest
    static void DMLDeleteHelperListNegative(){
        String errMsg;
        System.Test.startTest();
        try{
           Utils.DMLDeleteHelperList(new List<Contact>{ con}, 'deleted contact' + con.Id);
        }
        Catch(Exception e){
            system.debug('Error: ' + e.getMessage());
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assert(String.isNotBlank(errMsg),'Error message is not blank: ' + errMsg);
    }
    @IsTest
    static void UpsertsObjectsPositive(){
        
        List<Contact> upsertContacts = TestDataFactory.createContact(false,1, new List<Account>{acct});
        upsertContacts[0].AC_User_ID__c = '123';
        Schema.SObjectField f = Contact.Fields.AC_User_ID__c;
        System.Test.startTest();
        Utils.upsertRecords(upsertContacts,'Contact', f);
        System.Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM Contact WHERE AC_User_ID__c IN('123')]);

        
    }
}