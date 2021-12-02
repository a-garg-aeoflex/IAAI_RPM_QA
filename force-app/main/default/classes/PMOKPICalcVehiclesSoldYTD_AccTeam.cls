/*
NUMERATOR : # of Vehicles Sold YTD (NEW FIELD EXISTS) - for all Accounts where User is on the Account Team
DENOMINATOR : SUM of (ACCOUNT: # of Vehicles Sold YTD Goal (NEW FIELD)) for all Accounts where User is on the Account Team
Snapshot: Field
KPI: Field-YTD Vehicles Sold Vs Goal; Specialty
*/


global with sharing class PMOKPICalcVehiclesSoldYTD_AccTeam implements WebServiceMock{
    private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
    global void doInvoke(Object stub, Object soapRequest, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNamespace, String responseName, String responseType){
        if(stub instanceof Id){
            Id userId = (Id) stub;
            response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId));
        }
    }

    @TestVisible
    private static Integer calculate(Id userId){
        Integer res = 0;
        Set<Id> uniqAccIds = new Set<Id>();
        List<AccountTeamMember> accts = [Select id, AccountId from AccountTeamMember where UserId = :userId LIMIT 20000];
        for(AccountTeamMember acct : accts){
            uniqAccIds.add(acct.AccountId);
        }


        List<Account> accresults = [Select id, Total_Vehicles_Sold_YTD__c, YTD_Vehicles_Sold_Goal__c from Account where Id IN :uniqAccIds LIMIT 20000];
        List<Account_Goals_and_Targets__c> accGoalresults = [Select id, YTD_Vehicles_Sold_Goal__c from Account_Goals_and_Targets__c where Account__c IN :uniqAccIds AND Date__c = THIS_YEAR LIMIT 20000];
        
        Integer num = 0; Integer den = 0;

        for(Account acc : accresults){
            num += (acc.Total_Vehicles_Sold_YTD__c == null ? 0 : (Integer)acc.Total_Vehicles_Sold_YTD__c);
            //den += (acc.YTD_Vehicles_Sold_Goal__c == null ? 0 : (Integer)acc.YTD_Vehicles_Sold_Goal__c);
        }
        
        for(Account_Goals_and_Targets__c acc : accGoalresults){
            den += (acc.YTD_Vehicles_Sold_Goal__c == null ? 0 : (Integer)acc.YTD_Vehicles_Sold_Goal__c);
        }

        res = den <= 0 ? 0 : ((num * 100) / den);
        return res;
    }
}