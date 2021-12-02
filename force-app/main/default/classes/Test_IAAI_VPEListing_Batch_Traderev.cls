@isTest
public class Test_IAAI_VPEListing_Batch_Traderev {
     @testSetup
    private static void makeTestData() {
          VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'TRADEREV';
        partner.Call_Frequency_Min__c = 2;
        partner.Cron_Id__c = 'test';
        partner.Call_Start_Time__c = System.now().time();
        partner.Call_End_Time__c = System.now().addMinutes(30).time();
        partner.Bid_filtering_Value__c = 100;
        partner.Last_Batch_Ran_At__c = System.now();
        insert partner;
        
        partner.Last_Batch_Ran_At__c = System.now() - 2;
        update partner;
        
       
        VPE_Listings__c vpl = new VPE_Listings__c();
        vpl.VPE_Listing_Partner__c = partner.Id;
        vpl.VIN__c = '1gth5cea0g1152730';
        vpl.Make__c = 'Gmc';
        vpl.Model__c = 'Canyon Extended Cab Sle t';
        vpl.Model_Year__c = '2016';
        vpl.Listing_Id__c = '10000960';
        vpl.Mileage__c = 95250;
        vpl.Status_of_Listing__c = 'Active';
        vpl.Auction_Id__c = '23e2e21r';
        vpl.Bid_Offer_Submitted__c = false;
        vpl.ASAP_Updated__c = false;
       	vpl.Blackbookupdated__c = false;
        insert vpl;
        
        
    }
     
  
    @isTest
    public static void testData1(){
        
        string response = '[{ "tradeId": 10000960, "auctionId": 559497,"tradeState": { "tradeStateId": 1},"dateAutoLaunch": null,"vin": "1FMCU0H95DUD71024","year": 2005,"make": {"makeId": 42,"name": "SAAB"},"model": { "name": "9-5"}, "trim": "4dr Sdn Arc 2.3L","exteriorColor": "White","odometer": {"odometerId": 0},"fuel": { "fuelId": 1 },"mileage": 44850,"transmission": { "transmissionId": 0 },"drivetrain": "FWD","hasAccident": true,"accidentBrand": { "name": "NONE"}, "sellerName": "Raj US Dealer 1","pickupAddress": "1 Hillside Street, Bakersfield, CA, 93306, US","vehicleHistoryReport": "null","minStartingBid": 50,"topBidAmount": 0,"buyNowPrice": null, "buyNowStartTime": null,"thumbnailURL": "https://dciz2bbrdh6r7.cloudfront.net/22174-1496243820570_t.jpg","activeExpiryTime": "2020-03-30T22:02:12Z"}]';
  
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];

		vpl.Status_of_Listing__c = 'Pending';
        vpl.Starting_Bid__c = 50;
        vpl.Bid_Offer_Amount_Paid__c = 50;
        vpl.Original_Bid_Offer_Amount__c = 50;
        vpl.Blackbookupdated__c = true;
        vpl.Most_Recent_Sale_Date__c  = System.today()+1;
        vpl.Bid_Offer_Submitted__c = true;        
        vpl.ASAP_Updated__c = true;
        vpl.Blackbookupdated__c = true;
        update vpl;
        
        Test.startTest();
       
            Mock_IAAI_VPEListing_Batch fakeResponse = new Mock_IAAI_VPEListing_Batch(200, 'OK', response, null);
        	system.debug('fakeResponse '+fakeResponse);
            Test.setMock(HttpCalloutMock.class, fakeResponse);

       // update vpl;
        //system.debug('vpl '+vpl.Bid_Offer_Submitted__c);
        
       
            Database.executeBatch(new IAAI_VPEListing_Batch_Traderev());
		//system.debug('vpl '+vpl.Bid_Offer_Submitted__c);        
        Test.stopTest();
    }
    
     /* @isTest
    public static void testData(){
        
        string response = '[{ "tradeId": 10000960, "auctionId": 559497,"tradeState": { "tradeStateId": 1},"dateAutoLaunch": null,"vin": "1FMCU0H95DUD71024","year": 2005,"make": {"makeId": 42,"name": "SAAB"},"model": { "name": "9-5"}, "trim": "4dr Sdn Arc 2.3L","exteriorColor": "White","odometer": {"odometerId": 0},"fuel": { "fuelId": 1 },"mileage": 44850,"transmission": { "transmissionId": 0 },"drivetrain": "FWD","hasAccident": true,"accidentBrand": { "name": "NONE"}, "sellerName": "Raj US Dealer 1","pickupAddress": "1 Hillside Street, Bakersfield, CA, 93306, US","vehicleHistoryReport": "null","minStartingBid": 50,"topBidAmount": 0,"buyNowPrice": null, "buyNowStartTime": null,"thumbnailURL": "https://dciz2bbrdh6r7.cloudfront.net/22174-1496243820570_t.jpg","activeExpiryTime": "2020-03-30T22:02:12Z"}]';
        
        VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'TRADEREV';
        partner.Call_Frequency_Min__c = 2;
        partner.Cron_Id__c = 'test';
        partner.Call_Start_Time__c = System.now().time();
        partner.Call_End_Time__c = System.now().addMinutes(30).time();
        partner.Bid_filtering_Value__c = 100;
        partner.Last_Batch_Ran_At__c = System.now();
        insert partner;
        
        VPE_Listings__c vp = new VPE_Listings__c();
        vp.VIN__c = '1gth5cea0g1152730';
        vp.Make__c = 'Gmc';
        vp.Model__c = 'Canyon Extended Cab Sle';
        vp.Model_Year__c = '2016';
        vp.Listing_Id__c = '10000960';
        vp.Mileage__c = 95250;
        vp.Auction_Id__c = '23e2e21r';
        vp.Status_of_Listing__c = 'parked';
        vp.Bid_Offer_Submitted__c = true;
        vp.Blackbookupdated__c = true;
        insert vp;
       
        Mock_IAAI_VPEListing_Batch fakeResponse = new Mock_IAAI_VPEListing_Batch(200, 'Complete', response, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Database.executeBatch(new IAAI_VPEListing_Batch_Traderev());
    }*/
}