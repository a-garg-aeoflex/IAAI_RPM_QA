/**
* Lev - updated exisiting class to be able to parse
* @date 2021
*
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
*
* @description Custom REST webservice for upserting the Broker Account
*/
@RestResource(urlMapping='/updateBroker/*')
global with sharing class BrokerService {
    private static final String PARENT_BROKER_NOT_FOUND_ERROR = 'Parent Broker is not found.';
    private static final String BUYER_ID_BLANK_OR_NOT_NUMERIC_ERROR = 'Buyer Id can not be Blank and should be contains number only.';
    private static final String IS_BROKER_BOOLEAN_ERROR = 'IsBroker should be true or false only, IsBroker Can not be blank.';
    private static final String BAD_REQUEST_ERROR = 'Request is not correct, please send correct request';
    private static final String BROKER_PARENT_ERROR = 'Broker can not have Parent';
    private static final String BUYER_AND_BROKER_DIFF_ERROR = 'Buyer and Parent should be different';
    private static final String NO_BRANCH_ERROR = 'Branch is not found.';
    global class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }
    @HttpPost
    global static void updateBroker(){
        Integration_logs__c log = new Integration_logs__c();
        RestRequest req = RestContext.request;
        String result = req?.requestBody?.toString();
        try{
            //Set default log info incase of parsing issues
            log.Sent_To__c ='SCRM';
            log.Sent_From__c ='IAAI';
            log.Transaction_Type__c = 'IAAI_BUYER_UPDATE';
            List<Broker_Field__mdt> brokerFields = Broker_Field__mdt.getall().values();
            Map<String,List<SObject>> settings = new  Map<String,List<SObject>>();
            //Setting initial fields to query
            Set<String> acctFields = new Set<String>{'Id','Name','BI_ID__c','AuthUserKey__c','LastModifiedDate','LastModifiedById','CreatedDate','CreatedById','recordTypeId','recordType.DeveloperName'};  
            //make a map of objectType and levelType . 'Account', <String> List<SObject> = <'Buyer', List<custommeta>
            //so that you can loop through that the level and fill in any default values 
            Map<String, Object> incomingPayLoad = (Map<String,Object>)JSON.deserializeUntyped(result);
            //Add any sObjects to Map with SObject wrapper class
            Map<String,Utils.SObjectWrapper> sObjectMap = new Map<String,Utils.SObjectWrapper>{'Account'=>new Utils.SObjectWrapper( new Account()), 'Integration_logs__c'=>new Utils.SObjectWrapper(log) };
            //loop through custom metadata and seperate into types and add to Convert to SObject to be dynamic
            for(Broker_Field__mdt brokerField: brokerFields){
				String eventType = String.valueOf(brokerField.EventType__c);
                String brokerType = String.valueOf(brokerField.Type__c);
				if(eventType == 'Broker' && (brokerType == 'Account' || brokerType == 'Integration_logs__c') ){
                    String fld = String.valueOf(brokerField.Field__c)?.trim();
                    String fldTwo = String.valueOf(brokerField.FieldTwo__c)?.trim();
                    String fldThree = String.valueOf(brokerField.FieldThree__c)?.trim();
                    if(!settings.containsKey(fld) && String.isNotBlank(fld)){
                        settings.put(fld,new List<SObject>());
                    } 
                    if(!settings.containsKey(fldTwo) && String.isNotBlank(fldTwo)){
                        settings.put(fldTwo,new List<SObject>());
                    }
                    if(!settings.containsKey(fldThree) && String.isNotBlank(fldThree)){
                        settings.put(fldThree,new List<SObject>());
                    }                   
                    if(String.isNotBlank(fld)){
                        List<SObject> custMetadata = settings.get(fld);
                        custMetadata.add(brokerField);
                        settings.put(fld,custMetadata);
                        //If Request is mapped then add payload to sObject
                        if(brokerField.IsMapped__c == false){
                            Utils.SObjectWrapper sobjWrapper =sObjectMap.get(String.valueof(brokerField.Type__c)?.trim());
                            sobjWrapper.additionalProperties.put(brokerField.label,result);
                        }
                        //If there are any default values that are not tied to the payload, then add the default values
                        else if(String.isNotBlank(String.valueof(brokerField.DefaultValue__c)) && String.isNotBlank(String.valueof(brokerField.Field__c)) && String.isNotBlank(String.valueof(brokerField.dataType__c))) {
                            Utils.SObjectWrapper sobjWrapper =sObjectMap.get(String.valueof(brokerField.Type__c)?.trim());
                            Utils.AddFieldToSObject(sobjWrapper.sobj,String.valueof(brokerField.Type__c)?.trim(),String.valueof(brokerField.Label)?.trim(),String.valueof(brokerField.DefaultValue__c)?.trim()); 
                        }//add any additional fields to acctFields for soql statement later
                        if(String.valueof(brokerField.Type__c)?.trim() =='Account'  && String.isNotBlank(String.valueof(brokerField.label?.trim())) && brokerField.IsMapped__c){
                            acctFields.add(String.valueof(brokerField.Label)?.trim());
                        }   
                    } 
                    if(String.isNotBlank(fldTwo)){
                        List<SObject> custMetadata = settings.get(fldTwo);
                        custMetadata.add(brokerField);
                        settings.put(fldTwo,custMetadata);
                    } 
                    if(String.isNotBlank(fldThree)){
                        List<SObject> custMetadata = settings.get(fldThree);
                        custMetadata.add(brokerField);
                        settings.put(fldThree,custMetadata);
                    }               
                }
			} 
            //populate sObjectMap with payload
            Utils.populateSObject(incomingPayLoad,settings,sObjectMap,0,'topObject');
            //get the account and integration log wrappers
            Utils.SObjectWrapper acctWrapper = sObjectMap.get('Account');
            Utils.SObjectWrapper logWrapper = sObjectMap.get('Integration_logs__c');
            Account acct = (Account) acctWrapper.sobj;
            Map<String,Object> acctFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(acct));
            //if account is empty and could no parse then throw error
            if(acctFieldsMap.isEmpty() || acctFieldsMap.size() ==1){
                throw new customException(BAD_REQUEST_ERROR);
            }

            log = (Integration_logs__c) logWrapper.sobj;
            //call function to do custom logic
            updateOrCreateNewAccount(acct,log,acctWrapper.additionalProperties,logWrapper.additionalProperties,acctFields);            

        }catch(customException ex){
            System.debug(logginglevel.ERROR,'general exception ' + ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString());
            RestResponse res = RestContext.response;          
            String jsonResponse = '{"response": {"status": "Failure", "message": "' + ex.getMessage() + '"}}';
            System.debug(logginglevel.ERROR,'jsonResponse '+res.responseBody);
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Response_Body__c = jsonResponse;
            insert log;
            return;
        }catch(exception ex){
            System.debug(logginglevel.ERROR,'exception ' + ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString());
            System.debug(logginglevel.ERROR,'exception - result '+ result);
            //log.Request_Body__c = result;            
            RestResponse res = RestContext.response;
            String jsonResponse = '{"response": {"status": "Failure", "message": "' + ex.getMessage() + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Response_Body__c = jsonResponse;
            insert log;            
        }
    }   
    /*******************************************************************************************************
    * @description Does custom logic based on if the incoming payload is a broker or not
    * @param acct - the account that has been parsed from the incoming payload
	* @param log - Integration_logs__c object 
    * @param acctAdditionalProps - Map of any additional properties that were part of the configured account but did not map to any sobject fields
    * @param logAdditionalProps - Map of any additional properties that were part of the configured Integration_logs__c but did not map to any sobject fields
    * @param acctFields - Set of Fields that were configured in the custom metadata used for soql query
    * @return void
    */
    public static void updateOrCreateNewAccount(Account acct,Integration_logs__c log,Map<String,Object> acctAdditionalProps,Map<String,Object> logAdditionalProps,Set<String> acctFields ){
        //string buyerID = String.valueOf(acct.API_Buyer_Id__c)?.trim();
        string buyerID = String.valueof(acctAdditionalProps.get('Updates.Buyer.Buyer_ID'))?.trim();
        System.debug(logginglevel.DEBUG,'BuyerID: ' +buyerID);
        string withoutPrefixBuyerId = String.valueOf(acct.API_Buyer_Id__c)?.trim();
        string withPrefixBroker = 'BRK-'+buyerID; 
        string withPrefixBuyer = 'BUY-'+buyerID;
        string authUserKey = acct.AuthUserKey__c;
        System.debug(logginglevel.DEBUG,'AuthUserKey: ' +authUserKey);
        if(((String.isNotBlank(buyerID) && (buyerID).isNumeric())||(String.isNotBlank(authUserKey)))){
           
            list<string> accountFlds = new List<String>();
            accountFlds.addAll(acctFields);
            String acctFlds =String.join(accountFlds,', '); 
            Account ObjAccntRec = new Account();
            System.debug(logginglevel.DEBUG,'IsBrokerParent: ' + String.valueof(acctAdditionalProps.get('Updates.Buyer.IsBrokerParent'))?.trim()?.equalsIgnoreCase('true'));
            if(String.valueof(acctAdditionalProps.get('Updates.Buyer.IsBrokerParent'))?.trim()?.equalsIgnoreCase('true')){
                String acctQuery = 'SELECT ' + String.escapeSingleQuotes(acctFlds) + ' FROM Account WHERE ';
                acctQuery += '(BI_ID__c =:withoutPrefixBuyerId OR BI_ID__c =:withPrefixBroker  OR (AuthUserKey__c != NULL AND AuthUserKey__c != \'\' AND AuthUserKey__c =: authUserKey))';
                acctQuery += ' AND (recordType.DeveloperName = \'Broker_Account\' OR recordType.DeveloperName = \'Prospect_Buyer\') LIMIT 1';
                System.debug(logginglevel.DEBUG,'query: ' +  acctQuery);
                List<Account> accts =  Database.query(acctQuery);
                System.debug(logginglevel.DEBUG,'accts size' + accts.size());
                if(!accts.isEmpty()){
                    ObjAccntRec = accts[0];
                    if(ObjAccntRec.RecordType.DeveloperName == 'Prospect_Buyer'){
                            ObjAccntRec.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Account').getRecordTypeId();
                    }
                    if(String.isNotBlank(ObjAccntRec.BI_ID__c)){
                        List<String> LststrBI_ID = (ObjAccntRec.BI_ID__c).split('-');
                        String strBI_ID = LststrBI_ID.size() <2?LststrBI_ID[0]:LststrBI_ID[1];
                        strBI_ID =strBI_ID.trim();
                        if(strBI_ID <> buyerID){
                            ObjAccntRec.BI_ID__c = 'BRK-'+buyerID;
                        }                        
                    }else {
                        if(String.isNotBlank(buyerID)){
                            ObjAccntRec.BI_ID__c = 'BRK-'+buyerID;
                        }
                    }
                    upsertAccount(ObjAccntRec, acct,log,acctAdditionalProps,logAdditionalProps,acctFields,acctFlds);                 
                }else{
                    ObjAccntRec = new Account();
                    ObjAccntRec.BI_ID__c = 'BRK-'+string.valueOf(+buyerID).trim();
                    ObjAccntRec.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Account').getRecordTypeId();
                    upsertAccount(ObjAccntRec, acct,log,acctAdditionalProps,logAdditionalProps,acctFields,acctFlds);
                }
            }else if(String.valueof(acctAdditionalProps.get('Updates.Buyer.IsBrokerParent'))?.trim()?.equalsIgnoreCase('false')){
                String acctQuery = 'SELECT ' + String.escapeSingleQuotes(acctFlds) + ' FROM Account WHERE ';
                acctQuery += '((BI_ID__c =:withoutPrefixBuyerId AND BI_ID__c != \'\') OR BI_ID__c =:withPrefixBuyer  OR (AuthUserKey__c != NULL AND AuthUserKey__c != \'\' AND AuthUserKey__c =: authUserKey))';
                acctQuery += ' AND (recordType.DeveloperName = \'Buyer_Account\' OR recordType.DeveloperName = \'Prospect_Buyer\') LIMIT 1';
                System.debug(logginglevel.DEBUG,'query: ' +  acctQuery);
                List<Account> accts =  Database.query(acctQuery);               
                System.debug(logginglevel.DEBUG,'accts size' + accts.size());
                if(!accts.isEmpty()){
                    ObjAccntRec = accts[0];
                    if(ObjAccntRec.RecordType.DeveloperName == 'Prospect_Buyer' ){
                        ObjAccntRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
                    }
                    if(String.isNotBlank(ObjAccntRec.BI_ID__c)){
                        String strBI_ID = (ObjAccntRec.BI_ID__c).split('-')[1];                         
                        if(String.isNotBlank(buyerID) && strBI_ID <> buyerID){
                            ObjAccntRec.BI_ID__c = 'BUY-'+buyerID;
                        }
                    }else if(String.isNotBlank(buyerID)) {
                        ObjAccntRec.BI_ID__c = 'BUY-'+buyerID;
                    }
                    upsertAccount(ObjAccntRec, acct,log,acctAdditionalProps,logAdditionalProps,acctFields,acctFlds);                    
                }else{
                    ObjAccntRec = new Account();
                    ObjAccntRec.BI_ID__c = 'BUY-'+string.valueOf(buyerID);
                    ObjAccntRec.recordTypeId =  Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
                    upsertAccount(ObjAccntRec, acct,log,acctAdditionalProps,logAdditionalProps,acctFields,acctFlds);
                }
            }else{
                throw new customException(IS_BROKER_BOOLEAN_ERROR);
            }            
            RestResponse res = RestContext.response;        
            String jsonResponse = '{"response": {"status": "Success", "message": "Broker/Buyer is  successfully created or Updated", "sfId": "' + ObjAccntRec.Id + '" }}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Response_Body__c = jsonResponse;
            log.status__c = 'Success';
            insert log;
            return;        
        }else{
            throw new customException(BUYER_ID_BLANK_OR_NOT_NUMERIC_ERROR);
        }        
    } 
    /*******************************************************************************************************
    * @description Does custom logic based on if the incoming payload is a broker or not
    * @param objAcc - the account was found in Salesforce or new blank account sObject to upserted
    * @param newobj - the account that has been parsed from the incoming payload
	* @param log - Integration_logs__c object 
    * @param acctAdditionalProps - Map of any additional properties that were part of the configured account but did not map to any sobject fields
    * @param logAdditionalProps - Map of any additional properties that were part of the configured Integration_logs__c but did not map to any sobject fields
    * @param acctFields - Set of Fields that were configured in the custom metadata used for soql query
    * @param acctFlds - String of joined Fields that were configured in the custom metadata used for soql query
    * @return void
    */                                                                                                                                                                   
    private static void upsertAccount(Account objAcc, Account newobj,Integration_logs__c log,Map<String,Object> acctAdditionalProps,Map<String,Object> logAdditionalProps,Set<String> acctFields, String acctFlds){
        Branch__c objBrnch = new Branch__c();
        objAcc.Name = newobj.Name;
        String brokerId = String.ValueOf(acctAdditionalProps.get('Updates.Buyer.BrokerId'))?.trim();
        System.debug(logginglevel.DEBUG,'brokerId before: ' + brokerId);
        if(String.isNotBlank(brokerId)){ 
            System.debug('brokerId after: ' + brokerId);
            string withoutPrefixParent = String.valueOf(brokerId);
            string withPrefixParentBRK = 'BRK-'+brokerId;
            string withPrefixParentBUY = 'BUY-'+brokerId;

            String acctQuery = 'SELECT ' + String.escapeSingleQuotes(acctFlds) + ' FROM Account WHERE ';
            acctQuery += 'BI_ID__c =:withoutPrefixParent OR BI_ID__c =: withPrefixParentBRK OR BI_ID__c =:withPrefixParentBUY limit 1';
            List<Account> lssAcc =  Database.query(acctQuery);
            if(!lssAcc.isEmpty()){
                System.debug(logginglevel.DEBUG,'Current Account'+objAcc.RecordType.DeveloperName);
                System.debug(logginglevel.DEBUG,'Parent Account'+ lssAcc[0].RecordType.DeveloperName);
                if(objAcc.RecordType.DeveloperName == 'Broker_Account' ){
                    throw new customException(BROKER_PARENT_ERROR);
                }else if(objAcc.BI_ID__c == lssAcc[0].BI_ID__c){
                    throw new customException(BUYER_AND_BROKER_DIFF_ERROR);
                }else{
                    objAcc.ParentId = lssAcc[0].Id;
                }                
            }else{
                throw new customException(PARENT_BROKER_NOT_FOUND_ERROR);
            }
        }
        System.debug(logginglevel.DEBUG,'objAcc.AuthUserKey__c '+objAcc.AuthUserKey__c+ '\n');
        System.debug(logginglevel.DEBUG,'newobj.AuthUserKey '+newobj.AuthUserKey__c+ '\n');
        Map<String,Object> newobjFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(newobj));
        Map<String,Object> objAccFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(objAcc));
        
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
        for(String fldName: newobjFieldsMap.keySet()){
            //System.debug('Existing Field Name matches: ' + fldName + ' Value: ' + objAccFieldsMap.get(fldName) + ' New Field Name: ' + fldName + ' Value: ' + newobjFieldsMap.get(fldName));
            if(fldName != 'attributes' && fieldMap.containsKey(fldName)){
                String newObjValue = String.valueOf(newobjFieldsMap.get(fldName));               
                if(String.isNotBlank(newObjValue) && fieldMap.get(fldName).getDescribe().isUpdateable()){
                    Schema.DisplayType fldType = fieldMap.get(fldName).getDescribe().getType();
                    Utils.AddFieldToSObject(objAcc,String.valueOf(fldType),fldName,newobjFieldsMap.get(fldName));
                }
            }
        }
        if((String.isNotBlank(newobj.AuthUserKey__c) && objAcc.AuthUserKey__c <> newobj.AuthUserKey__c) ){
            objAcc.AuthUserKey__c = newobj.AuthUserKey__c;
        }       
        System.debug(logginglevel.FINER,'objAcc: ' +JSON.serializePretty(objAcc));
        String BranchNumber = newobj.Branch__c;
        System.debug(logginglevel.DEBUG,'branchNumber: ' +BranchNumber);
        if(BranchNumber <> Null && !String.isEmpty(BranchNumber)){
            List<Branch__c> lstBranch = [SELECT Branch_Manager__c,Branch_Name__c,Branch_Number__c,City__c,Country__c,
                                         CreatedById,CreatedDate,Fax__c,IAA_Region__c,Id,IsDeleted,LastActivityDate,
                                         LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,
                                         OwnerId,Phone__c,State__c,Street_Line_2__c,Street__c,
                                         SystemModstamp,Total_of_Vehicles_Sold_YTD__c,Zip_Code__c 
                                         FROM Branch__c
                                         WHERE Branch_Number__c =: BranchNumber Limit 1];
            if(!lstBranch.isEmpty()){
                objBrnch = lstBranch[0];
            }else{
                throw new customException(NO_BRANCH_ERROR);
            }
        }
        if(objBrnch <> Null && objBrnch.Id <> Null && objBrnch.Id <> objAcc.Branch__c){
            objAcc.Branch__c = objBrnch.Id;
        }        
        upsert objAcc;
    }	
    private class CustException extends Exception{}   
}