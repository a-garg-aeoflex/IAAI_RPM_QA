@isTest
public class IAAI_AutoBidQueueable_Test {
    @isTest
    public static void autoBidQueueable() {
        
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
        System.enqueueJob(new IAAI_AutoBidQueueable(vpId,true));
    }

}