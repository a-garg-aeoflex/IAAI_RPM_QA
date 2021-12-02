@isTest
private class LeadAssignmentBuyerRT_Test {
    static testMethod void leadAssignment() {
        List<Lead> lstLead = new List<lead>();
        Lead  lead1 = new Lead(lastName='Behind the Cloud1', company='test1');
        Lead  lead2 = new Lead(lastName='Behind the Cloud2',company='test1');
        Lead  lead3 = new Lead(lastName='Behind the Cloud3',company='test1');
        Lead  lead4 = new Lead(lastName='Behind the Cloud4',company='test1');
        lstLead.add(lead1);
        lstLead.add(lead2);
        lstLead.add(lead3);
        lstLead.add(lead4);
        insert lstLead;

        
        
        Test.startTest();
        // Insert book
        LeadAssignmentBuyerRT objLAbRT = new LeadAssignmentBuyerRT();
        Database.executeBatch(objLAbRT, 2000);
        
        Test.stopTest();    
    
    
    }
}