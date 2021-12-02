Trigger CaseTrigger on Case (before insert, before update, before delete, 
                             after insert, after update, after delete, after undelete) {
    TriggerHandler.getInstance('CaseTriggerHandler',false).runHandler();
}