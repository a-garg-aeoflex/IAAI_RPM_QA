@IsTest
private class FindLostListingsofTraderev_Test {
    @testSetup
    private static void testSetup () {
        VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'TRADEREV';
        partner.Call_Frequency_Min__c = 30;
        insert partner;
        
        VPE_Listings__c vpl = new VPE_Listings__c();
        vpl.Status_of_Listing__c = 'Pending';
        vpl.VPE_Listing_Partner__c = partner.Id;
        vpl.VIN__c = 'Wbanb53537cp06289';
        vpl.Make__C = 'Nissan';
        vpl.Model_Year__c = '2010';
        vpl.Model__c = 'Rogue S';
        vpl.Blackbookupdated__c = true;
        vpl.Has_Keys__c = 'Yes';
        insert vpl;
    }
    @IsTest
    private static void testBatch() {
        Test.startTest();
        	Database.executeBatch(new FindLostListingsofTraderev());
        Test.stopTest();
        VPE_Listings__c vpl = [SELECT Status_of_Listing__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV'];
        System.assertEquals('Lost', vpl.Status_of_Listing__c);
    }
    @IsTest
    private static void testScheduler() {
        Test.startTest();
        	String cronExp = '0 0 2 * * ?';
        	System.schedule('Test_Change_Status_of_Listings', cronExp, new FindLostListingsofTraderev());
        Test.stopTest();
    }
}