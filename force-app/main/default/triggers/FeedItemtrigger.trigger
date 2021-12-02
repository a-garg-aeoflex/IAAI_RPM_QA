trigger FeedItemtrigger on FeedItem (before insert) {
     TriggerHandler.getInstance('FeedItemHandler', false).runHandler();     
}