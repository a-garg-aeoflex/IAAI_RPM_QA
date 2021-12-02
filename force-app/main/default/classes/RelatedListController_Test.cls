@isTest
public class RelatedListController_Test {
	@isTest
    public static void fetchRecord() {
        
        Account a = new Account();
        a.NAme = 'Test';
        insert a;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = a.Id;
        con.VPE_Partner_Contact__c = true;
        insert con;
        
        VPE_Listing_Partner__c vp = new VPE_Listing_Partner__c();
        vp.Name = 'Carvio';
        vp.Account__c = a.Id;
        vp.Call_Frequency_Min__c = 30.0;
        insert vp;
        
        RelatedListController.fetchRecords(vp.Id,'Name,Title,Email,Phone',con.Id);
        RelatedListController.fetchRecords(vp.Id,'Name,Title,Email,Phone',null);
    }
}