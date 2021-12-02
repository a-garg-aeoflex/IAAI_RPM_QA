/*
Numerator: Total Quality Score of All open opportunties close date = next 6 months  next 180 days
Denominator: Total # of Opportunities with closed date = next 6 months
 next 180 days
Quality/Health Factors:
1. If Stage <=3 & Order Date >30 Days from today (3.0); OR
     If Stage =4 or 5 & Order Date <60 Days from today (3.0); (3.0 points)
2. Activity - 1 Past Activity last 30-days = 2.0 & 1 future Activity = 2.0 (4.0 points)
3. People - contact roles (1 CR=1.0 points, 2CR=2.0; 3CR=3.0; ) (3.0 points)"

Snapshot: Corporate
KPI: Corporate-Quality of their pipeline

*/


global with sharing class PMOPipelineQuality_Corporate implements WebServiceMock {
    private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); } }

    @TestVisible
    public static Integer calculate(Id userId) {
        Integer result = 0;
        String query = 'SELECT id, Amount, CloseDate, StageName, isClosed, isWon, OwnerId, PMO_PipelineQuality_StageScore__c, PMO_PipelineQuality_ActivitiesScore__c, PMO_PipelineQuality_ContactRolesScore__c FROM Opportunity WHERE isClosed = false AND closeDate = NEXT_N_DAYS:180 and OwnerId = :userId';
        List<Opportunity> oppList = Database.query(query);
        if(oppList == null || oppList.size() <= 0){
            return 0;    
        }
        
        Map<Id, Opportunity> oppIDs = new Map<Id, Opportunity>();
        
        for(Opportunity opp : oppList){
            oppIDs.put(opp.id, opp);
        }
        result += PMOPipelineQuality_Corporate.calculateStageScore_Opps(oppIDs); system.debug('## result1 = '+ result);
        result += PMOPipelineQuality_Corporate.calculateActivities(oppIDs); system.debug('## result2 = '+ result);
        result += PMOPipelineQuality_Corporate.calculateContactRoles(oppIDs); system.debug('## result3 = '+ result);
        try{
            Database.update(oppIDs.values());    
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, e.getMessage());
        }
        
        //find average
        system.debug('## result oppsize = ' + oppIDs.size());
        system.debug('## result res = ' + result);
        Double d = result * 100;
        d = (d/oppIDs.size())/10;
        system.debug('## result d = ' + d);
        result = Math.round(d);
        return result;
    }
    
    //Opportunity .. **************************************************************
    //1. If Stage <=3 & Order Date >30 Days from today (3.0); 
    //OR 
    //If Stage =4 or 5 & Order Date <60 Days from today (3.0); (3.0 points)
    
    @TestVisible    
    private static Integer calculateStageScore_Opps(Map<Id, Opportunity> oppIDs) {
        Map<Id, Integer> resultsMap = getStageScore_Opps(oppIDs.keySet());
        Integer score = 0;
        for (Opportunity opp : oppIDs.values()) {
            opp.PMO_PipelineQuality_StageScore__c = 0;
            if(resultsMap != null && resultsMap.containsKey(opp.id)){
                score += 3;
                opp.PMO_PipelineQuality_StageScore__c = 3;
            }
        }
        return score;
    }
    @TestVisible    
    private static Map<Id, Integer> getStageScore_Opps(Set<Id> oppsIDs) {
        Map<Id, Integer> result = new Map<Id, Integer>();
            
        List<Opportunity> oppList = [SELECT Id FROM Opportunity Where id in :oppsIds AND (((StageName = '0. Qualifying' OR StageName = '1. Discovering' OR StageName = '2. Validating' OR StageName = '3. Proposing') AND CloseDate > NEXT_N_DAYS:30) OR ((StageName = '4. Closing' OR StageName = '5. Closed Won') AND CloseDate < NEXT_N_DAYS:60))];
        for (Opportunity opp : oppList) {
            result.put(opp.id, 1);
        }
        return result;
    } 
    
    //Opportunity has related activities ******************************************
    @TestVisible    
    private static Integer calculateActivities(Map<Id, Opportunity> oppIDs) {
        Map<Id, Integer> resultsMap_OpenActs = getOpenActivitiesDays(oppIDs.keySet());
        Map<Id, Integer> resultsMap_ClosedActs = getClosedActivitiesDays(oppIDs.keySet());
        Integer count_openAct = 0; Integer count_closedAct = 0;
        Integer score = 0;
        for (Opportunity opp : oppIDs.values()) {
            count_openAct = 0;  count_closedAct = 0; opp.PMO_PipelineQuality_ActivitiesScore__c = 0;
            if (resultsMap_OpenActs != null && resultsMap_OpenActs.containsKey(opp.id)) {
                count_openAct = resultsMap_OpenActs.get(opp.id); 
            }
            if (resultsMap_ClosedActs != null && resultsMap_ClosedActs.containsKey(opp.id)) {
                count_closedAct = resultsMap_ClosedActs.get(opp.id); 
            }            
            if(count_openAct > 0){
                score += 2; opp.PMO_PipelineQuality_ActivitiesScore__c += 2;
            }
            if(count_closedAct > 0){
                score += 2; opp.PMO_PipelineQuality_ActivitiesScore__c += 2;
            }

        }
        return score;
    }
    @TestVisible    
    private static Map<Id, Integer> getOpenActivitiesDays(Set<Id> oppsIDs) {
        Map<Id, Integer> result = new Map<Id, Integer>();
        List<Opportunity> oppList = [SELECT Id, (SELECT Id FROM OpenActivities limit 1000) FROM Opportunity Where id in :oppsIds limit 1000];
        for (Opportunity opp : oppList) {
            result.put(opp.id, opp.OpenActivities.size());
        }
        return result;
    } 
    
    @TestVisible    
    private static Map<Id, Integer> getClosedActivitiesDays(Set<Id> oppsIDs) {
        Map<Id, Integer> result = new Map<Id, Integer>();
        List<Opportunity> oppList = [SELECT Id, (SELECT Id FROM ActivityHistories WHERE ActivityDate = LAST_N_DAYS:30 limit 1000) FROM Opportunity Where id in :oppsIds limit 1000];
        for (Opportunity opp : oppList) {
            result.put(opp.id, opp.ActivityHistories.size());
        }
        return result;
    } 
    
    //Opportunity has related Contact Roles *****************************************
    @TestVisible    
    private static Integer calculateContactRoles(Map<Id, Opportunity> oppIDs) {
        Map<Id, Integer> resultsMap = getContactRoles(oppIDs.keySet());
        Integer score = 0;
        Integer count = 0;
        for (Opportunity opp : oppIDs.values()) {
            count = 0; opp.PMO_PipelineQuality_ContactRolesScore__c = 0;
            if (resultsMap!= null && resultsMap.containsKey(opp.id)) {
                count = resultsMap.get(opp.id); 
            }
            if(count > 0){
                opp.PMO_PipelineQuality_ContactRolesScore__c = Math.min(3, count);
                score += Math.min(3, count);
            }
        }
        return score;
    }
    @TestVisible    
    private static Map<Id, Integer> getContactRoles(Set<Id> oppsIDs) {
        Map<Id, Integer> result = new Map<Id, Integer>();
        AggregateResult[] groupedResults = [Select OpportunityId, count(id) cnt from OpportunityContactRole where ContactId != null AND OpportunityId in:oppsIDs GROUP BY OpportunityId LIMIT 20000];
        Integer count;
        Id oppId;
        for(AggregateResult ar : groupedResults) {
            count = (Integer)ar.get('cnt');
            oppId = (Id)ar.get('OpportunityId');
            result.put(oppId, count);
        }  
        
        return result;
    }
    
}