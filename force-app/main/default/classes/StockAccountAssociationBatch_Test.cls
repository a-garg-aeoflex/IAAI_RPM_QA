@isTest
public class StockAccountAssociationBatch_Test {
    static testMethod void testMethod2(){
        Stock_bid__c stkBid = new Stock_bid__c();
        stkBid.Stock__c = 'test123';
        insert stkBid;
        
        Branch__c objBranch = new Branch__c(Phone__c = '18293819', Branch_Number__c = '2123');
        insert objBranch;
        List<Stock__c> lstStk = new List<Stock__c>();
        
        
        Stock__c stk1 = new Stock__c();
        stk1.Name = 'test123';
        stk1.Buyer_ID__c = 'BUY-5566';
        stk1.Payment_Branch_Number__c = '2123';
        lstStk.add(stk1);
        
        Stock__c stk2 = new Stock__c();
        stk2.Provider_ID__c ='PRO-1122';
        lstStk.add(stk2);
        
        Stock__c stk21 = new Stock__c();
        stk21.Provider_ID__c ='PRO-1122';
        lstStk.add(stk21);
        
        Stock__c stk11 = new Stock__c();
        stk11.Name = 'test123';
        stk11.Buyer_ID__c = 'BUY-5566';
        stk11.Payment_Branch_Number__c = '2123';
        lstStk.add(stk11);
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