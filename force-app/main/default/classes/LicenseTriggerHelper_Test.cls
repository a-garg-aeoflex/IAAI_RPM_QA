@isTest
private class LicenseTriggerHelper_Test {
    @isTest
    private static void LicenseTriggerHelper1(){
        Account obj = new Account(Name ='test12', BI_ID__c = '12345');
        insert obj;
        Account obj1 = new Account(Name ='test12', BI_ID__c = 'BUY-123456');
        insert obj1;
        License__c objLi =new License__c(Buyer_Id__c = '12345');
        insert objLi;
        License__c objLi1 =new License__c(Buyer_Id__c = 'BUY-123456');
        insert objLi1;
        License__c objLi2 = new License__c(Buyer_Id__c = 'BUY-12345');
        insert objLi2;
    }
    
}