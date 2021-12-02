@isTest
private class VPECarvioExpireBatchSch_Test {
    
    public static testMethod void VPECarvioExpireBatchSchTest() {
        Test.StartTest();
        VPECarvioExpireBatchSch sh1 = new VPECarvioExpireBatchSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
}