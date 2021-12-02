@isTest
public class IAAI_BoltOn_Test {
    
    static testMethod void vpeBoltOnInsertFetch() {
        
        String profileId = [SELECT Id from Profile WHERE Name = 'Custom - Partner Users']?.Id;
        
        Account acc = new Account();
        acc.name ='George dealership';
        insert acc; 
        
        Contact con = new contact(); 
        con.accountid = acc.id; 
        con.lastname = 'cochram';
        con.FirstName = 'jeff';
        insert con;
        
        User u = new User();
        u.FirstName = 'First';
        u.LastName = 'Last';
        u.Email = 'firstlast@yopmail.com';
        u.ContactId = con.Id;
        u.ProfileId = profileId;
        u.Username = 'firstlast@yopmail.com';
        u.Alias = 'FL123';
        u.TimeZoneSidKey = 'Asia/Kolkata';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        VPE_Listing_Partner__c vp = new VPE_Listing_Partner__c(); 
        vp.Call_Frequency_Min__c = 30; 
        vp.Account__c = acc.id;
        vp.name ='carvio';
        insert vp; 
        
        VPE_Listings__c vpe = new VPE_Listings__c();
        vpe.VIN__c = '1ZVFT80NX65140951';
        vpe.contact__c = con.id;
        vpe.VPE_Listing_Partner__c  = vp.id;
        vpe.Notes__c = 'Testing notes';
        insert vpe; 
        
        IAAI_BoltOnController.fetchVPEListing('10','1','');
        IAAI_BoltOnController.updateVPEListingRec(vpe.id);  
        System.runAs(u) {
            IAAI_BoltOnController.fetchUser();
            IAAI_BoltOnController.acceptTermsAndConditions();   
        }
    }
}