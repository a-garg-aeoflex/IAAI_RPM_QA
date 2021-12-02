@isTest
public class IAAI_BuyerListingController_Test {
    
    static testMethod void vpeListingInsertUpdate() {
        
        VPE_Listing_Partner__c vpePartner = new VPE_Listing_Partner__c();
        vpePartner.Name = 'CARVIO';
        vpePartner.Call_Frequency_Min__c = 30;
        vpePartner.Listing_Partner_Type__c = 'Purchase';
        insert vpePartner;
        
        VPE_Listing_Partner__c vpePartner2 = new VPE_Listing_Partner__c();
        vpePartner2.Name = 'TRADEREV';
        vpePartner2.Call_Frequency_Min__c = 30;
        vpePartner2.Listing_Partner_Type__c = 'Auction';
        insert vpePartner2;
        
        VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'ELSE';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        insert vpePartner1;
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX65140951';
        vpe.VPE_Listing_Partner__c = vpePartner.Id;
        insert vpe;
        
        VPE_Listings__c vpe9 = new VPE_Listings__c();
        vpe9.VIN__c = '1ZVFT80NX651409591';
        vpe9.VPE_Listing_Partner__c = vpePartner2.Id;
        insert vpe9;
        
        vpe.Notes__c = 'Testing notes';
        update vpe;
        
        BuyerListingController.getPickListValuesIntoList();
        
        BuyerListingController.fetchValueAndUpdateRecord( vpe.id);
        
        BuyerListingController.getListingPartnertList();
        
        BuyerListingController.saveBidValue(vpe9.id, 80);
        BuyerListingController.getBidResult('{"requestId":"800aa73b-e866-4aad-a5d5-f88b4c72387f"}');
        BuyerListingController.makeTraderevBid(vpe9.id, vpe9.id, 900, 980, 'NOT_AVAILABLE');
        
        BuyerListingController.getBuyerPortalData(2,15,'All','Won',vpe.id,vpe.id,'init');
        //BuyerListingController.getBuyerPortalData(2,15,vpePartner1.id,'Won,Pending',vpe.id,vpe.id,'prev');
        BuyerListingController.getBuyerPortalData(2,15,vpePartner1.id,'Parked',vpe.id,vpe.id,'next');
        BuyerListingController.getBuyerPortalData(2,15,'All','',vpe.id,vpe.id,'15');
        //BuyerListingController.getBidResult('test');
        // BuyerListingController.getPageCountInfo('15');
        //BuyerListingController.getPageCountChange('10','15','10');
        BuyerListingController.getPageCountChange(10,15,20);
        BuyerListingController.getPageCountChange(1,15,20);
        BuyerListingController.getPageCountChange(1,25,20);
        // PGN_PageInfo pg = new PGN_PageInfo();
        BuyerListingController.bidOffer(vpe.Id, '10000751', 356, 50, '');
        BuyerListingController.bidOffer(vpe9.Id, '10000751', 356, 50, '');
        
        vpe.VPE_Listing_Partner__c = vpePartner1.Id;
        update vpe;
        
        BuyerListingController.bidOffer(vpe.id,vpe.id,300, 50, '');
        
        IAAI_StockBatchScheduler testsche = new IAAI_StockBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );      
    }
    static testMethod void vpeListingInsertUpdate1(){
        
        string response = ' {"resultList": [{"tradeId": 10000980,"auctionId": 559621,"status": "failed","errorMessage": "BID FAILED - INVALID AMOUNT"},{"tradeId": 10000989,"auctionId": 559638,"status": "failed","errorMessage": "BID FAILED - INVALID AMOUNT"}],"tradeCount": 2}';
        
        VPE_Listing_Partner__c vpePartner2 = new VPE_Listing_Partner__c();
        vpePartner2.Name = 'TRADEREV';
        vpePartner2.Call_Frequency_Min__c = 30;
        vpePartner2.Listing_Partner_Type__c = 'Auction';
        vpePartner2.Request_Id__c = 'gsgydf5577';
        insert vpePartner2;
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX65140951';
        vpe.VPE_Listing_Partner__c = vpePartner2.Id;
        vpe.Listing_Id__c = '10000980';
        insert vpe;
        Test.startTest();
        BuyerListingController.makeTraderevBid(vpe.Id,vpe.Id,1000,1000,'NOT_AVAILABLE');
        BuyerListingController.makeTraderevBid(vpe.Id,vpe.Id,1000,1000,'');
        BuyerListingController.bidOffer(vpe.id,vpe.id,300, 50, 'NOT_AVAILABLE');
        Test.stopTest();
    }
    static testMethod void vpeListingInsertUpdate2(){
        
        VPE_Listing_Partner__c vpePartner2 = new VPE_Listing_Partner__c();
        vpePartner2.Name = 'TRADEREV';
        vpePartner2.Call_Frequency_Min__c = 30;
        vpePartner2.Listing_Partner_Type__c = 'Auction';
        insert vpePartner2;
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX65140951';
        vpe.VPE_Listing_Partner__c = vpePartner2.Id;
        insert vpe;
        
        BuyerListingController.bidOffer(vpe.id,vpe.id,300, 50, '');
    }
    
    static testMethod void vpeListingInsertUpdateBatches() {
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX65140951';
        insert vpe;
        
        VPE_Listings__c vpe1 = new VPE_Listings__c();
        vpe1.VIN__c = '1ZVFT80NX65140921';
        vpe1.ASAP_Updated__c = false;
        vpe1.Status_of_Listing__c = 'Won';
        insert vpe1;
        
        Test.startTest();
        Database.executeBatch(new IAAI_ASAP_Stock_Batch());
        IAAI_Market_Value_Search imvs = new IAAI_Market_Value_Search();
        imvs.basicAuthCallout(vpe);
        
        Database.executeBatch(new IAAI_Blackbook_Batch());
        Test.stopTest();   
    }
    @isTest
    public static void autoBid() {
        
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
        vpe.Predicted_Price__c = 5000;
        update vpe;
        
        Set<Id> vpId = new Set<Id>();
        vpId.add(vpe.Id);
        
        
        BuyerListingController.autoBidCheck(vpId);
        AutoBidCheck.checkAutoEligibleListing(vpe.Id);
    }
     @isTest
    public static void autoBid1() {
        
        VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'CARVIO';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        vpePartner1.of_Value__c = 75;
        vpePartner1.Reference_Value__c = 'Predicted_Price__c';
        vpePartner1.Mileage_Limit__c = 1000;
        vpePartner1.Auto_Bid_Eligible__c = true;
        vpePartner1.Vehicle_Condition_Grade__c = 4;
        vpePartner1.Price_Limit__c = 100;
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
        vpe.Predicted_Price__c = 5000;
        update vpe;
        
        Set<Id> vpId = new Set<Id>();
        vpId.add(vpe.Id);
        BuyerListingController.autoBidCheck(vpId);
        AutoBidCheck.checkAutoEligibleListing(vpe.Id);
    }
    @isTest
    public static void getPredictivePriceTest(){
        
        VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'CARVIO';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        vpePartner1.of_Value__c = 75;
        vpePartner1.Reference_Value__c = 'Predicted_Price__c';
        vpePartner1.Mileage_Limit__c = 1000;
        vpePartner1.Auto_Bid_Eligible__c = true;
        vpePartner1.Vehicle_Condition_Grade__c = 4;
        vpePartner1.Price_Limit__c = 100;
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
        BuyerListingController.getPredictivePrice(vpe.Id);
    }
    @isTest
    public static void manualBidCarvio() {
         VPE_Listing_Partner__c vpePartner1 = new VPE_Listing_Partner__c();
        vpePartner1.Name = 'Tradrev';
        vpePartner1.Call_Frequency_Min__c = 30;
        vpePartner1.Listing_Partner_Type__c = 'Auction';
        vpePartner1.of_Value__c = 75;
        vpePartner1.Reference_Value__c = 'Predicted_Price__c';
        vpePartner1.Mileage_Limit__c = 1000;
        vpePartner1.Auto_Bid_Eligible__c = true;
        vpePartner1.Vehicle_Condition_Grade__c = 4;
        vpePartner1.Price_Limit__c = 100;
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
        BuyerListingController.getPredictivePrice(vpe.Id);
    }
}