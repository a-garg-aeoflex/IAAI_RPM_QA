@isTest
public class DELETE_Licenses_Test {
    
    @isTest
    public static void DELETE_Licenses_Test_Method1(){
        List<License__c> lstIDER = new List<License__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            License__c obj = new License__c();
            obj.Buyer_ID__c = 'BUY-12222'; 
			
			lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
        DELETE_Licenses obj = new DELETE_Licenses(50,true ); 
        DELETE_Licenses obj1 = new DELETE_Licenses();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}