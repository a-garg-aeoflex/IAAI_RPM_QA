global without sharing Class ContactAccountRelationCreationBatch implements Database.Batchable<Sobject>,Database.Stateful{
	List<AccountContactRelation> lstAccConRel = new List<AccountContactRelation>();
    global Database.QueryLocator start( Database.BatchableContext BC){
        String Query = System.Label.queryContactConAccRelaCreation;
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> lstContact){
        	
            set<Id> lstIdRealtedAccount = new set<Id>();
          	List<AccountContactRelation> lstAccConRel1 = new List<AccountContactRelation>();
            Map<String, Account> mapAccIdAndAccObj = new Map<String, Account>();
            for(Contact objCon:lstContact){
                lstIdRealtedAccount.add(objCon.AccountId);
            }
            List<Account> lstAcc = [SELECT Id, Name, BI_Id__c, RecordTypeId, RecordType.Name 
                                    FROM Account 
                                    WHERE Id IN: lstIdRealtedAccount];
            for(Account objAcc :lstAcc){
                mapAccIdAndAccObj.put(objAcc.Id,objAcc);
            }
          
        	lstAccConRel = [SELECT AccountId, BI_Id__c, ContactId, Id, Type__c 
                            FROM AccountContactRelation 
                            WHERE AccountId IN:lstIdRealtedAccount];
        	system.debug('Size '+lstAccConRel.size());
            for(AccountContactRelation objConR : lstAccConRel){              
                Account objAccMap =  mapAccIdAndAccObj.get(objConR.AccountId);
                system.debug('Account BI Id '+objAccMap);
                if(objAccMap.RecordType.Name == 'Broker Account'){
                    objConR.Type__c = 'Broker';
                }else if(objAccMap.RecordType.Name == 'Buyer Account'){
                    objConR.Type__c = 'Buyer';
                }else if(objAccMap.RecordType.Name == 'Provider Account'){
                    objConR.Type__c = 'Provider';
                }
                objConR.BI_Id__c = objAccMap.BI_Id__c;
                lstAccConRel1.add(objConR);
                system.debug('lstAccConRel12 -'+objConR);
                system.debug('lstAccConRel-'+lstAccConRel1.size());
            }
    
          update lstAccConRel1;
    }
    global void finish(Database.BatchableContext BC){
         //update lstAccConRel;
    }
}