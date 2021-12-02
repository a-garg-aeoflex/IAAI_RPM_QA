@isTest
public class DuplicateContactSchdule_Test {
    
    public static testMethod void DuplicateContactSchduleTest() {

    Test.StartTest();
    DuplicateContactSchdule sh1 = new DuplicateContactSchdule();
    
    String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }

}