trigger TaskTrigger on Task (before insert, before update, before delete, 
                             after insert, after update, after delete, after undelete) {                                 
                                 
    TriggerHandler.getInstance('TaskTriggerHandler', false).runHandler();                        
}