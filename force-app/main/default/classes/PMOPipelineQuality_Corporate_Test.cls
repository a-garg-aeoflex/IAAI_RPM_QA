@IsTest
public class PMOPipelineQuality_Corporate_Test {
 	private static Account acc;
    private static Opportunity opp;
    
    @TestSetup 
    static void setup() {
        acc = new Account(Name = 'accccccc', BillingState = 'Alabama', BillingCity = 'NYC');
        insert acc;    
        opp = new Opportunity(Name = 'opp1', StageName = 'somestage', CloseDate = System.today().addDays(40), Amount=500001);
        insert opp;

    }
    
    @istest
    static void testMethod1(){
        PMOPipelineQuality_Corporate.calculate(Userinfo.getUserId());
    }
    
}