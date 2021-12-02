global class HandleBoltOnBulkListing implements Database.Batchable<Sobject>,Database.Stateful {
    Integer counter = 0;
    Integer failureCounter = 0;
    List<sObject> batchList;
    global HandleBoltOnBulkListing(List<sObject> objList) {
        if (objList == null) objList = new List<sObject>();      
        this.batchList = objList;
    }
    global List<Sobject> start(Database.BatchableContext info){ 
        return this.batchList; 
    }     
    global void execute(Database.BatchableContext info, List<sObject> scope){
        Database.SaveResult[] srList =Database.insert(scope,false);
        for(Database.SaveResult dsr: srList)
        {
            if(dsr.isSuccess())
            {
                counter++;
            }
            else
            {
                failureCounter++;
            }
        }
    }
    global void finish(Database.BatchableContext info)
    {    
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { UserInfo.getUserEmail() };
        message.subject = 'Bulk Listing Upload Result';
        Integer recSize = batchList.size();
        message.htmlbody = 'Total records in CSV ' +recSize+'<br> Total Records Inserted ' +Counter+ '<br> Failure Records ' +FailureCounter;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    } 
}