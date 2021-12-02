@IsTest
private class MakeTraderevListingsExpire_Test {
	@testSetup
    private static void setupData() {
        VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'TRADEREV';
        partner.Call_Frequency_Min__c = 30;
        partner.of_Value__c = 50;
        partner.Reference_Value__c = 'Average_Sale_Price__c';
        insert partner;
        
        VPE_Listing_Partner__c partner1 = new VPE_Listing_Partner__c();
        partner1.Name = 'CARVIO';
        partner1.Call_Frequency_Min__c = 30;
        partner1.of_Value__c = 50;
        partner1.Reference_Value__c = 'Average_Sale_Price__c';
        insert partner1;
        
        VPE_Listings__c v = new VPE_Listings__c();
        v.VPE_Listing_Partner__c = partner.Id;
        v.VIN__c = 'Wbanb53537cp06289';
        v.Make__C = 'Nissan';
        v.Status_of_Listing__c = 'Active';
        v.Scheduled_Time_for_Auction__c = System.now().addDays(-1);
        v.Model_Year__c = '2010';
        v.Model__c = 'Rogue S';
        v.Blackbookupdated__c = true;
        v.Has_Keys__c = 'Yes';
        insert v;
        
        VPE_Listings__c v1 = new VPE_Listings__c();
        v1.VPE_Listing_Partner__c = partner.Id;
        v1.VIN__c = 'WBAGN634X2DR00740';
        v1.Make__C = 'Nissan';
        v1.Model_Year__c = '2010';
        v1.Model__c = 'Rogue S';
        v1.Blackbookupdated__c = true;
        v.Has_Keys__c = 'No';
        insert v1;
        
        VPE_Listings__c v2 = new VPE_Listings__c();
        v2.VPE_Listing_Partner__c = partner1.Id;
        v2.VIN__c = '1ZVFT80NX65140951';
        v2.Make__C = 'Nissan';
        v2.Model_Year__c = '2010';
        v2.Model__c = 'Rogue S';
        v2.Blackbookupdated__c = true;
        insert v2;
    }
    @isTest
    private static void testScheduler() {
        Test.startTest();
        	String cronExp = '0 0 2 * * ?';
        	System.schedule('Test_Change_Status_of_Listings', cronExp, new MakeTraderevListingsExpire());
        Test.stopTest();
    }
    @isTest
    private static void testBatch() {
        Test.startTest();
        	Database.executeBatch(new MakeTraderevListingsExpire());
        Test.stopTest();
        VPE_Listings__c vpl = [SELECT Id, Name, Status_of_Listing__c FROM VPE_Listings__c WHERE VIN__c = 'WBAGN634X2DR00740'];
        System.assertEquals('Expired', vpl.Status_of_Listing__c);
    }
}