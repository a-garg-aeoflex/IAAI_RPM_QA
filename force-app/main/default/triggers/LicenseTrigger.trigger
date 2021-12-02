Trigger LicenseTrigger on License__c (before insert, before update, before delete, 
                             after insert, after update, after delete, after undelete) {
    TriggerHandler.getInstance('LicenseTriggerHelper',false).runHandler();
}