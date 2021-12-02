@isTest
private class SchedulerTestClass{
    public static testMethod void MergeDupProKARBSAccBatchJobschTest () {
        Test.StartTest();
        MergeDupProKARBSAccBatchJobsch sh1 = new MergeDupProKARBSAccBatchJobsch();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
    public static testMethod void StockBranchNameUpdateSchTest() {
        Test.StartTest();
        StockBranchNameUpdateSch sh1 = new StockBranchNameUpdateSch();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
    public static testMethod void MergeDuplicateAccountBatchJobscheduledTest() {
        Test.StartTest();
        MergeDuplicateAccountBatchJobscheduled sh2 = new MergeDuplicateAccountBatchJobscheduled();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh2); 
        Test.stopTest(); 
    }   

    
}