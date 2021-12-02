@istest
public class Test_FetchAutomateBidResult{
    @isTest
    public static void testData(){
        string response = ' {"resultList": [{"tradeId": 10000980,"auctionId": 559621,"status": "failed","errorMessage": "BID FAILED - INVALID AMOUNT"},{"tradeId": 10000989,"auctionId": 559638,"status": "failed","errorMessage": "BID FAILED - INVALID AMOUNT"}],"tradeCount": 2}';
        
        VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'TRADEREV';
        partner.Call_Frequency_Min__c = 2;
        partner.Cron_Id__c = 'test';
        partner.Call_Start_Time__c = System.now().time();
        partner.Call_End_Time__c = System.now().addMinutes(30).time();
        partner.Bid_filtering_Value__c = 100;
        partner.Last_Batch_Ran_At__c = System.now();
        partner.Request_Id__c = 't7atd7gig7';
        insert partner;
        
        VPE_Listings__c vp = new VPE_Listings__c();
        vp.VIN__c = '1gth5cea0g1152730';
        vp.Make__c = 'Gmc';
        vp.Model__c = 'Canyon Extended Cab Sle';
        vp.Model_Year__c = '2016';
        vp.Listing_Id__c = '10000980';
        vp.Mileage__c = 95250;
        vp.Status_of_Listing__c = 'parked';
        vp.Bid_Offer_Submitted__c = true;      
        insert vp;
        
        Mock_IAAI_VPEListing_Batch fakeResponse = new Mock_IAAI_VPEListing_Batch(200, 'Complete', response, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Database.executeBatch(new FetchAutomateBidResult());
    }
    

}