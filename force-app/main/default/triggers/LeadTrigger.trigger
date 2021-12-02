/**
* @author LevDigital
* @date 2020
*
* @group Lead
* @group-content ../../ApexDocContent/Lead.htm
*
* @description Trigger on Lead, it calls the AccountDispatcher
*/

trigger LeadTrigger on Lead(before insert, before update, after Insert) {
   /* List<TriggerKillSwitch__mdt> triggerKillSwitch = [SELECT RunTrigger__c FROM TriggerKillSwitch__mdt WHERE ObjectAPIName__c = 'Lead'];
    Boolean runTrigger = triggerKillSwitch.isEmpty() ? false : triggerKillSwitch[0].RunTrigger__c;

    if (runTrigger) {
        switch on Trigger.OperationType {
            when AFTER_INSERT {
                LeadTriggerDispatcher.afterInsert(Trigger.new,Trigger.newMap);
            }            
        }
    }*/
    TriggerHandler.getInstance('LeadTriggerHandler',false).runHandler();
}