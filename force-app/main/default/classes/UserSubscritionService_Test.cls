@isTest
private class UserSubscritionService_Test {
    private static testMethod void  UserSubscritionService_Test1(){
        list<User_Subcription__mdt> listA = UserSubscritionService.getSampleValue();
        
        Account objAccount = new Account();
        objAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        objAccount.Name = 'Test Account';
        objAccount.BI_ID__c = 'BRK-9327';        
        Insert objAccount;
        
        BuyerSubscrition__c obj = new BuyerSubscrition__c();
        obj.subscriptionId__c = '101';
        obj.Buyer_Id__c = '9327';
        obj.Account__c = objAccount.Id;
        insert obj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UserSubscriptionMockupCls());
        UserSubscritionService.getBuyerSubcription(objAccount.Id);
        
        Test.stopTest();
        
    }
    
}