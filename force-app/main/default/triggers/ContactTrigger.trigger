/**
* @author LevDigital
* @date 2020
*
* @group Contact
* @group-content ../../ApexDocContent/Contact.htm
*
* @description Trigger on Contact, it calls the ContactDispatcher
*/

trigger ContactTrigger on Contact (after insert,after update) {
    List<TriggerKillSwitch__mdt> triggerKillSwitches = [SELECT RunTrigger__c,ObjectAPIName__c FROM TriggerKillSwitch__mdt WHERE ObjectAPIName__c IN ('Contact','ContactAPI')];
    Boolean runContactTrigger = false;
    Boolean runContactAPITrigger = false;
    for(TriggerKillSwitch__mdt triggerKillSwitch:triggerKillSwitches){
       if(triggerKillSwitch.ObjectAPIName__c == 'Contact'){
            if(triggerKillSwitch.RunTrigger__c == true){
                runContactTrigger = true;
            }
       }else if(triggerKillSwitch.ObjectAPIName__c == 'ContactAPI'){
            if(triggerKillSwitch.RunTrigger__c == true){
                runContactAPITrigger = true;
            }
       }
    }
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            if ( runContactTrigger) {
                ContactTriggerDispatcher.afterInsert(Trigger.new,Trigger.newMap);
            }
        }
        when AFTER_UPDATE {    
            if(runContactAPITrigger) {       
                ContactTriggerDispatcher.afterUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
        }
    }
}