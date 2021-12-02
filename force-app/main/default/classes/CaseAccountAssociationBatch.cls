global class CaseAccountAssociationBatch implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        Id KarBSCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KAR BS Case').getRecordTypeId(); 
    
        String query = 'Select Id, BI_ID__c  from Case where BI_ID__c != null and recordtypeId = :KarBSCaseRecTypeId';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        
     
        Map<String, List<Case>> mapCase = new Map<String, List<Case>>();
        Map<String, Id> mapBIIdAcc = new Map<String, Id> ();
        List<Case> lstCaseToUpdate = new List<Case>(); 
        Set<String> setBIID = new Set<String>();
        
        for(Case oCase : caseList){ 
            if(mapCase.containsKey(oCase.BI_ID__c)){
                mapCase.get(oCase.BI_ID__c).add(oCase);             
            }
            else{
                List<Case> lstCase = new List<Case>();
                lstCase.add(oCase);
                mapCase.put(oCase.BI_ID__c, lstCase);
                
            }           
        }
        
        for(Account acc : [SELECT Id, BI_ID__c FROM Account WHERE BI_ID__c in :mapCase.keySet()]){        
           mapBIIdAcc.put(acc.BI_ID__c, acc.Id);
        }
        
        for (String biId : mapBIIdAcc.KeySet()){
            if(mapCase.containsKey(biId)){
                
                for(Case oCaseBiId : mapCase.get(biId)){
                    oCaseBiId.AccountId = mapBIIdAcc.get(biId); 
                    lstCaseToUpdate.add(oCaseBiId); 
                }
            }
        }
        
        
        try {
            Update lstCaseToUpdate;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {       
  }
}