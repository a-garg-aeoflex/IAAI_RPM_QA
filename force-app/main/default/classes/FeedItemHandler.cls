public class FeedItemHandler extends TriggerHandler {
    // 
    private static String BUYER_FEEDBACK_RT ='Buyer Feedback' ;
    private static String CASE_OBJ ='FeedItem' ;
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;
    
    List<Id> relatedToCaseId = new List<Id>();
    Map<Id, FeedItem> mapOfIdAndCase = new Map<Id, FeedItem>();
    
    private static Map<Id, FeedItem> triggerOldMap;
    private static Map<Id, FeedItem> triggerNewMap;
    private static List<FeedItem> triggerNew;
    private static List<FeedItem> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    
    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id, FeedItem>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id, FeedItem>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<FeedItem>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<FeedItem>) Trigger.new : null );
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
        
        for(FeedItem recFeedItem:triggerNew){
            system.debug('FeedItem'+ recFeedItem.ParentId);
            system.debug('FeedItem '+UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedItem.ParentId));
            if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedItem.ParentId)){
                relatedToCaseId.add(recFeedItem.ParentId);
            }
            
        }
        
        Map<Id, Case> mapOfIdAndCase = new Map<Id, Case>();
        for(case objCase:[SELECT Id, Status FROM Case Where Id IN: relatedToCaseId]){
            mapOfIdAndCase.put(objCase.Id, objCase);                
        }
        for(FeedItem recFeedItem :triggerNew){
            if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedItem.ParentId)){
                if(mapOfIdAndCase <> NULL && mapOfIdAndCase.get(recFeedItem.ParentId).status == 'Closed'){
                    recFeedItem.addError(ErrorMessage);
                }
            }
        }
    }
}