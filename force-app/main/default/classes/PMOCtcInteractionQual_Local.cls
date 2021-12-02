/*
Numerator: Total # of Stars of all contacts with FTF meetings in last 30-days
SUM of (Contact Score) on all Tasks with Type = FTF with Date = Last 30 Days
CONTACT SCORE = 4 if picklists = ""4-Star-Owner"", 3 if picklist = ""3-star decision maker"", 2 if ""2-star-influencer"" and 1 if ""1-star-gate keeper)

Denominator: # of FTF Meetings
Tasks with Type = FTF with Date = Last 30 Days

Snapshot: Local
KPI: Local: Quality of Contact Interaction
*/


global with sharing class PMOCtcInteractionQual_Local implements WebServiceMock{
    private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
    global void doInvoke(Object stub, Object soapRequest, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNamespace, String responseName, String responseType){
        if(stub instanceof Id){
            Id userId = (Id) stub;
            response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId));
        }
    }

    @TestVisible
    private static Decimal calculate(Id userId){
        Decimal res = 0.0;
        Integer num = 0; Integer den = 0;
        
        List<Task> tlist1 = [Select id, whoid from task where type LIKE 'FTF%' AND activitydate = LAST_N_DAYS:30 AND who.type = 'Contact' AND Ownerid = :userId LIMIT 20000];
        List<Task> tlist2 = [Select id, whoid from task where type LIKE 'FTF%' AND activitydate = LAST_N_DAYS:30 AND who.type = 'Contact' AND Ownerid = :userId LIMIT 20000];
        Set<Id> contactids = new Set<Id>();
        
        for(Task t : tlist1){
            contactids.add(t.whoid);
        }
        Map<Id, Contact> ctcs = new Map<Id, Contact>([Select id, Contact_Score__c from Contact where id IN :contactids LIMIT 20000]);
        for(Id i : ctcs.keySet()) {
            Contact c = ctcs.get(i);
            num += c.Contact_Score__c == null ? 0 : (Integer) c.Contact_Score__c;
        }
        
        if(tlist2 == null && tlist2.size() <= 0)
            den = 0;
		else
            den = tlist2.size();
        
        res = den <= 0 ? 0.0 : ((Decimal)num / (Decimal)den) *100;
        return res;
    }
}