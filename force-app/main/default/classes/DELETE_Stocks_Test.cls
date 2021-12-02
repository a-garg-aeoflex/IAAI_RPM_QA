@isTest
public class DELETE_Stocks_Test {
    
    @isTest
    public static void DELETE_Stocks_Test_Method1(){
        List<Stock__c> lstIDER = new List<Stock__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            Stock__c obj = new Stock__c();
			
			lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
        DELETE_Stocks obj = new DELETE_Stocks(50,true ); 
        DELETE_Stocks obj1 = new DELETE_Stocks();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}