public class FeedCommentHandler extends TriggerHandler {
    // 
    private static String BUYER_FEEDBACK_RT ='Buyer Feedback' ;
    private static String CASE_OBJ ='FeedComment' ;
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;
    List<Id> relatedToCaseId = new List<Id>();
    Map<Id, FeedComment> mapOfIdAndCase = new Map<Id, FeedComment>();
    
    private static Map<Id, FeedComment> triggerOldMap;
    private static Map<Id, FeedComment> triggerNewMap;
    private static List<FeedComment> triggerNew;
    private static List<FeedComment> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    
    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id, FeedComment>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id, FeedComment>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<FeedComment>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<FeedComment>) Trigger.new : null );
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
        
        for(FeedComment recFeedComment:triggerNew){
            system.debug('FeedComment'+ recFeedComment.ParentId);
            system.debug('FeedComment '+UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedComment.ParentId));
            if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedComment.ParentId)){
                relatedToCaseId.add(recFeedComment.ParentId);
            }
            
        }
        
        Map<Id, Case> mapOfIdAndCase = new Map<Id, Case>();
        for(case objCase:[SELECT Id, Status FROM Case Where Id IN: relatedToCaseId]){
            mapOfIdAndCase.put(objCase.Id, objCase);                
        }
        for(FeedComment recFeedComment :triggerNew){
            if('Case' == UtlitlyClass.findObjectNameFromRecordIdPrefix(recFeedComment.ParentId)){
                if(mapOfIdAndCase <> NULL && mapOfIdAndCase.get(recFeedComment.ParentId).status == 'Closed'){
                    recFeedComment.addError(ErrorMessage);
                }
            }
        }
    }
}