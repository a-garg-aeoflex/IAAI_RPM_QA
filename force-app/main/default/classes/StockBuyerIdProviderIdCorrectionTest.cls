@isTest
public class StockBuyerIdProviderIdCorrectionTest{

    static testMethod void testMethod1(){
        List<Stock__c> lstStk = new List<Stock__c>();
        
        Stock__c stk1 = new Stock__c();
        stk1.Buyer_ID__c = '5566';    
        lstStk.add(stk1);
     
        Stock__c stk2 = new Stock__c();
        stk2.Provider_ID__c ='1122';
        lstStk.add(stk2);

        Insert lstStk;
        

        StockBuyerIdProviderIdCorrectionBatch  teststock = new StockBuyerIdProviderIdCorrectionBatch ();
        database.executebatch(teststock);

    }
    
    static testMethod void testMethod2(){
        List<Stock__c> lstStk = new List<Stock__c>();
        
        Stock__c stk1 = new Stock__c();
        stk1.Buyer_ID__c = 'BUY-5566';    
        lstStk.add(stk1);
     
        Stock__c stk2 = new Stock__c();
        stk2.Provider_ID__c ='PRO-1122';
        lstStk.add(stk2);

        Insert lstStk;
        
        List<Account> lstAcc = new List<Account>();
        Account acc1 = new Account();
        acc1.Name= 'test1';
        acc1.BI_ID__c ='BUY-5566';
        
        lstAcc.add(acc1);
        
        
        Account acc2 = new Account();
        acc2.Name= 'test2';
        acc2.BI_ID__c ='PRO-1122';
        lstAcc.add(acc2);
        
        Insert lstAcc;
        
        

        StockAccountAssociationBatch   teststock = new StockAccountAssociationBatch  ();
        database.executebatch(teststock);

    }
}