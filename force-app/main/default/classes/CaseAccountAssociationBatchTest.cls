@isTest
public class CaseAccountAssociationBatchTest{

    static testMethod void testMethod1(){
    
        Id KarBSCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KAR BS Case').getRecordTypeId(); 
            
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
        
        
        List<Case> lstCase = new List<Case>();
        
        Case case1 = new Case();        
        case1.BI_ID__c ='BUY-5566'; 
        case1.recordtypeId = KarBSCaseRecTypeId;        
        lstCase.add(case1);
        
        
        Case case2 = new Case();        
        case2.BI_ID__c ='PRO-1122';
        case2.recordtypeId = KarBSCaseRecTypeId;
        lstCase.add(case2);
        
        Insert lstCase;
        
        
        

        CaseAccountAssociationBatch  testcase = new CaseAccountAssociationBatch ();
        database.executebatch(testcase);

    }
}