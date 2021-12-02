@isTest
public class DELETE_Cases_Test {
    
    @isTest
    public static void DELETE_Cases_Test_Method1(){
        List<Case> lstIDER = new List<Case>();
       
        for(Integer i = 0 ;i < =2;i++){
            Case obj = new Case();
			obj.subject = 'test';
			lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Cases obj = new DELETE_Cases(50,true ); 
        DELETE_Cases obj1 = new DELETE_Cases();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}