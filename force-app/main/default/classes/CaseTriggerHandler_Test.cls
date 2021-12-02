@isTest
public class CaseTriggerHandler_Test {
    static testMethod void madalliaSurveyCaseCreation_Test1(){
        ID FeedbackRT_Id = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Feedback').getRecordTypeId();
        ID BuyerServicesRT_ID = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Services').getRecordTypeId();
        Case recBuyerServiceCase = new Case(Subject ='test case', RecordTypeId=BuyerServicesRT_ID, Description ='test');
        insert recBuyerServiceCase;
        Case recSurveyFeedbackCase = new case(Subject ='test case', RecordTypeId=FeedbackRT_Id, Originating_Case__c = recBuyerServiceCase.id);
        insert recSurveyFeedbackCase;
        recBuyerServiceCase.Comments = 'test';
        update recBuyerServiceCase;
        
    }
    static testMethod void caseAllTaskCompletedBeforeClosed_Test(){
        Branch__c objBranch = new Branch__c(Branch_Name__c = 'test', Branch_Number__c = '1998',phone__c='99999999');
        insert objBranch;
        contact objC = new contact(FirstName = 'Test', LastName= 'User', Branch__c = objBranch.Id, Branch_Manager__c = true);
        insert objC;
        ID BuyerAccountRT_ID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Buyer Account').getRecordTypeId();
        Account objAcc = new Account(Name ='AccountTest', recordtypeId = BuyerAccountRT_ID);
        insert objAcc;
        Contact objContact = new Contact(firstName ='Manish', LastName ='Singh', AccountId = objAcc.Id);
        insert objContact;
        //ID FeedbackRT_Id = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Feedback').getRecordTypeId();
        ID BuyerServicesRT_ID = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Services').getRecordTypeId();
        Case recBuyerServiceCase = new Case(Subject ='test case', RecordTypeId=BuyerServicesRT_ID, IsEscalated  = false, Description ='test', 
                                            Branch__c= objBranch.id, AccountId = objAcc.Id, ContactId = objContact.Id, type = 'Auction Center Support', 
                                            Reason_for_Case__c='Desktop');
        insert recBuyerServiceCase;
        Task objTaskRec = new Task(Description='test', Subject='test Subject', status = 'Not Started', 
                                   whatId = recBuyerServiceCase.id);
        insert objTaskRec;
        Task objTaskRec1 = new Task(Description='test1', Subject='test Subject1', status = 'Not Started', 
                                   whatId = recBuyerServiceCase.id);
        insert objTaskRec1;
        recBuyerServiceCase.Status = 'closed';
        update recBuyerServiceCase;
        
    }
    static testMethod void caseUpdateBranchManagerEmailEscalation_Test(){
        Branch__c objBranch = new Branch__c(Branch_Name__c = 'test', Branch_Number__c = '1998',phone__c='99999999');
        insert objBranch;
        contact objC = new contact(FirstName = 'Test', LastName= 'User', Branch__c = objBranch.Id, Branch_Manager__c = true);
        insert objC;
        ID FeedbackRT_Id = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Feedback').getRecordTypeId();
        ID BuyerServicesRT_ID = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Services').getRecordTypeId();
        Case recBuyerServiceCase = new Case(Subject ='test case', RecordTypeId=BuyerServicesRT_ID, IsEscalated  = false, Description ='test', Branch__c= objBranch.id);
        insert recBuyerServiceCase;
        recBuyerServiceCase.IsEscalated = true;
        update recBuyerServiceCase;
        string Name = CaseTriggerHandler.getRecordTypeNameById('case', BuyerServicesRT_ID);
        Case recSurveyFeedbackCase = new case(Subject ='test case', RecordTypeId=FeedbackRT_Id, Originating_Case__c = recBuyerServiceCase.id);
        insert recSurveyFeedbackCase;
        recBuyerServiceCase.Comments = 'test';
        update recBuyerServiceCase;
        
    }
    
}