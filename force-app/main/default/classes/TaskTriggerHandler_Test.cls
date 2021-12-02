@isTest
public class TaskTriggerHandler_Test { 
    static testMethod void TaskTriggerHandler_Test_Test1()
    {
        
            Account objAc = new Account(Name ='test');
            insert objAc;
            contact objCon = new contact(LastName ='test', AccountId =objAc.Id );
            insert objCon;
            ID FeedbackRT_Id = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Feedback').getRecordTypeId();
            ID BuyerServicesRT_ID = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Services').getRecordTypeId();
            Case recBuyerServiceCase = new Case(AccountId = objAc.id, ContactId= objCon.Id,Subject ='test case', status = 'new', RecordTypeId=BuyerServicesRT_ID, Description ='test');
            insert recBuyerServiceCase;
            Case recBuyerServiceCase1 = new Case(AccountId = objAc.id, ContactId= objCon.Id,Subject ='test case', status = 'new', RecordTypeId=BuyerServicesRT_ID, Description ='test');
            insert recBuyerServiceCase1;
            recBuyerServiceCase.Status = 'Closed';
            update recBuyerServiceCase;
            Task objTask = new Task(Type='call', WhatId =recBuyerServiceCase.Id);
        	Database.SaveResult result = Database.insert(objTask, false);
        
        
        
        
        
             
          }
}