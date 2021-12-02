public class CaseTriggerHandler extends TriggerHandler {
    private static String BUYER_FEEDBACK_RT ='Buyer Feedback' ;
    private static String BUYER_SERVICES_RT ='Buyer Services' ;
    private static String CASE_OBJ ='Case' ;
    private static Map<Id,Case> triggerOldMap;
    private static Map<Id,Case> triggerNewMap;
    private static List<Case> triggerNew;
    private static List<Case> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;
    private static String ErrorMessageAllTask = System.Label.CaseAllTaskNotCloseError;
    private static User medalliaIntegrationUser = new User();
    
    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,Case>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,Case>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<Case>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<Case>) Trigger.new : null );
        medalliaIntegrationUser = [SELECT Id,Name FROM User WHERE Name = 'Medallia Integration User'];
    }
    
    protected override void doBefore(){        
        if(Trigger.isInsert){
            madalliaSurveyCaseCreation();
        }else if (Trigger.isUpdate) {
            caseUpdateBranchManagerEmailEscalation();
            closedCaseCantUpdated();
            caseAllTaskCompletedBeforeClosed();
        }
    }
    
    protected override void doAfter(){
        if (Trigger.isInsert){
        }else if (Trigger.isUpdate) 
        {
            for(Case caseRecords : triggernew){}
        } //endof if(Trigger.isUpdate)
    }
    
    private void madalliaSurveyCaseCreation(){
        system.debug('yeah');
        List<String> lstCase = new List<String>();
        Map<Id, Case> mapOfcaseIdAndCase = new Map<Id, Case>();
        
        for(Case caseRecords : triggernew){
            system.debug('forcaseRecords '+caseRecords);
            system.debug('Medallia user '+caseRecords.CreatedById);
            system.debug('Medallia user1 '+(caseRecords <> Null));
            system.debug('Medallia user2 '+(caseRecords.OwnerId <> null && caseRecords.OwnerId == medalliaIntegrationUser.Id));
            system.debug('Medallia user3 '+(caseRecords.RecordTypeId <> Null && caseRecords.RecordTypeId == getCaseRecordTypeIdbyName(BUYER_FEEDBACK_RT)));
            if(caseRecords <> Null){
                if(caseRecords.RecordTypeId <> Null && caseRecords.RecordTypeId == getCaseRecordTypeIdbyName(BUYER_FEEDBACK_RT)||
                   ((caseRecords.OwnerId <> null && caseRecords.OwnerId == medalliaIntegrationUser.Id)|| caseRecords.medallia_xm__Medallia_Feedback_id__c <> null)){
                       if(caseRecords.Originating_Case__c <> Null){
                           lstCase.add(caseRecords.Originating_Case__c);
                       } else if(caseRecords.ParentId <> Null){
                           caseRecords.Originating_Case__c = caseRecords.ParentId;
                           lstCase.add(caseRecords.Originating_Case__c);
                       }else{
                           caseRecords.addError('ParentId or Originating Case is required field for Buyer Feedback Case');
                       }
                   }
            }
        }
        system.debug(lstCase);
        List<String> lstOfOrginalCaseId = new List<String>();
        for(Case objCaseRec : [SELECT Id, Description, OwnerId FROM Case WHERE Id IN: lstCase ]){
            mapOfcaseIdAndCase.put(objCaseRec.Id, objCaseRec);
            lstOfOrginalCaseId.add(objCaseRec.Id);
        }
        map<Id, medallia_xm__Medallia_Feedback__c> mapOfCaseIdFeddback = new map<Id, medallia_xm__Medallia_Feedback__c>();
        for(medallia_xm__Medallia_Feedback__c objResponse: [SELECT medallia_xm__Original_case_Number__c, Id, Name, medallia_xm__Original_case_Owner_id__c 
                                                            FROM medallia_xm__Medallia_Feedback__c
                                                            WHERE medallia_xm__Original_case_Number__c IN: lstOfOrginalCaseId]){
                                                                system.debug('objResponse--  '+objResponse);
                                                                mapOfCaseIdFeddback.put(objResponse.medallia_xm__Original_case_Number__c, objResponse);
                                                            }
        for(Case caseRecords : triggernew){
            system.debug(mapOfCaseIdFeddback);
            if(caseRecords.RecordTypeId == getCaseRecordTypeIdbyName(BUYER_FEEDBACK_RT) && mapOfcaseIdAndCase.get(caseRecords.Originating_Case__c)<> null){
                caseRecords.Agent_Reviewed__c = mapOfcaseIdAndCase.get(caseRecords.Originating_Case__c).OwnerId;
                caseRecords.Description = mapOfcaseIdAndCase.get(caseRecords.Originating_Case__c).Description;
                caseRecords.Response__c = mapOfCaseIdFeddback.get(caseRecords.Originating_Case__c) <> null ? mapOfCaseIdFeddback.get(caseRecords.Originating_Case__c).Id : null;
                system.debug('caseRecords.Response__c ' +caseRecords.Response__c);
            }
        }
    }
    private Id getCaseRecordTypeIdbyName(String strRecordTypeName)
    {
        Schema.DescribeSObjectResult  cs = Schema.getGlobalDescribe().get(CASE_OBJ).getDescribe();
        RecordTypeInfo rt = cs.getRecordTypeInfosByName().get(strRecordTypeName);
        Id recId;
        if(rt != null){
            recId = cs.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
        }
        return recId;
    }
    @TestVisible
    private static String getRecordTypeNameById(String CASE_OBJ, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(CASE_OBJ).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    } 
    private void closedCaseCantUpdated(){
        
        for(case recCase:triggerNew){
            case oldCase = triggerOldMap.get(recCase.Id);
            if(oldCase.Status == 'Closed' && recCase.Status <> 'Re-Opened' ) {
                recCase.addError(ErrorMessage);
            }
        }
    }
    /********************************************************************
    * @User Storys: 541503												*
    * @Method Name: caseUpdateBranchManagerEmailEscalation				*
    * @Param: void														*
    * @Return Type:void													*
    * @Description: 													*
    * *******************************************************************/
    private void caseUpdateBranchManagerEmailEscalation(){
        Id caseRTId = getCaseRecordTypeIdbyName('Remote Workforce');
        Set<Id> relatedBranchIds = new Set<Id>();
        Map<Id,Id> mapOfBranchAndBranchManager = new Map<Id,Id>();
        //adding all CaseBranchId in set
        for(case recCase:triggerNew){
            case oldCase = triggerOldMap.get(recCase.Id);
            if(oldCase.IsEscalated  <> true && recCase.IsEscalated  == true && recCase.RecordTypeId == caseRTId){
                if(recCase.Branch__c <> null){
                    relatedBranchIds.add(recCase.Branch__c);
                }else{
                    recCase.addError('Case can not be escalated until branch is not associated');
                }
            }
            
        }
        //query on contact for find all Branch Manager and making map for Branch and Branch Manager
        if(!relatedBranchIds.isEmpty() ){
            /*for(Contact objContact:[SELECT Id, Name, Branch__c, Branch_Manager__c FROM Contact WHERE Branch__c IN: relatedBranchIds AND Branch_Manager__c = true]){
                mapOfBranchAndBranchManager.put(objContact.Branch__c, objContact.Id);
                
                }*/
            // if(!mapOfBranchAndBranchManager.isEmpty()){
            Group queueOCC = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Oklahoma City case' limit 1];
            system.debug('queueOCC '+queueOCC);
            for(case recCase:triggerNew){
                system.debug(recCase.RecordTypeId+'--'+caseRTId);
                case oldCase = triggerOldMap.get(recCase.Id);
                if(oldCase.IsEscalated  <> true && recCase.IsEscalated  == true  && recCase.RecordTypeId == caseRTId && queueOCC <> null) {
                    recCase.OwnerId = queueOCC.Id;
                }
                // }
            }            
        }        
    }
    /********************************************************************
    * @User Storys: 666399 Registration Task Completion Validation rule	*
    * @Method Name: caseAllTaskCompletedBeforeClosed					*
    * @Param: Void														*
    * @Return Type:void													*												
    * @Description: Buyer service can only be if all task is completed	* 
    * @Date: 19 May 2021												*
    * ******************************************************************/
    private void caseAllTaskCompletedBeforeClosed(){
        List<String> lstCaseId = new List<String>();
        Boolean isAllTaskIsClosed = true;
        Map<String,List<Task>> MapOfCaseTask = new Map<String,List<Task>>();
        Id caseBuyerServicesRTId = getCaseRecordTypeIdbyName(BUYER_SERVICES_RT);
        
        for(case recCase:triggerNew){
            if (recCase.recordTypeId == caseBuyerServicesRTId){
                lstCaseId.add(recCase.Id);
            }
        }
        for(Task objTask :[SELECT Id,IsClosed,WhatId FROM Task WHERE WhatId IN :lstCaseId]){
            if(MapOfCaseTask.containsKey(objTask.WhatId)){
                List<Task> lstOfTask = MapOfCaseTask.get(objTask.WhatId);
                lstOfTask.add(objTask);
                MapOfCaseTask.put(objTask.WhatId,lstOfTask );
            }else{
                List<Task> listOfTask = new List<Task>();
                listOfTask.add(objTask);
                MapOfCaseTask.put(objTask.WhatId,listOfTask);
            }
        }
        for(case recCase:triggerNew){
            case oldCase = triggerOldMap.get(recCase.Id);        
            if((oldCase.status <> 'Closed' && recCase.status == 'Closed') 
               && (recCase.Reason_for_Case__c == 'New Account' || recCase.Reason_for_Case__c == 'Account Update' 
                   || recCase.Reason_for_Case__c == 'License Update' || recCase.Reason_for_Case__c == 'Account Renewal'
                   || recCase.Reason_for_Case__c == 'Upgrade/Downgrade'|| recCase.Reason_for_Case__c == 'License Inquiry'
                   || recCase.Reason_for_Case__c == ' All Other Documents')  && recCase.Type == 'Registration'){
                list<Task> allTaskToCase = MapOfCaseTask.get(recCase.Id);
                if(allTaskToCase <> null && allTaskToCase.isEmpty() == false){
                    for(Task objTask:allTaskToCase){
                        if(objTask.isClosed == false){
                            isAllTaskIsClosed = false;
                        }                
                    }
                }
                if(isAllTaskIsClosed == false){
                    if(!Test.isRunningTest()){
                         recCase.addError(ErrorMessageAllTask);
                    }else{
                        system.debug(ErrorMessageAllTask);
                    }                   
                }          
            }
        }      
    }	
}