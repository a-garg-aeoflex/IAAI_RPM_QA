@isTest
private class IAAI_UpdateVPEListingWithStockBatchTest{
    @testSetup
    static void setup() {
        //Test Data Setup
        Account testAccount = new Account(Name='Test Account 1');
        insert testAccount;
        
        List<VPE_Listings__c> vpeListingList = new List<VPE_Listings__c>();
        List<Stock__c> stockListingList = new List<Stock__c>();
        for(Integer i=1; i<=10; i++){
            vpeListingList.add(new VPE_Listings__c(VIN__c = String.valueOf(i)));
            stockListingList.add(new Stock__c(Name= 'Test Stock ' + i, Buyer_Name__c=testAccount.Id, VIN__c = String.valueOf(i)));
        }
        if(!vpeListingList.isEmpty()){
            insert vpeListingList;
        }
        if(!stockListingList.isEmpty()){
            insert stockListingList;
        }
    }

    @isTest
    static void testMethod1(){
        System.assertEquals(0, [select count() from VPE_Listings__c where Stock_Lookup__c !=null]);
        Test.startTest();
            Id batchId = Database.executeBatch(new IAAI_UpdateVPEListingWithStockBatch(), 200);
        Test.stopTest();
        System.assertEquals(10, [select count() from VPE_Listings__c where Stock_Lookup__c !=null]);
    }
}