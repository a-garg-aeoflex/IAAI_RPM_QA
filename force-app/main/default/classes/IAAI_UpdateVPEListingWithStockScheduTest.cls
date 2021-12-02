@isTest
private class IAAI_UpdateVPEListingWithStockScheduTest{
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
        Test.startTest();
            String jobId = System.schedule('IAAI_UpdateVPEListingWithStockScheduTest', '0 0 0 15 3 ? 2022', new IAAI_UpdateVPEListingWithStockScheduler());
        Test.stopTest();
    }
}