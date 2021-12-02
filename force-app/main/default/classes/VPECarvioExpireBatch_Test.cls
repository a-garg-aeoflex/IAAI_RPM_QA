@isTest
private class VPECarvioExpireBatch_Test {
    private static testmethod void senario1(){
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
        datetime dt = system.now().addHours(-30);
        
        Test.setCreatedDate(vpe.Id,dt );
        
        VPE_Listings__c vpe9 = new VPE_Listings__c();
        vpe9.VIN__c = '1ZVFT80NX651409591';
        vpe9.VPE_Listing_Partner__c = vpePartner2.Id;
        insert vpe9;
        datetime dt2 = system.now().addHours(-30);
        
        Test.setCreatedDate(vpe9.Id,dt2 );
        
        
        VPECarvioExpireBatch b = new VPECarvioExpireBatch();
        database.executeBatch(b);
    }
}