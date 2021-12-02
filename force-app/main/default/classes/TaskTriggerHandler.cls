public class TaskTriggerHandler extends TriggerHandler {
    // 
    private static String BUYER_FEEDBACK_RT ='Buyer Feedback' ;
    private static String CASE_OBJ ='Case' ;
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;

    
    List<Id> relatedToCaseId = new List<Id>();
    Map<Id, Task> mapOfIdAndCase = new Map<Id, Task>();
    
    private static Map<Id,Task> triggerOldMap;
    private static Map<Id,Task> triggerNewMap;
    private static List<Task> triggerNew;
    private static List<Task> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    
    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,Task>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,Task>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<Task>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<Task>) Trigger.new : null );
    }
    
    protected override void doBefore(){
        
        if (Trigger.isInsert) {
            closedCaseTaskCantUpdated();
        }else if (Trigger.isUpdate) {
            closedCaseTaskCantUpdated();
        }
    }
    
    protected override void doAfter(){
        if (Trigger.isInsert){
            
        }else if (Trigger.isUpdate) 
        {
            
            
        } //endof if(Trigger.isUpdate)
    }
    
    private void closedCaseTaskCantUpdated(){
        List<Id> relatedToCaseId = new List<Id>();
        Map<Id, Case> mapOfIdAndCase = new Map<Id, Case>();
        
        for(Task recTaskObj :triggerNew){
            system.debug('case'+ recTaskObj.WhatId);
            system.debug('ca '+UtlitlyClass.findObjectNameFromRecordIdPrefix(recTaskObj.WhatId));
            if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recTaskObj.WhatId)){
                relatedToCaseId.add(recTaskObj.WhatId);
            }
            
        }                                 
        
        for(case objCase:[SELECT Id, Status FROM Case Where Id IN: relatedToCaseId]){
              mapOfIdAndCase.put(objCase.Id, objCase);                
        }
        
        for(Task recTaskObj :triggerNew){
             if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recTaskObj.WhatId)){
                 if(mapOfIdAndCase <> NULL && mapOfIdAndCase.get(recTaskObj.WhatId).status == 'Closed'){
                     recTaskObj.addError(ErrorMessage);
                 }
            }
        }        
    }
   /*  private Id getCaseRecordTypeIdbyName(String strRecordTypeName)
    {
        return  Schema.getGlobalDescribe().get(CASE_OBJ).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
   private static String getRecordTypeNameById(String CASE_OBJ, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(CASE_OBJ).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    } 
    private void closedCaseCantUpdated(){
        for(case recCase:triggerNew){
            case oldCase = triggerOldMap.get(recCase.Id);
            if(oldCase.Status == 'Closed' && recCase.Status <> 'Re-Opened' ) {
                recCase.addError('Case can not be updated, to update closed case reopen it');
            }
        }
    }*/
   
}