@isTest
public class DELETE_Invitation_Test {
    
    @isTest
    public static void DELETE_Invitation_Test_Method1(){
        List<medallia_xm__Invitation__c> lstIDER = new List<medallia_xm__Invitation__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            
			 medallia_xm__Invitation__c obj = new medallia_xm__Invitation__c();
            obj.medallia_xm__Invitation_Payload__c = 'test'+i;
            
            
            lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Invitation obj = new DELETE_Invitation(50,true ); 
        DELETE_Invitation obj1 = new DELETE_Invitation();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}