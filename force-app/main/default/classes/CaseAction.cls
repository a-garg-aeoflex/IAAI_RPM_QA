/*
* @author LevDigital
* @date 2021
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Custom apex action to be used in flow to create a case using custom metadata
*
*/
public with sharing class CaseAction {
    @TestVisible private static Boolean hasError = false;
    @InvocableMethod(label='Case Action' description='New Case' category='Case')
    public static List<String> createNewCase(List<CaseActionInputs> caseInputs) {

        System.debug('Case Apex Action');
        List<String> errMessages = new List<String>();
        List<BSO_Case_Service_Event__mdt> caseSettings = new List<BSO_Case_Service_Event__mdt>();
        List<BSO_Case_Service_Event__mdt> caseServiceEvents = BSO_Case_Service_Event__mdt.getall().values();
        Case cse = new Case();
        String buyerId;
        String authUserKey;
        String eventType;
        System.debug(caseInputs.size());
        try {
            if (caseInputs.size() == 1) {
                CaseActionInputs caseInput = caseInputs[0];
                eventType = caseInput?.serviceEvent?.Event_Type__c;
                System.debug('existing : ' + caseInput.existingServiceEventName);
                for(BSO_Case_Service_Event__mdt caseServiceEvent: caseServiceEvents){
                    if(caseServiceEvent?.Case_Type__c == caseInput.caseType && String.isNotBlank(String.valueOf(caseInput?.caseType))){    
                        caseSettings.add(caseServiceEvent);
                    }            
                }
                if(!caseSettings.isEmpty() ){
                    List<Account> accts = [SELECT Id,Name,AuthUserKey__c,API_Buyer_Id__c,
                        (SELECT Id,AuthUserKey__c,Name FROM Contacts WHERE AccountId =:caseInput.serviceEvent.Account__c AND AuthUserKey__c != Null LIMIT 1),
                        (SELECT Id,Name, Event_Type__c FROM Service_Events__r WHERE Account__c =:caseInput.serviceEvent.Account__c AND Event_Type__c =:caseInput.existingServiceEventName)
                         FROM Account WHERE Id =:caseInput.serviceEvent.Account__c AND AuthUserKey__c !=Null LIMIT 1];
                    if(!accts.isEmpty()){
                        Account acct = accts[0];
                        System.debug('acct' + acct);
                        buyerId = acct.API_Buyer_Id__c;
                        authUserKey = acct.AuthUserKey__c;
                        List<Contact> cons = acct.Contacts;
                        Contact con = cons[0];
                        System.debug('contact' + con);
                        List<Service_Event__c> exisingServiceEvents = acct.Service_Events__r;
                        System.debug('exisingServiceEvents:' + exisingServiceEvents.size());
                        if(!cons.isEmpty() && (String.isBlank(caseInput.existingServiceEventName) || (String.isNotBlank(caseInput.existingServiceEventName) && exisingServiceEvents.IsEmpty()))){      
                            for(BSO_Case_Service_Event__mdt caseEvent:caseSettings){
                                if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                                    String lookupType = caseEvent.Field_API__c;					
                                    if(lookupType == 'Contact'){                                       
                                        cse.put(caseEvent.Field_API__c + 'Id',con.Id);                                        
                                    }else if(lookupType == 'Account'){
                                        cse.put(caseEvent.Field_API__c + 'Id',acct.Id);
                                    }					
                                }
                                else if(caseEvent.Field_API__c == 'RecordTypeId'){
                                    Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
                                    cse.put('RecordTypeId',recordTypeId);
                                }                        
                                else{
                                    cse.put(caseEvent.Field_API__c,caseEvent.Value__c);							
                                }
                            }
                            System.debug('*case: ' + caseInput.caseType + ' : ' + cse);
                            if(String.isNotBlank(cse.Subject)){                                
                                List<Case> existingCases= [SELECT Id,OwnerId FROM CASE 
                                                        WHERE STATUS != 'Closed' AND Origin = 'Auction Center' AND Subject =:cse.Subject AND (ContactId=:con.Id OR AccountId=:acct.Id) LIMIT 1];   
                                System.debug('*existingCases: ' + existingCases.size());            
                                if(existingCases.size() == 0){
                                    Database.SaveResult sr = Database.insert(cse, false); 
                                    String errMsg;                                  
                                    if (!sr.isSuccess() || hasError == true) {          
                                        for(Database.Error err : sr.getErrors()) {
                                            String errMessage = err.getStatusCode() + ' : ' + err.getMessage() + ' : ' + + err.getFields();
                                            errMsg = String.isBlank(errMsg) ?errMessage : errMsg + errMessage;
                                        }
                                        throw new custException(errMsg);
                                    }
                                }else{
                                    System.debug('Has Case Existing: ' + existingCases[0].Id);
                                }
                            }else{
                                throw new custException('There is not a subject for case: ' + cse + ' for Key ' + authUserKey + ' BuyerId: ' + buyerId);
                            }
                        }
                    }                  
                }
            }
        } Catch (Exception ex) {
            String errMessage = ex.getLineNumber() + ': ' + ex.getMessage();
            System.Debug(errMessage);
            errMessages.add(errMessage);
            Utils.createIntegrationLog('',errMessage,'Incoming Service Event',String.isBlank(authUserKey) ? buyerId : authUserKey,eventType,true);
        }
        return errMessages;
    }
    public class CaseActionInputs {
        @InvocableVariable
        public Service_Event__c serviceEvent;
        @InvocableVariable
        public String caseType;
        @InvocableVariable
        public String existingServiceEventName;
    }
    public class CustException extends Exception {}
}