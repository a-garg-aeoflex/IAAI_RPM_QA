@isTest
public class DELETE_Email_Messages_Test {
    
    @isTest
    public static void DELETE_Email_Messages_Test_Method1(){
        List<EmailMessage> lstIDER = new List<EmailMessage>();
       
        for(Integer i = 0 ;i < =2;i++){
            EmailMessage obj = new EmailMessage();
			
			lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
        DELETE_Email_Messages obj = new DELETE_Email_Messages(50,true ); 
        DELETE_Email_Messages obj1 = new DELETE_Email_Messages();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}