@isTest
public class DELETE_Tasks_Test {
    
    @isTest
    public static void DELETE_Tasks_Test_Method1(){
        List<Task> lstIDER = new List<Task>();
        Account objA= new Account();
        objA.Name = 'testAccount';
        insert objA;
        
       
        for(Integer i = 0 ;i < =2;i++){
            
			 Task obj = new Task();
            
            
            obj.Description = 'Test';
            
			 
            
            
            lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Tasks obj = new DELETE_Tasks(50,true ); 
        DELETE_Tasks obj1 = new DELETE_Tasks();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}