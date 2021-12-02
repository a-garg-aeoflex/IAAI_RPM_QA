global class ContactEmailUpdatePostRefreshBatchClass implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String Query = 'SELECT Id, Name, Email From Contact where Email != Null';
            return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactList){
        for(Contact objContact:contactList){
            if( objContact.Email <> null && !objContact.Email.contains('.invalid') ){
                objContact.Email = objContact.Email+'.invalid';
            } 
        }
        update contactList;
        // process each batch of records
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Database.executeBatch(new LeadEmailUpdatePostRefreshBatchClass(), 2000);
    }    
}