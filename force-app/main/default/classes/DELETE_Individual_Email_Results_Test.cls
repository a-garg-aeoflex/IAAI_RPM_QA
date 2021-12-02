@isTest
public class DELETE_Individual_Email_Results_Test {
    
    @isTest
    public static void DELETE_Individual_Email_ResultsMethodV1(){
        List<et4ae5__IndividualEmailResult__c> lstIDER = new List<et4ae5__IndividualEmailResult__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            
			 et4ae5__IndividualEmailResult__c obj = new et4ae5__IndividualEmailResult__c();
            et4ae5__SendDefinition__c test = new et4ae5__SendDefinition__c();
            insert test;
            obj.et4ae5__SendDefinition__c= test.Id;
            lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Individual_Email_Results obj = new DELETE_Individual_Email_Results(50,true );
        DELETE_Individual_Email_Results obj1 = new DELETE_Individual_Email_Results();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}