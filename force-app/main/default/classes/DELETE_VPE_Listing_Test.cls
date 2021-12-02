@isTest
public class DELETE_VPE_Listing_Test {
    
    @isTest
    public static void DELETE_VPE_ListingMethodV1(){
        List<VPE_Listings__c> lstVPE = new List<VPE_Listings__c>();
        VPE_Listing_Partner__c vpePartner = new VPE_Listing_Partner__c();
        vpePartner.Name = 'CARVIO';
        vpePartner.Call_Frequency_Min__c = 30;
        vpePartner.Listing_Partner_Type__c = 'Purchase';
        insert vpePartner;
        
        
        for(Integer i = 0 ;i < =2;i++){
            
            VPE_Listings__c vpe = new VPE_Listings__c();
            vpe.VIN__c = '1ZVFT80NX6514095'+i;
            vpe.VPE_Listing_Partner__c = vpePartner.Id;
            lstVPE.add(vpe);          
        }
        insert lstVPE;
        
        Test.startTest();
        DELETE_VPE_Listing obj = new DELETE_VPE_Listing(50,true );  
        DELETE_VPE_Listing obj1 = new DELETE_VPE_Listing();
        Database.executeBatch( obj );  
        Test.stopTest();
        
    }
}