public class DELETE_Email_Messages implements Database.Batchable<sObject>, Database.Stateful{
     private integer LimitSize = 50000;
    private Boolean executeNext = true;
    
    public DELETE_Email_Messages(integer intLimitSize, Boolean BollexecuteNext) {
        LimitSize = intLimitSize;
        executeNext = BollexecuteNext;
    }
    public DELETE_Email_Messages(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ActivityId,BccAddress,CcAddress,CreatedById,CreatedDate,EmailTemplateId,FirstOpenedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IsBounced,IsClientManaged,IsDeleted,IsExternallyVisible,IsOpened,IsTracked,LastModifiedById,LastModifiedDate,LastOpenedDate,MessageDate,MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,ValidatedFromAddress FROM EmailMessage ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<EmailMessage> lstEmailMessage = scope;
        database.delete(lstEmailMessage);
    }
    public void finish(Database.BatchableContext BC){
        if(executeNext){
            //Database.executeBatch(new DELETE_Contacts());
            Database.executeBatch(new DELETE_Cases());
        }
    }

}