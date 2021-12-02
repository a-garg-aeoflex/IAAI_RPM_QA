@isTest
private class PMOCtcInteractionQual_Local_Test 
{
    
 	private static Account acc;
    private static Contact ctc;
    
    @TestSetup 
    static void setup() {
        acc = new Account(Name = 'accccccc', BillingState = 'Alabama', BillingCity = 'NYC');
        insert acc;    
        ctc = new Contact(LastName = 'test', accountid = acc.id);
        insert ctc;
        Task t = new Task(Subject = 'test', whoid = ctc.id, ActivityDate = System.today() - 20, Type = 'FTF - New');
        insert t;
    }
    
    @istest
    static void testMethod1(){
        PMOCtcInteractionQual_Local.calculate(Userinfo.getUserId());
        PMOCtcInteractionQual_Local p = new PMOCtcInteractionQual_Local();
        p.doInvoke(null,null,null,null,null,null,null,null,null);
    }    
}