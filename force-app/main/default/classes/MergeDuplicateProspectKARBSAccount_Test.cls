@isTest
private class MergeDuplicateProspectKARBSAccount_Test {
    @isTest static void mergeDuplicates(){  
        Id propectAccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        Id karBSAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KAR BS Account').getRecordTypeId();
        Account objAcc = new Account(Name = 'Test Account1',
                                     BillingState='Test Billing State', 
                                     BillingCity='Test Billing City', 
                                     Phone='1001001234', 
                                     KAR_ID__c = '1001001',
                                     RecordTypeId = propectAccountRecordTypeId);
        insert objAcc;
        Account objAccBuyer = new Account(Name = 'Test Account1',
                                     BillingState='Test Billing State', 
                                     BillingCity='Test Billing City', 
                                     Phone='1001001234', 
                                     KAR_ID__c = '1001001',
                                     RecordTypeId = karBSAccountRecordTypeId);
        insert objAccBuyer;
        Account objAccBuyer1 = new Account(Name = 'Test Account1',
                                     BillingState='Test Billing State', 
                                     BillingCity='Test Billing City', 
                                     Phone='1001001234', 
                                     KAR_ID__c = '1001001',
                                     RecordTypeId = karBSAccountRecordTypeId);
        insert objAccBuyer1;
        Test.startTest();
        MergeDuplicateProspectKARBSAccount objMerDupPro = new MergeDuplicateProspectKARBSAccount();
        database.executeBatch(objMerDupPro);
        Test.stopTest();
    }
}