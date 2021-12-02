global class MergeDuplicateAccount implements Database.batchable<sobject>, Database.Stateful{
	global Map<Id, Account> accountmap = new Map<Id, Account> ();  
    List<String> lstUpdatedAccount = new List<String>();
	private List<Account> findDuplicateAccount(Account objAcc){
        
        List<Account> lstAccount = new List<Account>();
		List<String> lstId = new List<String>();
        Id propectAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        system.debug(' --- '+propectAccountRecordTypeId);
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(objAcc);
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(lstAcc);
        system.debug(results.size());
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
			for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
				for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
					for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
						System.debug('Duplicate Record: ' + matchRecord.getRecord());
						if(objAcc.Id != matchRecord.getRecord().id){
							lstId.add(matchRecord.getRecord().id);
						}
					}
				}
			}
        }
        System.debug('lstId '+lstId);
        System.debug('objAcc '+objAcc.id);
        List<String> fields = new List<String>();
        
		lstAccount = [SELECT Industry,  BillingCity, BillingCountry, BillingGeocodeAccuracy, BillingLatitude, 
                      BillingLongitude,BI_ID__c, BillingPostalCode, BillingState, BillingStreet, Billing_Country__c,
                      Billing_Postal_Code__c, Billing_State__c, Billing_Street__c, KAR_ID__c, Loan_Payoff__c,
                      ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry, Group_Name__c, 
                      Website, ACH_Setup__c, Loss_Advisor__c, Phone, RecordTypeId, RecordType.Name 
					 FROM Account
                     WHERE Id IN: lstId AND RecordtypeId =: propectAccountRecordTypeId Limit 100];
        for(Account obj:lstAccount){
            system.debug('obj.RecordType.Name '+obj.RecordType.Name+ ' '+'obj.Id' +obj.id);
        }
			//Database.merge(objAcc, lstAccount[0]);	
		system.debug('lstAccount inside find duplicate '+lstAccount.size());  
        if(objAcc != null && !lstAccount.isEmpty() ){
            string Id = MergeObjects(objAcc,lstAccount);
        }
       
        return lstAccount;
    }
	
	private String MergeObjects(Account masterAccount, List<Account> dupAccountlist){
      
        
        
        system.debug('1');
        list<String> obj = new list<String>();       
       
        String sObjectType = masterAccount.getsObjectType().getDescribe().getName();
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();
        SavePoint sp = Database.setSavepoint();
		List<String> strFields = system.label.duplicateAccountFields.split(',');
        try{
            map<string,object> mapMasterAccount = (map<string,object>)JSON.deserializeUntyped(Json.serialize(masterAccount));
            system.debug(mapMasterAccount);
            system.debug('strFields==' +strFields);
             
            Map<String, Schema.SObjectField> mapAccountField = Schema.SObjectType.Account.fields.getMap();
            system.debug('mapAccountField==' +mapAccountField);
            //for(string strName:mapAccountField.keyset()){
               system.debug('strName==' +mapAccountField.get('billingcity')); 
            ///}
            for(string str: strFields){
                str=str.trim();
                //system.debug('===inside master if-'+masterAccount.get(str));                  
				if(masterAccount.get(str) == null || masterAccount.get(str) == false ){                        
					//system.debug('===inside master if-'+masterAccount.get(str));
					for(integer i = 0; i<dupAccountlist.size(); i++){                        
						if(dupAccountlist[i].get(str) != null && dupAccountlist[i].get(str)!= false){
						   system.debug(str);
							masterAccount.put(str, dupAccountlist[i].get(str));							
							break;
						}
					}
				}            	
            }
			
			
            list<sObject> objects = new list<sObject>();
            List<Id> lstIdAccount = new List<Id>();
			update masterAccount;
            for(integer i=0; i < dupAccountlist.size(); i++){
                accountmap.put(dupAccountlist[i].Id,dupAccountlist[i] );
                objects.add(dupAccountlist[i]);
                lstIdAccount.add(dupAccountlist[i].id);
                Database.Merge(masterAccount, dupAccountlist[i].id);
								
                
            }
            system.debug('lstIdAccount '+lstIdAccount);
            //update masterAccount;
			
			system.debug('master Rec '+masterAccount.id);
            return masterAccount.id;
        }catch(exception e){
            database.rollback(sp);
            system.debug('error '+ e.getMessage()+'  LineNumber'+e.getLineNumber());
            return e.getMessage();
        }
    }
	//String query='select column_name from information_schema.COLUMNS where table_name =\''+ String.escapeSingleQuotes(selectedValue1)+'\'';
    global Database.QueryLocator  start(Database.BatchableContext bc) {
		
		String query = System.Label.AccountProspectFieldsSoql;		
		system.debug(' query '+query);             
		
        return Database.getQueryLocator(query);    
    }
    
 
    global void execute(Database.BatchableContext bc, List<Account> lstCon){
        
        system.debug('lstCon'+lstCon.size());
        for(Account masterCon: lstCon){
            system.debug('accountmap '+accountmap.size());
            if(accountmap.get(masterCon.id) == Null){
                List<Account> lstAccount = new List<Account>();
                lstAccount =  findDuplicateAccount(masterCon);
                system.debug(lstAccount.size());
            }
        }           
        
    }
    
    global void finish(Database.BatchableContext bc){
    }
}