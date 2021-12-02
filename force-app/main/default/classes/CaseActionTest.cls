/*
* @author LevDigital
* @date 2021
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Apex coverage for CaseAction class
*
*/
@IsTest
private with sharing class CaseActionTest {
    static Account buyerAcct;
    static Contact buyerCon;
    static User integrationUser;
    static final Id BUYER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    static CaseAction.CaseActionInputs caseInputserviceEvent;
    static {     
        integrationUser = TestDataFactory.createUser(true, 'testIntegration23235','Integration User');
        System.runAs(integrationUser){
            buyerAcct = TestDataFactory.createAccounts(false,1, 'John Buyer', BUYER_ACCOUNT_RECORD_TYPE_ID)[0];  
            buyerAcct.AuthUserKey__c = '12345';
            insert buyerAcct; 
            buyerCon = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerCon.AuthUserKey__c ='12345';
            insert buyerCon;
        }
        caseInputserviceEvent = new CaseAction.CaseActionInputs();       
        caseInputserviceEvent.caseType= 'Payment Review';
        caseInputserviceEvent.existingServiceEventName = 'buyercreated';
    }
    @IsTest 
    static void ServiceEventCCPositive(){
        
        System.Test.startTest();
        Service_Event__c serviceEvent = TestDataFactory.createServiceEvents(true,1,buyerAcct.Id,'creditcardpayment')[0];
        caseInputserviceEvent.serviceEvent = serviceEvent;
        List<String> errorMsgs = CaseAction.createNewCase(new List<CaseAction.CaseActionInputs>{caseInputserviceEvent});
        System.Test.stopTest();
        System.assert([SELECT COUNT() FROM CASE WHERE ContactId =:buyerCon.Id] > 0,'Case count incorrect');
    }
    @IsTest 
    static void ServiceEventPPalPositive(){
        
        System.Test.startTest();
        Service_Event__c serviceEvent =TestDataFactory.createServiceEvents(true,1,buyerAcct.Id,'paypalpayment')[0];
        caseInputserviceEvent.serviceEvent = serviceEvent;
        List<String> errorMsgs = CaseAction.createNewCase(new List<CaseAction.CaseActionInputs>{caseInputserviceEvent});
        System.Test.stopTest();
        System.assert([SELECT COUNT() FROM CASE WHERE ContactId =:buyerCon.Id] > 0,'Case count incorrect');
    }
    @IsTest 
    static void ServiceEventNegative(){
        
        System.Test.startTest();       
        Service_Event__c serviceEvent =TestDataFactory.createServiceEvents(true,1,buyerAcct.Id,'paypalpayment')[0]; 
        caseInputserviceEvent.serviceEvent = serviceEvent;
        CaseAction.hasError = true;
        List<String> errorMsgs = CaseAction.createNewCase(new List<CaseAction.CaseActionInputs>{caseInputserviceEvent});
        System.Test.stopTest();
        System.assert([SELECT COUNT() FROM CASE WHERE ContactId =:buyerCon.Id] ==1,'Case count incorrect');
    }
    @IsTest 
    static void ServiceEventPPalNoCasePositive(){
        Service_Event__c serviceEventCreated =TestDataFactory.createServiceEvents(true,1,buyerAcct.Id,'buyercreated')[0];
        System.Test.startTest();
        Service_Event__c serviceEvent =TestDataFactory.createServiceEvents(true,1,buyerAcct.Id,'paypalpayment')[0];
        System.Test.stopTest();
        System.assert([SELECT COUNT() FROM CASE WHERE ContactId =:buyerCon.Id]  ==0,'Case count incorrect');
    }
}