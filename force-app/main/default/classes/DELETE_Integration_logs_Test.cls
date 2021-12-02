@isTest
public class DELETE_Integration_logs_Test {
    
    @isTest
    public static void DELETE_Integration_logs_Method1(){
        List<Integration_logs__c> lstIDER = new List<Integration_logs__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            
			 Integration_logs__c obj = new Integration_logs__c();
            obj.Endpoint_URL__c = 'test'+i;
            obj.Request_Body__c = 'test'+i;
            
            lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Integration_logs obj = new DELETE_Integration_logs(50,true ); 
        DELETE_Integration_logs obj1 = new DELETE_Integration_logs();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}