@isTest
public class IAAI_UpdatePredictedPriceBatch_Test {
  
    
    public static testmethod void testPP(){
      
        VPE_Listings__c  v = new VPE_Listings__c();
        v.Assignment_Date__c = System.Today();
        v.Vehicle_Condition_Grade__c = 2;
        v.VIN__c = 'WDBNG75J21A174142';
        insert v;
        
        Database.executeBatch(new IAAI_UpdatePredictedPriceBatch());
        
        
    }
    
}