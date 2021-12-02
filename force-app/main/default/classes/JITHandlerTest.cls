/**
* @author LevDigital
* @date 2020
*
* @group Contact
* @group-content ../../ApexDocContent/User.htm
*
* @description  Apex coverage for JITHandler class
*/
@IsTest
private with sharing class JITHandlerTest {
    static Account acct;
    static Contact con;
    static user u;
    static Id samlSsoProviderId = '0LE000000000000';
    static Id communityId = '0DB000000000000';
    static Id portalId = '0DB000000000000';
    static String assertion = 'assertion';
    static{
        acct = TestDataFactory.createAccounts(true,1, 'Salvage')[0];
        con = TestDataFactory.createContact(true,1, new List<Account>{acct})[0];
        EnvironmentSetting__mdt ENVIRONMENT_SETTING = [select Id,Label,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName ='CommunityProfileName' LIMIT 1][0];
        u = TestDataFactory.createUser(true,'John', ENVIRONMENT_SETTING.Value__c,con.Id);
    }

    @IsTest
    static void guestUserPositive(){
        String errMsg;
        String contactId='1232135';        
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
        
        System.Test.startTest();
        JITHandler jit = new  JITHandler();
        try{
            jit.createUser( samlSsoProviderId, communityId, portalId,contactId, attributes,assertion);
        }
        Catch(Exception e){
            System.debug('error' +e);
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        Integer count = [SELECT Count() FROM User WHERE ContactId = :contactId];
        System.assertEquals(0, count,'User count in not equal to zero ' + count);
    }
    @IsTest
    static void authenticatedUserPositive(){
        String errMsg;
        
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
        System.Test.startTest();
        JITHandler jit = new  JITHandler();
        try{
            jit.updateUser(u.Id, samlSsoProviderId, communityId, portalId,con.Id, attributes,assertion);     
        }
        Catch(Exception e){
            System.debug('error' +e);
            errMsg = e.getMessage();   
        }
        System.Test.stopTest();
        Integer count = [SELECT Count() FROM User WHERE ContactId = :con.Id];
        System.assertEquals(1, count,'User count in not equal to one ' + count);
        
    }
}