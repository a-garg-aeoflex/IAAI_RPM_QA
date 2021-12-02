trigger ASAPNoteTrigger on ASAP_Note__c (before insert, before update, before delete, 
    after insert, after update, after delete, after undelete) {
    TriggerHandler.getInstance('ASAPNoteTriggerHelper',false).runHandler();   
}