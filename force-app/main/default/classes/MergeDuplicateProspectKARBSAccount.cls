global class MergeDuplicateProspectKARBSAccount implements Database.batchable<sobject>, Database.Stateful{ 
  
    global Database.QueryLocator  start(Database.BatchableContext bc) {
   
    String query = System.Label.DuplicateaKAR_BS;    
    system.debug(' query '+query);             
        
        return Database.getQueryLocator(query);    
    }
    
 
    global void execute(Database.BatchableContext bc, List<Account> lstCon){
        
        system.debug('lstCon'+lstCon.size());
        for(Account masterCon: lstCon){
            findDuplicateKARBSAccount(masterCon);                
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    private void findDuplicateKARBSAccount(Account objAccount){
        List<String> strFields = system.label.KAR_BS_Query.split(',');
        Id karBSAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KAR BS Account').getRecordTypeId();
        List<Account> lstDuplicateKARBSAccount = new List<Account>();
        lstDuplicateKARBSAccount = [SELECT id, KAR_Createdbyid__c, KAR_ID__c, KAR_OwnerID__c, FEIN__c, Branch__c, recordType.Name
                                    FROM Account
                                    WHERE KAR_ID__c != null AND KAR_ID__c =: objAccount.KAR_ID__c AND RecordTypeID =: karBSAccountRecordTypeId];
        list<list<Id>> lstDupAccIds = new list<list<Id>>();
        list<Id> dualList = new list<Id>();     
        system.debug('lstDuplicateKARBSAccount size '+lstDuplicateKARBSAccount.size());
        for(Account objAcc :lstDuplicateKARBSAccount){
            

            system.debug(objAcc);
            for(string str: strFields){
                 str=str.trim();
                system.debug('objAccount 1 '+objAccount);
                if((objAccount.get(str) == null || objAccount.get(str) == false)){
                    system.debug('Ass 1'+objAcc);
                    if(objAcc.get(str) != null && objAcc.get(str) != false){
                        system.debug('Ass 2'+objAcc);
                        objAccount.put(str, objAcc.get(str)); 
                        system.debug('objAccount 2 '+objAccount);
                    }
                }
            }
            
            if(dualList.size() <= 2){
                dualList.add(objAccount.Id);
                if(dualList.size() == 2){
                    lstDupAccIds.add(dualList);
                    dualList.clear();
                }
            }
            
        
        }
        system.debug('lstDupAccIds size '+lstDupAccIds.size());
        for(Account lst:lstDuplicateKARBSAccount){
            
            Database.Merge(objAccount,lst);
        }
        
    }
}