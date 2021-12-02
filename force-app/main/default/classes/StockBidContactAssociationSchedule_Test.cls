@isTest
public class StockBidContactAssociationSchedule_Test {
    public static testMethod void testschedule() {
    Test.startTest();
    StockBidContactAssociationSchedule sh1 = new StockBidContactAssociationSchedule();
    String sch = '0 0 23 * * ?'; 
    system.schedule('Test Stock bid contact Assoc', sch, sh1); 
    Test.stopTest(); }

}