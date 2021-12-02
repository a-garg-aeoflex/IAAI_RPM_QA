trigger FeedCommentTrigger on FeedComment (before insert, before update, before delete, 
                             after insert, after update, after delete, after undelete) {                                 
                                 
    TriggerHandler.getInstance('FeedCommentHandler', false).runHandler();             
}