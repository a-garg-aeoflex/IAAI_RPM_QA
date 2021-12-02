@isTest
private class ContactAccountRelationCreationBatch_Test {

    static testMethod void AccConRel(){
        Id IAA_AccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Account').getRecordTypeId();
        Account objAcc = new Account(Name ='Test Account', RecordTypeId = IAA_AccId, BI_Id__c = '112123');
        Insert objAcc;
        Contact objCon = new Contact(LastName = 'SiTest', AccountId = objAcc.Id);
        insert objCon;
        /*AccountContactRelation objACR = new AccountContactRelation(AccountId =objAcc.Id, ContactId = objCon.Id );
        Insert objACR;*/
        Test.startTest();
        	
                database.executeBatch(new ContactAccountRelationCreationBatch());
        Test.stopTest();
        
    }
     static testMethod void AccConRel1(){
        Id IAA_AccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        Account objAcc = new Account(Name ='Test Account', RecordTypeId = IAA_AccId, BI_Id__c = '112123');
        Insert objAcc;
        Contact objCon = new Contact(LastName = 'SiTest', AccountId = objAcc.Id);
        insert objCon;
        /*AccountContactRelation objACR = new AccountContactRelation(AccountId =objAcc.Id, ContactId = objCon.Id );
        Insert objACR;*/
        Test.startTest();
        	
                database.executeBatch(new ContactAccountRelationCreationBatch());
        Test.stopTest();
        
    }
     static testMethod void AccConRel2(){
        Id IAA_AccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Buyer Account').getRecordTypeId();
        Account objAcc = new Account(Name ='Test Account', RecordTypeId = IAA_AccId, BI_Id__c = '112123');
        Insert objAcc;
        Contact objCon = new Contact(LastName = 'SiTest', AccountId = objAcc.Id);
        insert objCon;
        /*AccountContactRelation objACR = new AccountContactRelation(AccountId =objAcc.Id, ContactId = objCon.Id );
        Insert objACR;*/
        Test.startTest();
        	
                database.executeBatch(new ContactAccountRelationCreationBatch());
        Test.stopTest();
        
    }
}