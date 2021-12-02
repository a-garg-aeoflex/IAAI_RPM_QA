@isTest
public class Test_BoltOnController {
    
    public static List<String> lstCSVLines;    
    @isTest
    public static void testIf()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Data';
        con.AccountId = acc.Id;
        insert con;
        
        VPE_Listings__c v1=new VPE_Listings__c();
        v1.Provider_Name__c='test1';
        v1.VIN__c='test11';
        v1.contact__c = con.Id;
        insert v1;
        
        VPE_Listing_Partner__c vl = new VPE_Listing_Partner__c();
        vl.Name='Test';
        vl.Call_Frequency_Min__c=500;
        insert vl;
        IAAI_BoltOnController.currentPartner = vl;
        
        List<VPE_Listings__c> vpeList = new List<VPE_Listings__c>();
        for( Integer a=0; a<6; a++) {
            VPE_Listings__c v=new VPE_Listings__c();
            v.Provider_Name__c='test1_'+a;
            v.VIN__c='test11_'+a;
            v.VPE_Listing_Partner__c = vl.Id;
            v.Listing_Id__c = String.valueOf(a);
            vpeList.add(v);
        }
        insert vpeList;
        
        
        BoltOnController.dealerListingRecords(con.Id,23);   
        Test.startTest();
        try{
            BoltOnController.saveListing(v1);
        }catch(exception e){ }
        try{
            BoltOnController.decodeVIN('1FTYR14V41PB04102');
           }catch(exception e){}
        try{
            BoltOnController.fetchListingsPendingForPickup();
           }catch(exception e){}
        
        
        	BoltOnController.createListing(vpeList);
        	Database.executeBatch(new HandleBoltOnBulkListing(vpeList));
        Test.stopTest();
    }
    @isTest
    public static void testElse()
    {
        Contact con = new Contact();
        con.LastName = 'Test Data';
        insert con;
        
        VPE_Listing_Partner__c vl = new VPE_Listing_Partner__c();
        vl.Name='Test';
        vl.Call_Frequency_Min__c=500;
        insert vl;
        IAAI_BoltOnController.currentPartner = vl;
        
        VPE_Listings__c v1=new VPE_Listings__c();
        v1.Provider_Name__c='test1';
        v1.VIN__c='test11';
        v1.Contact__c = con.Id;
        v1.VPE_Listing_Partner__c = vl.Id;
        v1.Listing_Id__c = 'tsting';
        
        BoltOnController.dealerListingRecords(con.Id,23);        
        Test.startTest();
        	BoltOnController.createListingRecord(v1);
        	BoltOnController.doAcceptOffer(v1);
        Test.stopTest();
    }
}