/*  Date            Description
  *  23-02- 2021     Queueable class will be used to send LCU update based on status back to CARVIO 
  */
public class IAAI_LCU_UpdateQueueable implements Queueable, Database.allowsCallouts {
    String listingId;
    String stockId;
    Map<String, Object> procStatus;
    public IAAI_LCU_UpdateQueueable(String listingIdTemp, String stockIdTemp, Map<String, Object> procStatusTemp) {
        listingId = listingIdTemp;
        stockId = stockIdTemp;
        procStatus = procStatusTemp;
    }
    public void execute(QueueableContext qc) {
        try{
            IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c,Authtoken__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'CARVIOBID'] ;         
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(imdt.Endpoint__c + listingId); 
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Authorization', imdt.Authtoken__c);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(60000);
            httpRequest.setBody(createRequestData(procStatus, stockId));
            HttpResponse response = h.send(httpRequest);
            if(response.getStatusCode() == 200) {
                System.debug('--BAL--'+response.getBody());
            } else {
                System.debug('--BAL1--'+response.getBody());
            }
        } catch(Exception e) {
            System.debug('exception--'+e.getMessage()+'--'+e.getStackTraceString());
        }
    }
    
    private static String createRequestData(Map<String, Object> procStatus, String stockId) {
        Map<String, Object> response = new Map<String, Object>();
        Stock__c stock = [SELECT Id, Name, PICKUP_DATETIME__c, CHECKIN_DATETIME__c, SOLD_DATETIME__c, Stock__c, 
                          (SELECT Id, NewValue, OldValue, CreatedDate FROM Histories 
                           WHERE Field = 'PROCESS_STATUS_DESC__c' ORDER BY CreatedDate DESC) 
                          FROM Stock__c WHERE Id =:stockId];
        response.put('IS_LCU_UPDATE', true);
        response.put('IAAI_STOCK_NUMBER', stock.Stock__c);
        response.put('ASSIGNMENT_DATETIME', procStatus.get('ASSIGNMENT_DATETIME'));
        response.put('QUOTED_RELEASE_DATE', procStatus.get('QUOTED_RELEASE_DATE'));
        response.put('ACTUAL_RELEASE_DATETIME', procStatus.get('ACTUAL_RELEASE_DATETIME'));
        response.put('PICKUP_DATETIME', stock.PICKUP_DATETIME__c);
        response.put('DISPATCH_DATETIME', procStatus.get('DISPATCH_DATETIME'));
        response.put('CHECKIN_DATETIME', stock.CHECKIN_DATETIME__c);
        response.put('SOLD_DATETIME', stock.SOLD_DATETIME__c);
        response.put('PROCESS_STATUS_DESCRIPTION_HISTORY', stock.Histories);
        if(procStatus.get('RELEASE_PROBLEMS')!= null){
        List<Object> releaseProblems = (List<Object>) procStatus.get('RELEASE_PROBLEMS');
        List<Object> releaseProblemsNew = new List<Object>();
        if(!releaseProblems.isEmpty()) {
            for(Object o : releaseProblems) {
                Map<String, Object> rp = (Map<String, Object>) o;
                releaseProblemsNew.add(rp.get('RELEASE_PROBLEM'));
            }
        }
        response.put('RELEASE_PROBLEMS', releaseProblemsNew);
        }
        return JSON.serialize(response);
    }
}