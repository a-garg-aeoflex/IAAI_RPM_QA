global class LeadAssignmentBuyerRT implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String queryAllLead = 'SELECT Id, recordtypeId, Name FROM Lead';
        return Database.getQueryLocator(queryAllLead);
    }
    global void execute(Database.BatchableContext bc, List<lead> lstLeads){
        // process each batch of records
        List<Lead> listLeads = new List<Lead>();
        Id BuyerRecordTyperId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Buyer Lead').getRecordTypeId();
    
        for(Lead objLead:lstLeads){
            objLead.recordTypeId = BuyerRecordTyperId;
            listLeads.add(objLead);
        }
        if(!listLeads.Isempty()){
            Update listLeads;
        }
        
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }   
    
}