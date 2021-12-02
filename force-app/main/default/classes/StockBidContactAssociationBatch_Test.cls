@isTest
public class StockBidContactAssociationBatch_Test {
    static testMethod void StockBidContactBatch_Test1(){
       stock__c objStk = new Stock__c(Name='12351235');
        insert objStk;
       Stock_Bid__c objSB = new Stock_Bid__c(Buyer_Employee_Id__c = '12345',Stock__c = '12351235');
       insert objSB;
        
       Contact objCon = new Contact(LastName = 'TestCon', Buyer_Employee_Id__c = '12345');
        insert objCon;
        
        Test.startTest();
        StockBidContactAssociationBatch objSBCAB = new StockBidContactAssociationBatch();
         DataBase.executeBatch(objSBCAB);

        Test.stopTest();

    }

}