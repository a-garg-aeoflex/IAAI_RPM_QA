/**
* Lev - updated exisiting class to be able to parse
* @date 2021
*
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
*
* @description Custom REST webservice for upserting the Employee Contact
*/

@RestResource(urlMapping='/updateEmployee/*')
global with sharing class EmployeeService {
    private static final String EMPLOYEE_LAST_NAME_REQUIRED_ERROR = 'Employee Last Name is required, It can not be empty';
    private static final String NO_BUYER_BROKER_ERROR ='No Buyer/Broker Found for this Employee Id';
    private static final String BUYER_EMPLOYEE_ID_IS_NOT_BLANK_ERROR = 'Buyer Employee Id should be blank';
    private static final String BAD_REQUEST_ERROR = 'Request is not correct, please send correct request';
    global class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }
    
    @HttpPost
    global static void updateEmployee(){
        Integration_logs__c log = new Integration_logs__c();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String result = req?.requestBody?.toString();
        String contactFld;
        String contactValue;
        try{
            system.debug('result '+result);
            //Set default log info incase of parsing issues
            log.Sent_To__c = 'SCRM';
            log.Sent_From__c = 'IAAI';
            log.Transaction_Type__c = 'IAAI_EMPLOYEE_UPDATE';

            List<Broker_Field__mdt> brokerFields = Broker_Field__mdt.getall().values();
            Map<String,List<SObject>> settings = new  Map<String,List<SObject>>();
            //Setting initial fields to query
            Set<String> contactFields = new Set<String>{'Id','Name','Buyer_ID__c','Buyer_Employee_ID__c','LastModifiedDate','LastModifiedById','CreatedDate','CreatedById','recordTypeId','recordType.DeveloperName'};  
            //make a map of objectType and levelType . 'Contact', <String> List<SObject> = <'Buyer', List<custommeta>
            //so that you can loop through that the level and fill in any default values 
            Map<String, Object> incomingPayLoad = (Map<String,Object>)JSON.deserializeUntyped(result);
            //Add any sObjects to Map with SObject wrapper class
            Map<String,Utils.SObjectWrapper> sObjectMap = new Map<String,Utils.SObjectWrapper>{'Contact'=>new Utils.SObjectWrapper( new Contact()), 'Integration_logs__c'=>new Utils.SObjectWrapper(log) };
            //loop through custom metadata and seperate into types and add to Convert to SObject to be dynamic
            for(Broker_Field__mdt brokerField: brokerFields){
				String eventType = String.valueOf(brokerField.EventType__c);
                String brokerType = String.valueOf(brokerField.Type__c);
				if(eventType == 'Employee' && (brokerType == 'Contact' || brokerType == 'Integration_logs__c') ){
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
                        }//add any additional fields to contactFields for soql statement later
                        if(String.valueof(brokerField.Type__c)?.trim() =='Contact'  && String.isNotBlank(String.valueof(brokerField.label?.trim())) &&  brokerField.IsMapped__c){
                            contactFields.add(String.valueof(brokerField.Label)?.trim());
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
            //populate sObjectMap with payload with Generic function to parse JSON
            Utils.populateSObject(incomingPayLoad,settings,sObjectMap,0,'topObject');
            //get the contact and integration log wrappers
            Utils.SObjectWrapper contactWrapper = sObjectMap.get('Contact');
            Utils.SObjectWrapper logWrapper = sObjectMap.get('Integration_logs__c');
            //get the parsed Contact object
            Contact parsedContact = (Contact) contactWrapper.sobj;
            System.debug(logginglevel.FINER,'parsedContact: ' + JSON.serializePretty(parsedContact));
            //Put all of the Contact fields in a map
            Map<String,Object> contactFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(parsedContact));
            //get the parsed Log object
            log = (Integration_logs__c) logWrapper.sobj;

            String buyerId = String.valueOf(parsedContact.Buyer_ID__c)?.trim();
            string buyerEmployeeId = String.valueOf(parsedContact.Buyer_Employee_ID__c)?.trim();
            System.debug(logginglevel.FINER,'buyerEmployeeId: ' + buyerEmployeeId);
            System.debug(logginglevel.FINER,'buyerId: ' + buyerId);

            Contact existingOrBlankContact = new Contact();
            //Verify the contact is not blank or null
            if((!contactFieldsMap.isEmpty() || contactFieldsMap.size() > 1) && String.isNotBlank(buyerEmployeeId)){ 
                string withoutPrefixBuyer = String.valueOf(buyerId)?.trim();
                string withPrefixBuyer = 'BUY-'+String.valueOf(buyerId)?.trim(); 
                string withPrefixBroker = 'BRK-'+String.valueOf(buyerId)?.trim(); 
                Account acct = new Account();
                //Get the Account that should be associated with the account                
                list<Account> accts = [SELECT Id, BI_ID__c, Name,BillingStreet, BillingCity, BillingPostalCode, BillingState,
                                        	   BillingCountry, Phone, FEIN__c, ShippingStreet, ShippingCity, ShippingPostalCode, 
                                        	   ShippingState,recordtype.developerName, ShippingCountry, Branchnumber_c__c, 
                                        	   Buyer_Status__c, Branch__c,recordtype.Name
                                        FROM Account 
                                        WHERE  BI_ID__c =:withoutPrefixBuyer 
                                        	OR BI_ID__c =:withPrefixBuyer 
                                        	OR BI_ID__c =:withPrefixBroker LIMIT 10];
                Id AccId;
                system.debug('accts size: '+ accts?.size());
                if(!accts.isEmpty() && accts[0].BI_ID__c <> '' && accts[0].BI_ID__c <> null){
                    acct = accts[0];
                    AccId = acct.Id;
                    system.debug('AcctId: '+ acct.Id);
                    system.debug('AcctRecordTypeDevName: '+ acct.recordtype.developerName);
                }else{
                    throw new customException(NO_BUYER_BROKER_ERROR);
                }
                list<string> contactFlds = new List<String>();
                contactFlds.addAll(contactFields);
                String conFlds =String.join(contactFlds,', ');
                String contactQuery = 'SELECT ' + String.escapeSingleQuotes(conFlds) + ' FROM Contact WHERE ';
                contactQuery += ' Buyer_Employee_ID__c =: buyerEmployeeId LIMIT 1';               
                List<Contact> existingContacts =  Database.query(contactQuery);
                system.debug('ExistingContacts Size: '+ existingContacts.size());               
                String accountRecordTypeName = acct.recordtype.developerName;
                
                if(!existingContacts.isEmpty()){
                    existingOrBlankContact = existingContacts[0];  
                    //system.debug('existingOrBlankContact : '+ JSON.serializePretty(existingOrBlankContact));                   
                }else{
                    if(accountRecordTypeName == 'Broker_Account'){
                        existingOrBlankContact.RecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get('Broker Employee').getRecordTypeId();
                    }else if(accountRecordTypeName == 'Buyer_Account'){
                        existingOrBlankContact.RecordTypeId = Schema.SobjectType.Contact.getRecordTypeInfosByName().get('Buyer Employees').getRecordTypeId();
                    }
                }                
                existingOrBlankContact.AccountId =  AccId;
                Map<String,Object> parsedContactMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(parsedContact));
                Map<String,Object> existingOrBlankContactMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(existingOrBlankContact));
                
                Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
                //loop through and assign any parsed Contact fields to the existingOrBlankContact.
                for(String fldName: parsedContactMap.keySet()){
                    contactFld = fldName;                    
                    //System.debug('Existing Field Name matches: ' + fldName + ' Value: ' + objAccFieldsMap.get(fldName) + ' New Field Name: ' + fldName + ' Value: ' + newobjFieldsMap.get(fldName));
                    if(fldName != 'attributes' && fieldMap.containsKey(fldName)){
                        String newObjValue = String.valueOf(parsedContactMap.get(fldName));
                        String retType =Utils.returnType( parsedContactMap.get(fldName) );
                        Schema.DisplayType fldType = fieldMap.get(fldName).getDescribe().getType();
                        contactValue = newObjValue + ' dataType: ' + retType + ' field type: ' + String.valueOf(fldType);
                        
                        if(String.isNotBlank(newObjValue) && fieldMap.get(fldName).getDescribe().isUpdateable()){                         
                            //existingOrBlankContact.put(fldName,parsedContactMap.get(fldName));
                            Utils.AddFieldToSObject(existingOrBlankContact,String.valueOf(fldType),fldName,parsedContactMap.get(fldName));
                        }
                    }
                }
                contactFld = '';
                //custom logic for isOwner
                if(existingOrBlankContact <> null && existingOrBlankContact.Job_Title_Code__c <> null &&  existingOrBlankContact.Job_Title_Code__c <> '' && existingOrBlankContact.Job_Title_Code__c.equalsIgnoreCase('OWNR')){
                    existingOrBlankContact.Is_Owner__c = true;
                }
                if(String.isBlank(existingOrBlankContact.LastName)){                   
                    throw new customException(EMPLOYEE_LAST_NAME_REQUIRED_ERROR);
                }               
                ///system.debug('existingOrBlankContact: '+ JSON.serializePretty(existingOrBlankContact)); 
                upsert existingOrBlankContact;
                
            }else{
                throw new customException(BUYER_EMPLOYEE_ID_IS_NOT_BLANK_ERROR);
            }
            String jsonResponse = '{"response": {"status": "Success", "message": "Employee ' + parsedContact.Buyer_Employee_ID__c +' is created/Updated successfully","sfId": "'+ existingOrBlankContact.Id +'"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Status__c = 'Success';
            log.Response_Body__c = jsonResponse;
            insert log;
        }catch(System.TypeException exc){    
            String errMsg = String.isNotBlank(contactFld) ?  'Type exception: ' + contactFld + ' : ' + contactValue + ' '  + exc.getLineNumber()  + ' : ' + exc.getMessage()  + ' : ' + exc.getStackTraceString() 
                    : 'Type exception: '+ exc.getLineNumber() + exc.getMessage() + exc.getStackTraceString();
            system.debug(errMsg);   	
            String jsonResponse = String.isNotBlank(contactFld) ? '{"response": {"status": "Failure", "message": "'  + contactFld + ' : ' + contactValue + ' ' + contactFld + exc.getMessage() + '"}}'
                : '{"response": {"status": "Failure", "message": "' + exc.getLineNumber()  + ' : ' + exc.getMessage() + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Response_Body__c = jsonResponse;
            insert log;
            return;
        }catch(customException ex){
            String errMsg = String.isNotBlank(contactFld) ? 'Custom exception: ' + contactFld + ' : ' + contactValue + ' '  + ex.getLineNumber() + ' : ' + ex.getMessage() + ' : ' + ex.getStackTraceString() 
                    : 'Type exception: '+ ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString();
            system.debug(errMsg);          	
            String jsonResponse = String.isNotBlank(contactFld) ? '{"response": {"status": "Failure", "message": "'  + contactFld + ' : ' + contactValue + ' ' + contactFld + ex.getMessage() + '"}}'
            : '{"response": {"status": "Failure", "message": "' +  + ex.getLineNumber()  + ' : '  +ex.getMessage() + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            //log.Request_Body__c = result;
            log.Response_Body__c = jsonResponse;
            insert log;
            return;
        }catch(Exception ex){
            String errMsg = String.isNotBlank(contactFld) ? 'Custom exception: ' + contactFld + ' : ' + contactValue + ' '  + ex.getLineNumber() + ' : ' + ex.getMessage() + ' : ' + ex.getStackTraceString() 
                    : 'Type exception: '+ ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString();
            system.debug(errMsg);          	
            String jsonResponse = String.isNotBlank(contactFld) ? '{"response": {"status": "Failure", "message": "'  + contactFld + ' : ' + contactValue + ' ' + contactFld + ex.getMessage() + '"}}'
            : '{"response": {"status": "Failure", "message": "'  + ex.getLineNumber()  + ' : '  + ex.getMessage() + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            res.statusCode =200;
            log.Status__c = 'Failed';
            log.Response_Body__c = jsonResponse;
            insert log;
        }
    }
}