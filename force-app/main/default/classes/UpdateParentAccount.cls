global class UpdateParentAccount implements Database.Batchable<sObject> {



    global Database.QueryLocator  start(Database.BatchableContext bc) {
            // collect the batches of records or objects to be passed to execute
            system.debug('batch started');
            String query = 'SELECT Id, FEIN__c, ParentId, Name FROM Account WHERE (FEIN__c <> null AND FEIN__c <> \'0\''+') AND ParentId = Null AND (RecordType.developerName = \'Buyer_Account\'' +' OR RecordType.developerName = \'Provider_Account\''+')';
            return Database.getQueryLocator(query);
        }
    global void execute(Database.BatchableContext BC, List<Account> lstAccount) {
       Set<String> setOfFEIN = new Set<String>();
        map<String, Account> mapOfParentAccount = new Map<String, Account>();
        List<Account> updateAccount = new List<Account>(); 
        List<Account> createAccount = new List<Account>(); 
        
        RecordType objRecordType = [SELECT BusinessProcessId,CreatedById,CreatedDate,Description,DeveloperName,Id,IsActive,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SobjectType,SystemModstamp FROM RecordType WHERE DeveloperName = 'Parent_Account' and SobjectType = 'Account'];
        
        for(Account objAccRec : lstAccount){
            setOfFEIN.add(objAccRec.FEIN__c);
        }
        
        system.debug('setOfFEIN '+setOfFEIN);
        
        List<Account> lstParentAccount = [SELECT Id,Name,FEIN__c FROM Account WHERE recordType.DeveloperName ='Parent_Account' AND FEIN__c IN: setOfFEIN ];
        
        system.debug('lstParentAccount size '+lstParentAccount.size());
        
        for(Account objAcc: lstParentAccount){
            mapOfParentAccount.put(objAcc.FEIN__c,objAcc);
        }
        
        system.debug('mapOfParentAccountOfParentAccountWithFEIN No  '+mapOfParentAccount.size());
        //List<Account> lstAccount1 = [SELECT Id, FEIN__c, ParentId, Name FROM Account WHERE (FEIN__c <> null AND FEIN__c <> '0') AND ParentId = Null ];
       
       for(Account obj:lstAccount){
            if(mapOfParentAccount.get(obj.FEIN__c) == null){
        
                Account ParentAccount=  new Account();
                ParentAccount.name = 'Parent Account-'+obj.FEIN__c;
                ParentAccount.FEIN__c = obj.FEIN__c;
                ParentAccount.RecordType = objRecordType;
                createAccount.add(ParentAccount); 
            }
    
        }
        Insert createAccount;
        //system.debug('create Parent Account size '+createAccount.size());
        lstParentAccount = [SELECT Id,Name,FEIN__c FROM Account WHERE recordType.DeveloperName ='Parent_Account' AND FEIN__c IN: setOfFEIN ];
        system.debug('lstParentAccount '+lstParentAccount);
        //map<String, Account> mapOfParentAccount = new Map<String, Account>();
        mapOfParentAccount.clear();
        for(Account objAcc: lstParentAccount){
            mapOfParentAccount.put(objAcc.FEIN__c,objAcc);
        }

        system.debug('mapOfParentAccount1 '+mapOfParentAccount.size());
        for(Account obj:lstAccount){
            system.debug('lstParentAccount '+mapOfParentAccount.get(obj.FEIN__c));
            if(mapOfParentAccount.get(obj.FEIN__c) <> null){
                obj.ParentId  = mapOfParentAccount.get(obj.FEIN__c).Id;
        
                updateAccount.add(obj);
            }
        }

        Update updateAccount;
    }

    global void finish(Database.BatchableContext BC) {       
    }


}