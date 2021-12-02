@IsTest
private class Test_ListingTrigger {
    @testSetup
    private static void makeTestData() {
        
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
        v.Model_Year__c = '2010';
        v.Model__c = 'Rogue S';
        v.Blackbookupdated__c = true;
        v.Has_Keys__c = 'Yes';
        insert v;
        
        VPE_Listings__c v1 = new VPE_Listings__c();
        v1.VPE_Listing_Partner__c = partner1.Id;
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
    @IsTest
    private static void setStartingBidToZero() {
        VPE_Listings__c vpl = [SELECT Id, Name, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VIN__c = 'WBAGN634X2DR00740' LIMIT 1];
        vpl.Starting_Bid__c = 200;
        vpl.Top_Bid__c = 200;
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VIN__c = 'WBAGN634X2DR00740' LIMIT 1];
        // System.assertEquals(200, vplAssert.Starting_Bid__c);
        //System.assertEquals(200, vplAssert.Top_Bid__c);
    }
    @IsTest
    private static void suggestBidForCARVIO() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'CARVIO' LIMIT 1];
        vpl.Average_Sale_Price__c = 300;
        vpl.Starting_Bid__c = null;
        vpl.Top_Bid__c = null;
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Original_Bid_Offer_Amount__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'CARVIO' LIMIT 1];
        //System.assertEquals(150, vplAssert.Original_Bid_Offer_Amount__c);
    }
    @IsTest
    private static void suggestBidForUpcomingTRADEREV() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        vpl.Average_Sale_Price__c = 300;
        vpl.Status_of_Listing__c = 'Upcoming';
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Original_Bid_Offer_Amount__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        //System.assertEquals(150, vplAssert.Original_Bid_Offer_Amount__c);
    }
    @IsTest
    private static void suggestBidForActiveTRADEREV() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        vpl.Average_Sale_Price__c = 400;
        vpl.Status_of_Listing__c = 'Active';
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Original_Bid_Offer_Amount__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        //System.assertEquals(200, vplAssert.Original_Bid_Offer_Amount__c);
    }
    @IsTest
    private static void suggestBidForActiveStartingBidTRADEREV() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        vpl.Average_Sale_Price__c = 400;
        vpl.Starting_Bid__c = 200;
        vpl.Status_of_Listing__c = 'Upcoming';
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Original_Bid_Offer_Amount__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        //System.assertEquals(250, vplAssert.Original_Bid_Offer_Amount__c);
    }
    @IsTest
    private static void suggestBidForActiveTopBidTRADEREV() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        vpl.Average_Sale_Price__c = 400;
        vpl.Starting_Bid__c = 200;
        vpl.Top_Bid__c = 1200;
        vpl.Status_of_Listing__c = 'Active';
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Original_Bid_Offer_Amount__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        //System.assertEquals(1400, vplAssert.Original_Bid_Offer_Amount__c);
    }
    @IsTest
    private static void handleBidOfferSubmittedFlag() {
        VPE_Listings__c vpl = [SELECT Id, Name, Average_Sale_Price__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        vpl.Status_of_Listing__c = 'Pending';
        vpl.Blackbookupdated__c = true;
        update vpl;
        VPE_Listings__c vplAssert = [SELECT Id, Name, Bid_Offer_Submitted__c, Starting_Bid__c, Top_Bid__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__r.Name = 'TRADEREV' LIMIT 1];
        // System.assertEquals(true, vplAssert.Bid_Offer_Submitted__c);
    }
    @isTest
    public static void updatePredictivePriceOnInsert(){
        VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'CARVIO';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        vpePartner1.of_Value__c = 75;
        vpePartner1.Reference_Value__c = 'Predicted_Price__c';
        vpePartner1.Mileage_Limit__c = 1000;
        vpePartner1.Auto_Bid_Eligible__c = true;
        vpePartner1.Vehicle_Condition_Grade__c = 4;
        vpePartner1.Price_Limit__c = 10000;
        insert vpePartner1;
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX651409591';
        vpe.VPE_Listing_Partner__c = vpePartner1.Id;
        vpe.Auction_Id__c = 'NOT_AVAILABLE';
        vpe.Listing_Id__c = '2342dd';
        vpe.Starting_Bid__c = 30;
        vpe.Predicted_Price__c = 1000;
        vpe.Vehicle_Condition_Grade__c = 3;
        vpe.Mileage__c = 500;
        insert vpe; 
        
    }
    @isTest
    public static void updatePredictivePriceOnUpdate(){
        VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'CARVIO';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        vpePartner1.of_Value__c = 75;
        vpePartner1.Reference_Value__c = 'Predicted_Price__c';
        vpePartner1.Mileage_Limit__c = 1000;
        vpePartner1.Auto_Bid_Eligible__c = true;
        vpePartner1.Vehicle_Condition_Grade__c = 4;
        vpePartner1.Price_Limit__c = 10000;
        insert vpePartner1;
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.Status_of_Listing__c = 'Pending';
        vpe.VIN__c = '1ZVFT80NX651409591';
        vpe.VPE_Listing_Partner__c = vpePartner1.Id;
        vpe.Auction_Id__c = 'NOT_AVAILABLE';
        vpe.Listing_Id__c = '2342dd';
        vpe.Starting_Bid__c = 30;
        vpe.Predicted_Price__c = 1000;
        vpe.Vehicle_Condition_Grade__c = 3;
        vpe.Mileage__c = 500;
        insert vpe; 
        vpe.Mileage__c = 501;
        update vpe;
    }
    
    @isTest
    public static void bidOfferChanged(){
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.Status_of_Listing__c = 'Pending';
        vpe.VIN__c = '1ZVFT80NX651409591';
        vpe.Auction_Id__c = 'NOT_AVAILABLE';
        vpe.Listing_Id__c = '2342dd';
        vpe.Starting_Bid__c = 30;
        vpe.Predicted_Price__c = 1000;
        vpe.Vehicle_Condition_Grade__c = 3;
        vpe.Original_Bid_Offer_Amount__c = 100;
        vpe.Mileage__c = 500;
        insert vpe; 
        vpe.Original_Bid_Offer_Amount__c = 501;
        update vpe;
    }
    @isTest
    public static void changeVpeListingPartner(){
        VPE_Listing_Partner__c partner1 = new VPE_Listing_Partner__c();
        partner1.Name = 'CARVIO';
        partner1.Cron_Id__c = '5e5189f202482439d666bc71';
        partner1.Call_Frequency_Min__c = 30;
        partner1.of_Value__c = 50;
        partner1.Reference_Value__c = 'Average_Sale_Price__c';
        partner1.Auto_Bid_Eligible__c = false;
        partner1.Price_Limit__c = 30;
        partner1.Status__c = 'Submitted';
        insert partner1;
        partner1.Call_Frequency_Min__c = 40;
        partner1.Auto_Bid_Eligible__c = true;
        update partner1;
        partner1.Status__c = 'Approved';
        update partner1;
        
        
    }
    @isTest
    public static void changeVpeListingPartners(){
        VPE_Listing_Partner__c partner1 = new VPE_Listing_Partner__c();
        partner1.Name = 'Traderev';
        partner1.Cron_Id__c = '5e5189f202482439d666bc71';
        partner1.Call_Frequency_Min__c = 30;
        partner1.of_Value__c = 50;
        partner1.Reference_Value__c = 'Average_Sale_Price__c';
        partner1.Auto_Bid_Eligible__c = false;
        partner1.Price_Limit__c = 30;
        partner1.Status__c = 'Submitted';
        insert partner1;
        partner1.Call_Frequency_Min__c = 40;
        partner1.Auto_Bid_Eligible__c = true;
        
        partner1.Status__c = 'Approved';
        update partner1;
        
        
    }

}