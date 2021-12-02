@isTest
public class DELETE_Stock_Bids_Test {
    
    @isTest
    public static void DELETE_Stock_Bids_Test_Method1(){
        List<Stock_Bid__c> lstIDER = new List<Stock_Bid__c>();
       
        for(Integer i = 0 ;i < =2;i++){
            
			 Stock_Bid__c obj = new Stock_Bid__c();
            obj.Auction_Item_Number__c = '110101';
            obj.Buyer_Id__c = 'test';
            
            
            lstIDER.add(obj);          
        }
        insert lstIDER;
       
     Test.startTest();
         DELETE_Stock_Bids obj = new DELETE_Stock_Bids(50,true ); 
        DELETE_Stock_Bids obj1 = new DELETE_Stock_Bids();
        Database.executeBatch( obj );  
      Test.stopTest();
         
    }
}