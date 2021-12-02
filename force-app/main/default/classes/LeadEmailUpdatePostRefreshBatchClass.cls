global class LeadEmailUpdatePostRefreshBatchClass implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String Query = 'SELECT Email,Id FROM Lead where Email != Null';
            return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> LeadList){
        for(Lead objLead:LeadList){
            if( objLead.Email <> null && !objLead.Email.contains('.invalid') ){
                objLead.Email = objLead.Email+'.invalid';
            } 
        }
        update LeadList;
        // process each batch of records
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
       // Database.executeBatch(new LeadEmailUpdatePostRefreshBatchClass(), 2000);
    }    
}