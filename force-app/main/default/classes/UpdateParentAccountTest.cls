@isTest 
public class UpdateParentAccountTest 
{
    static testMethod void testMethod1() 
    {
        List<Account> lstAccount= new List<Account>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Buyer Account').getRecordTypeId();
        system.debug('-- '+RecordTypeId);
        for(Integer i=0 ;i <200;i++)
        {
            Account acc = new Account();
            acc.Name ='Name'+i;
            acc.FEIN__c = '123456'+i;
            acc.RecordTypeId = RecordTypeId;
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        
        Test.startTest();

            UpdateParentAccount obj = new UpdateParentAccount();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
 }