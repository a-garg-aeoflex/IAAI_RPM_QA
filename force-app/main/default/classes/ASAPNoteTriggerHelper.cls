/*
* @author LevDigital
* @date 2021
*
* @group ASAP_Note__c
* @group-content ../../ApexDocContent/ASAP_Note__c.htm
*
* @description ASAPNoteTriggerHelper is called fromASAPNoteTrigger
*/
public with sharing class ASAPNoteTriggerHelper extends TriggerHandler{
    @TestVisible
    public static Boolean asapNoteFirstRun = true;
    private static String ASAP_NOTE_OBJ ='ASAP_Note__c';
    private static Map<Id,ASAP_Note__c> triggerOldMap;
    private static Map<Id,ASAP_Note__c> triggerNewMap;
    private static List<ASAP_Note__c> triggerNew;
    private static List<ASAP_Note__c> triggerOld;
    private static final TriggerKillSwitch__mdt TRIGGER_KILL_SWITCH = TriggerKillSwitch__mdt.getInstance('ASAPNote');
    private static final String PENDING_API_STATUS = 'Pending - Refresh to view';

    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,ASAP_Note__c>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,ASAP_Note__c>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<ASAP_Note__c>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<ASAP_Note__c>) Trigger.new : null );
    }

    protected override void doBefore(){        
       /* if(TRIGGER_KILL_SWITCH.RunTrigger__c){     
            if (Trigger.isInsert) {}
            else            
            if (Trigger.isUpdate) {}
       }*/
    }
    protected override void doAfter(){
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){ 
            if (Trigger.isInsert){
                if (asapNoteFirstRun) {
                    
                    BSONoteAPIs();
                }
            }
            /*else if (Trigger.isUpdate){            
                //using static variable so that we don't get max depth trigger error and keep updating same asap_note__c
                if (asapNoteFirstRun) {
                    asapNoteFirstRun = false;
                    //Do callout
                }                
            }*/
        }
    }
     /*******************************************************************************************************
    * @description - Invokes ASAPNoteService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void BSONoteAPIs(){
        List<String> apiNames = new List<String>();
        //only process one from the ui and don't do multiple callouts for bulkification
        if(triggerNew.size()==1 ){
            ASAP_Note__c asapNote = triggerNew[0];           
            apiNames.add('UploadNote');
            ASAPNoteService asapService = new ASAPNoteService(apiNames);
            asapService.asapNote = asapNote;
            System.enqueueJob(asapService);
        }
        
    }
}