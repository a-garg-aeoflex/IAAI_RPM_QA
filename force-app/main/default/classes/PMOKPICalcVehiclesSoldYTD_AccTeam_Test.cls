@isTest
private class PMOKPICalcVehiclesSoldYTD_AccTeam_Test 
{
    
 	private static Account acc;
    private static Opportunity opp;
    
    @TestSetup 
    static void setup() {
        acc = new Account(Name = 'accccccc', BillingState = 'Alabama', BillingCity = 'NYC');
        insert acc;    
        opp = new Opportunity(Name = 'opp1', StageName = 'somestage', CloseDate = System.today().addDays(40), Amount=500001);
        insert opp;
		
        AccountTeamMember atm = new AccountTeamMember(AccountId = acc.id, userid = Userinfo.getUserId() );
        insert atm;
    }
    
    @istest
    static void testMethod1(){
        PMOKPICalcVehiclesSoldYTD_AccTeam.calculate(Userinfo.getUserId());
        PMOKPICalcVehiclesSoldYTD_AccTeam p = new PMOKPICalcVehiclesSoldYTD_AccTeam();
        p.doInvoke(null,null,null,null,null,null,null,null,null);
        
        PMOKPICalcVehiclesSoldYTD_AccTeam_Sub.calculate(Userinfo.getUserId());
        PMOKPICalcVehiclesSoldYTD_AccTeam_Sub p1 = new PMOKPICalcVehiclesSoldYTD_AccTeam_Sub();
        p1.doInvoke(null,null,null,null,null,null,null,null,null);
        
        
    }    
}