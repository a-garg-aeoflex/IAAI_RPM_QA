/**
* @author Lev
* @date 2020
*
* @group Account
* @group-content ../../ApexDocContent/Event.htm
*
* @description Web Service accepting events from ESB
*/
@RestResource(urlMapping='/event/incoming/*')
global with sharing class EventWebService {
    @TestVisible 
	global static Boolean isMock;
    @HttpPut             
    global static EventResponse acceptEvent() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        EventResponse resp = new EventResponse();
        String requestBody = '';
        try{
                Blob body = req.requestBody;
                requestBody = body.toString();
                //System.debug('*payload: ' + requestBody);
                Map<String, Object> eventMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
                EventIntegrationService eventIntegration = new EventIntegrationService();
                System.debug('EventWebService: '+ isMock);
                /*if(isMock == true){
                    eventIntegration.isMock = isMock;
                    System.debug(' eventIntegration: '+ isMock);
                }*/
                String errMessage = eventIntegration.sendEvents(eventMap,isMock); 
                String key =  String.isBlank(String.valueof(eventIntegration.buyerId)) ? eventIntegration.authUserKeyRegModel : eventIntegration.buyerId;
                if(String.isBlank(errMessage)){
                    resp.status = 'Success';
                    res.StatusCode = 200;
                    resp.message = '';
                }else{
                    resp.status = 'Error';
                    res.StatusCode = 200;
                    resp.message = errMessage;                  
                    Utils.createIntegrationLog(requestBody,JSON.serializePretty(resp),'Incoming Service Event',key,eventIntegration.eventType,true);
                }               
        }        
        Catch(Exception e){
                resp.status = 'Error';
                resp.message = e.getMessage();
                res.StatusCode = 400;
                System.debug('Error: ' + resp.message);
                Utils.createIntegrationLog(requestBody,JSON.serializePretty(resp),'Incoming Service Event',true);
        }
       
        return resp;
    }
    global class EventResponse {
        global String status;
        global String message;        
    }
  
}