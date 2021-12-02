/**
* @author LevDigital
* @date 2021
*
* @group Service_Event__c
* @group-content ../../ApexDocContent/Service_Event__c.htm
*
* @description EventIntegrationService
*/
public with sharing class EventIntegrationService {
	@TestVisible private Map<String,List<ServiceEventField__mdt>> settings;
	@TestVisible private Map<String,List<BSO_Case_Service_Event__mdt>> caseSettings;
	private Account acct;
	private Contact con;
	public String eventType;
	private String authUserKey ='';
	public String authUserKeyRegModel='';
	private	String callToAction;
	public String buyerId = '';
	private String previousBuyerId = '';
	private	String buyerStatus = '';
	private businessCheck bizCheck;
	private Case cse;
	private boolean isCaseExisting;
	private Map<String,Task> subjectTasks;
	private Savepoint sp1;
	private static final String UPDATE_CONVERTED_LEAD_ERROR = 'DUPLICATE_VALUE';
	Map<String,String> developerNameRecordTypeIds = new Map<String,String>();

  	/*******************************************************************************************************
    * @description  main method for incoming Service Events
    * @param jsonPayload incoming payload
    * @return Error message if applicable
    */
	public EventIntegrationService(){
		settings = new Map<String,List<ServiceEventField__mdt>>();
		caseSettings = new Map<String,List<BSO_Case_Service_Event__mdt>>();
		bizCheck =new businessCheck();
		isCaseExisting = false;
		subjectTasks = new Map<String,Task>();		
		try{
			List<ServiceEventField__mdt> serviceEventFields = ServiceEventField__mdt.getall().values();
			List<BSO_Case_Service_Event__mdt> caseServiceEvents = BSO_Case_Service_Event__mdt.getall().values();
			//Get and separate mappings for Salesforce field to payload object/attribute mapping
			for(ServiceEventField__mdt serviceEventField: serviceEventFields){
				String eventType = String.valueOf(serviceEventField.EventType__c);
				
				String typeFld = String.valueOf(serviceEventField.Type__c);
				String keyType = eventType == 'Other' || String.isBlank(eventType) ? typeFld :  (String.isBlank(typeFld) || eventType == 'buyercheck') ?  eventType : eventType + typeFld;

				if(!settings.containsKey(keyType)){
					settings.put(keyType,new List<ServiceEventField__mdt>()); 
				}
				List<ServiceEventField__mdt> serviceEvtSettings = settings.get(keyType);
				serviceEvtSettings.add(serviceEventField);
				settings.put(keyType,serviceEvtSettings);
			}
			//Get and separate Case mappings
			for(BSO_Case_Service_Event__mdt caseServiceEvent: caseServiceEvents){
				String caseType = String.valueOf( caseServiceEvent.Case_Type__c);
		
				if(!caseSettings.containsKey(caseType)){
					caseSettings.put(caseType,new List<BSO_Case_Service_Event__mdt>()); 
				}
				List<BSO_Case_Service_Event__mdt> caseEvtSettings = caseSettings.get(caseType);
				caseEvtSettings.add(caseServiceEvent);
				caseSettings.put(caseType,caseEvtSettings);
			}
			//Get all of the recordTypes
			Map<String,Schema.RecordTypeInfo> recordTypeMapNames = Schema.SObjectType.Account.getRecordTypeInfosByName();
			for(String recordTypeName: recordTypeMapNames.keyset()){
				Schema.RecordTypeInfo recordTypeInfo = recordTypeMapNames.get(recordTypeName);
				developerNameRecordTypeIds.put(recordTypeInfo.developername,recordTypeInfo.recordTypeId);				
			}
			//System.debug('  EventIntegrationService: '+ isMock);
		}
		Catch(Exception e){
			String errorMessage = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMessage);
			throw new custException(errorMessage);
		}
		
	}
	/*******************************************************************************************************
    * @description main method 
	* @param eventMap - Map<String, Object> from payload from EventWebService
    * @return void
    */
	public  String sendEvents(Map<String, Object> eventMap,Boolean isMock ){	
		
		Map<String,String> parentObject = new Map<String,String>();
		String errorMessage = '';
		System.debug(' sendEvents: '+ isMock);
		try{	
			//Set savepoint when not running test mocks- only for test cases
			
			if( isMock == false || isMock == null){
				System.debug('setting savepoint:');
				sp1  = Database.setSavepoint();
			}
			System.debug('eventMap:' + eventMap);
			System.debug('settings: ' + settings.keyset());
			List<ServiceEventField__mdt> parentSettings = settings.get('parent');
			System.debug('parent settings: ' + parentSettings);			
			
			
			populateMap( eventMap,parentObject,  settings.get('parent'));
			System.debug('parentObject: ' + parentObject);			
			
			if(parentObject.containsKey('Parent_EventName')){
				eventType = parentObject.get('Parent_EventName');
				if(String.IsNotBlank(eventType)){
					eventType = eventType.toLowerCase();
				}
			}
			System.debug('*eventType: ' + eventType);
			if(parentObject.containsKey('Parent_AuthUserKey')){
				authUserKey = parentObject.get('Parent_AuthUserKey');
			}			
			System.debug('*authUserKeyParent: ' + authUserKey);
			if(parentObject.containsKey('Parent_CalltoAction')){
				callToAction = parentObject.get('Parent_CalltoAction');
			}
			System.debug('*callToAction: ' + callToAction);
			
			if(parentObject.containsKey('Parent_BuyerId')){
				buyerId = parentObject.get('Parent_BuyerId');
			}
			System.debug('*buyerId: ' + buyerId);

			if(parentObject.containsKey('Parent_BuyerStatus')){
				buyerStatus = parentObject.get('Parent_BuyerStatus');
			}
			System.debug('*buyerStatus: ' + buyerStatus);			
			if(parentObject.containsKey('Parent_AuthKeyRegModel')){
				authUserKeyRegModel = parentObject.get('Parent_AuthKeyRegModel');
			}
			System.debug('*authUserKeyRegModel: ' + authUserKeyRegModel);
			Map<String,Object> regModel;
			if( eventMap.containsKey('RegistrationModel')){
				regModel = (Map<String, Object>) eventMap.get('RegistrationModel');
				System.debug('regModel: ' + regModel);
			}			
			//Lead
			if(eventType== 'accountprofilecreate' && regModel != Null){
				errorMessage = accountProfileCreate(regModel,settings.get('accountprofilecreateLead'));				
			}else if(eventType== 'accountprofilecreate' && regModel.isEmpty()){
				throw new custException('Account Profile received but no registration model. Type: accountprofilecreate');
			}
			//Lead Convert to Account and Contact 								//PublicBuyer/2 enum
			else if(eventType== 'accountprofilecomplete' && regModel != Null && callToAction != '0' &&  callToAction !='1'){
				errorMessage =  accountProfileComplete(regModel,eventMap);					
			}else if(eventType== 'accountprofilecomplete' && regModel == Null){
				throw new custException('Account Profile received but no registration model. Type: accountprofilecomplete');
			}
			//Event equals Buyer Create and buyerstatus is inactive IIA-12- parse and create case "Buyer Services" related and any tasks if needed
			else if(eventType == 'buyercreated' && buyerstatus != '0' &&  buyerstatus != '1'){ 
				System.debug('*buyer status is inactive/0 enum');
				errorMessage = parsePayloadAndOtherEventTypes(regModel,eventMap);
			}			
			//Event Starts with upgrade IAA-44 -Do not parse but only do biz check
			else if (eventType.startsWith('upgrade')){
				System.debug('Started upgrade');
				List<Account> accts = [SELECT Id,Name,(SELECT ID FROM Contacts WHERE AuthUserKey__c=:authUserKeyRegModel LIMIT 1 ) FROM Account WHERE AuthUserKey__c=:authUserKeyRegModel For Update];
				if(!accts.isEmpty()){
					acct = accts[0];
					System.debug('acct: ' + acct.Id);
					List<Contact> cons = acct.Contacts;
					if(!cons.isEmpty()){
						con = cons[0];
						bizCheck = populateSObjectWithBusinessCheck(regModel, settings.get('buyercheck'),'LexusNexisResults',false);
						System.debug('*bizCheck: ' + bizCheck);	
						if(eventType =='upgrade-upgradecomplete'){
							AddNewCase(caseSettings.get('Upgrade LBB Review'),'Upgrade LBB Review');
							if(isCaseExisting == false){
								DMLHelper(cse,'insert',' not insert Case with Key: ' + authUserKeyRegModel + '. Type: upgrade');
							}
							//create Upgrade_Task_License always
							//if account business check then create task 		
							CreateTasks('upgrade');
						}
						
						//service event
						Service_Event__c serviceEvent = new Service_Event__c();
						populateSObject(eventMap,'Service_Event__c',serviceEvent, settings.get('Service_Event__c'));
						serviceEvent.Account__c =accts[0].Id;			
						DMLHelper(serviceEvent,'insert','Could not insert ServiceEvent with buyerId:' +authUserKeyRegModel + ' Key: ' + authUserKeyRegModel + '. Type: upgrade');
					}else{
						throw new custException('Could not find Converted Contact for authKey: ' + authUserKeyRegModel);
					}
				}
				else{
					throw new custException('Can not find Account from authUserKey: ' + authUserKeyRegModel + ' buyerId: '  + buyerId + '. Type: upgrade');
				}
				
			}
			//If buyer Id and starts with profileupdate - IIA-35 - do not parse
			//Update logic: IAA - 169 - parse profileupdate/segmentation into account fields.
			else if(String.isNotBlank(buyerId) && eventType.startsWith('profileupdate') && !eventType.contains('segmentation')){
				
				List<Account> accts  = [SELECT Id,Name,(SELECT ID FROM Contacts WHERE Is_Owner__c = TRUE LIMIT 1) FROM Account WHERE API_Buyer_Id__c=:buyerId];
				if(!accts.isEmpty()){
					acct = accts[0];
				
					System.debug('acct: ' + acct.Id);
					List<Contact> cons = acct.Contacts;
					//Don't throw error if can't find role, for case use account Id
					if(!cons.isEmpty()){
						con = cons[0];
						System.debug('contact: ' + con.Id);
					}
					//just add service event with top buyerId
					AddNewCase(caseSettings.get('Profile Update'),'Profile Update',true);
					if(isCaseExisting == false){
						DMLHelper(cse,'insert','Could not insert Case with Key: ' + buyerId + '. Type: profileupdate');	
					}					
					Service_Event__c serviceEvent = new Service_Event__c();
					populateSObject(eventMap,'Service_Event__c',serviceEvent, settings.get('Service_Event__c'));
					serviceEvent.Account__c =accts[0].Id;			
					DMLHelper(serviceEvent,'insert','Could not insert ServiceEvent with buyerId:' +buyerId + ' Key: ' + authUserKeyRegModel + '. Type: profileupdate');
				}else{
					throw new custException('Can not find Account from buyer id: ' + authUserKeyRegModel + ' buyerId: '  + buyerId + '. Type: profileupdate');
				}
			}
			else if(String.isNotBlank(buyerId) && eventType.startsWith('profileupdate') && eventType.contains(('segmentation'))){
				
				List<Account> accts  = [SELECT Id,Name,(SELECT ID FROM Contacts WHERE Is_Owner__c = TRUE LIMIT 1) FROM Account WHERE API_Buyer_Id__c=:buyerId];
				if(!accts.isEmpty()){
					acct = accts[0];
					regModel = (Map<String, Object>) eventMap.get('SegmentationInfo');
					errorMessage = parsePayloadAndOtherEventTypesByBuyerId(regModel,eventMap);
									
					Service_Event__c serviceEvent = new Service_Event__c();
					populateSObject(eventMap,'Service_Event__c',serviceEvent, settings.get('Service_Event__c'));
					serviceEvent.Account__c =accts[0].Id;			
					DMLHelper(serviceEvent,'insert','Could not insert ServiceEvent with buyerId:' +buyerId + ' Key: ' + authUserKeyRegModel + '. Type: profileupdate');
				}else{
					throw new custException('Can not find Account from buyer id: ' + authUserKeyRegModel + ' buyerId: '  + buyerId + '. Type: profileupdate');
				}
			}
			//update all other objects 
			// or  Event equals Buyer Create and Account.Is AuctionAccess = true and the buyer status is Active and Billing State = Wisconson - IAA-217
			else {
				System.debug('*Other');
				errorMessage = parsePayloadAndOtherEventTypes(regModel,eventMap);
			}
			

		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);
			errorMessage =errorMsg;
			if(sp1!=null){
				System.debug('rollback sendEvents ' + eventType);
				Database.rollback(sp1);
			}
		}
		return errorMessage;
    }
	/*******************************************************************************************************
    * @description  Adds a value to an sObject dynamically based on dataType
    * @param sobj - sObject I.E. Lead,Acccount,etc
	* @param fldName - Name of the field
	* @param fldValue - Value of the field
	* @param fldType - Datatype of the field. I.E. String
    * @return void sObject is returned because is passed by reference
    */
	public void AddFieldToSObject(sObject sobj,string fldName,object fldValue,string fldType){
		AddFieldToSObject(sobj,fldName,fldValue,null,null,fldType);
	}
	public void AddFieldToSObject(sObject sobj,string fldName,object fldValue,object fldValueTwo,string fldType){
		AddFieldToSObject(sobj,fldName,fldValue,fldValueTwo,null,fldType);
	}
	public void AddFieldToSObject(sObject sobj,string fldName,object fldValue,object fldValueTwo,object fldValueThree, string fldType){
		
		try{
			if(fldValue!=Null){
				if (fldType == 'Date'){
					//If getting datetime, truncate time	
					if(fldValue !=null){
						String strValue = String.Valueof(fldValue);
						if(strValue.indexOf('T') != -1){
							strValue = strValue.left(strValue.indexOf('T'));
							system.debug('strValue:' + strValue);
						}
						Date dt = (Date)Json.deserialize('"'+strValue+'"', Date.class);
						sobj.put(fldName, dt);
					}					
				}else if (fldType == 'Datetime') {			
					DateTime dt = (DateTime)Json.deserialize('"'+fldValue+'"', DateTime.class);
					sobj.put(fldName, dt);
				} else if (fldType == 'Checkbox') {
					Boolean b = Boolean.valueOf(fldValue);
					sobj.put(fldName, b);
				} else if (fldType == 'Integer') {
					Integer i = Integer.valueOf(fldValue);
					sobj.put(fldName, i);
				} else if (fldType == 'Double') {
					double d = double.valueOf(fldValue);
					sobj.put(fldName, d);
				} else if (fldType == 'Currency') {
					decimal d = decimal.valueOf(String.valueOf((fldValue)));
					sobj.put(fldName, d);		}                       
				else {
					//if there is more than one field that is type of string then concatenate
					if(String.isNotBlank(String.valueOf(fldValueThree))){
						System.debug('*2fldThree : ' + fldValue + ' ' + fldValueTwo + ' ' + fldValueThree);
						sobj.put(fldName, fldValue + ' ' + fldValueTwo + ' ' + fldValueThree);
					}
					else if(String.isNotBlank(String.valueOf(fldValueTwo))){
						sobj.put(fldName, fldValue + ' ' + fldValueTwo);						
					}else{
						sobj.put(fldName, String.Valueof(fldValue));
					}
				}
			}
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			String inputs = ' *fldName: ' + fldName + ' fldValue: ' + fldValue + ' fldValueTwo: ' + fldValueTwo + ' fldType: ' + fldType ;
			System.debug(errorMsg);
			throw new custException(errorMsg + inputs);
		}
		
	}
	/*******************************************************************************************************
    * @description if event type is accountprofilecreate  && callToAction =='PublicBuyer' then create a lead
    * @param regModel registration model under parent object
	* @param serviceEventFields customMetadata for type of payload
    * @return Error message if applicable
    */
	Public String accountProfileCreate(Map<String, Object> regModel,List<ServiceEventField__mdt> serviceEventFields){	
		String errorMessage = '';
		Lead ld;
		try{
			System.debug('Started accountProfileCreate');
			ld = new Lead();
			Long startTime = System.now().getTime();
			populateSObject(regModel,'Lead',ld, serviceEventFields);
			Long endTime = System.now().getTime();
			System.debug('*Lead: ' + ld);
			Long timeDiffmlseconds =endTime -startTime;
			System.debug('*TimeDiff: ' + timeDiffmlseconds + ' Milliseconds:');
			Schema.SObjectField f = Lead.Fields.AuthUserKey__c;
			Database.UpsertResult sr = Database.upsert(ld,f, false);
			if (!sr.isSuccess()) { 	
				for(Database.Error err : sr.getErrors()) {
					//Ignore update of converted lead as it will error and send back success
					if(String.valueOf(err.getStatusCode()) == UPDATE_CONVERTED_LEAD_ERROR){
						return '';
					}					
					errorMessage = errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields();  
				}
			}
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);
			errorMessage =errorMsg;
		}
		return errorMessage;
	} 
	/*******************************************************************************************************
    * @description if event type is accountprofilecomplete convert lead to account and add info to service event object
	* @param eventMap entire payload deserialized in map<string,Objects>
   	* @param regModel registration model under parent object
    * @return Error message if applicable
    */
	Public String accountProfileComplete(Map<String, Object> regModel,Map<String, Object> eventMap){	
		String errorMessage = '';	
		try{
			System.debug('Started accountProfileComplete: key: ' + authUserKeyRegModel );
			String leadId ='';
			String convertedAccountId = '';
			String convertedContactId = '';
			List<Lead> lds = [SELECT Id,IsConverted FROM Lead WHERE AuthUserKey__c=:authUserKeyRegModel];
			if(!lds.isEmpty()){
				leadId = lds[0].Id;
			}else{
				throw new custException('Could not find lead for authKey: ' + authUserKeyRegModel);
			}
			//If lead is already converted, just parse and don't throw error
			if(lds[0].IsConverted == true){
				errorMessage = parsePayloadAndOtherEventTypes(regModel,eventMap);
			}else{
				LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND APIName='Converted'];
				Database.LeadConvert lc = new database.LeadConvert();
				lc.setLeadId(leadId);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				Database.LeadConvertResult lcr = Database.convertLead(lc);
				if (lcr.isSuccess()) {
					System.debug('convert success');
					convertedAccountId = lcr.getAccountId();
					convertedContactId = lcr.getContactId();
					System.debug('getAccountId: ' + convertedAccountId);
					List<Account> accts = [SELECT Id,Name,OCR_Status__c,Business_Response_Code__c,Buyer_Promo_Code__c,Company_Name__c,API_Buyer_Id__c,RecordTypeId,
						(SELECT Id,Address_Varies_from_ID__c,Individual_Response_Code__c FROM Contacts WHERE Id=:convertedContactId) FROM Account WHERE Id=:convertedAccountId];
					if(!accts.isEmpty()){
						acct = accts[0];
						List<Contact> cons = acct.Contacts;
						if(!cons.isEmpty()){
							con = cons[0];
							//account
							populateSObject(regModel,'Account',acct, settings.get('accountprofilecompleteAccount'));
							
							
							
							System.debug('*Account: ' + acct);
							populateSObject(regModel,'Contact',con, settings.get('accountprofilecompleteContact'));
							System.debug('*Contact: ' + con);
							errorMessage = parsePayloadAndOtherEventTypes(regModel,eventMap);
							if(String.isNotBlank(errorMessage)){
								throw new custException(errorMessage);
							}
						}else{
							throw new custException('Could not find Converted Contact for authKey: ' + authUserKeyRegModel);
						}
					}
					else{
						throw new custException('Could not find Converted Account for authKey: ' + authUserKeyRegModel);
					}

				} else {
					System.debug('convert failure');
					system.debug(lcr.getErrors());	
					for(Database.Error err : lcr.getErrors()) {				
						errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() 
							: errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields();
					}	
					throw new custException('Could not Convert Lead: ' + authUserKeyRegModel + ' ' + errorMessage + '. Type: accountProfileComplete');		
				}
			}
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);	

			if(sp1 != null){
				System.debug('rollback accountProfileComplete');
				Database.rollback(sp1);
			}
			errorMessage =errorMsg;
		}
		return errorMessage;
	} 
	
	/*******************************************************************************************************
    * @description if event type is other just populate all custom metadata fields marked as other
	* @param regModel registration model under parent object	
	* @param eventMap entire payload deserialized in map<string,Objects>
    * @return Error message if applicable
    */
	Public String parsePayloadAndOtherEventTypes(Map<String, Object> regModel,Map<String, Object> eventMap){	

		String errorMessage = '';
		try{
			System.debug('started parsePayloadAndOtherEventTypes');
			//System.debug('Account Id: ' + acct.Id);
			System.debug('Account : ' + acct + ' eventType: ' + eventType);			
			if(acct == null){
				System.debug('Queried Account ');				

				List<Account> accts = [SELECT Id,Name,OCR_Status__c,Business_Response_Code__c,Buyer_Promo_Code__c,Company_Name__c,API_Buyer_Id__c,RecordTypeId,Is_AuctionAccess_User__c,
					(SELECT ID,Address_Varies_from_ID__c,Individual_Response_Code__c FROM Contacts WHERE AuthUserKey__c=:authUserKeyRegModel LIMIT 1) FROM Account WHERE AuthUserKey__c=:authUserKeyRegModel For Update];
				if(!accts.isEmpty() ){
					acct = accts[0];
					System.debug('found Account: ' + acct.Id);
					previousBuyerId = acct.API_Buyer_Id__c;
					System.debug('previousBuyerId: ' + acct.API_Buyer_Id__c);
					List<Contact> cons = acct.Contacts;					
					if(cons.isEmpty()){
						throw new custException('Can not find Contact from authUserKey: ' + authUserKeyRegModel + ' buyerId: '  + buyerId + ' acctId: ' + acct.Id);
					}else{
						con = cons[0];
					}	
				}else{
					throw new custException('Can not find Account from authUserKey: ' + authUserKeyRegModel + ' buyerId: '  + buyerId);
				}
			}
			if(eventType== 'accountprofilecomplete'){
				//IAA-118 - Account RT is set to Prospect Buyer
				acct.recordTypeId = developerNameRecordTypeIds.get('Prospect_Buyer');
				System.debug('*prospect buyer Rt: ' + acct.recordTypeId);
			}
			populateSObject(regModel,'Account',acct, settings.get('Account'));
			populateSObject(regModel,'Contact',con, settings.get('Contact'));

			//So far only do biz check on authKey
			if(String.isBlank(buyerId)){
				bizCheck = populateSObjectWithBusinessCheck(regModel, settings.get('buyercheck'),'LexusNexisResults',true);
				System.debug('*bizCheck: ' + bizCheck);
				System.debug('*biz Contact: ' + con);
				System.debug('*biz Account: ' + acct);
				if(eventType == 'idbusinessbackgroundcheck'){
					if(bizCheck.contactResponseCode == '3' &&  bizCheck.hasContact == true){								
						AddNewCase(caseSettings.get('New Reg BG Check'),'New Reg BG Check');							
					}
					else if(bizCheck.accountResponseCode == '3' &&  bizCheck.hasAccount == true){									
						AddNewCase(caseSettings.get('New Reg Biz Check'),'New Reg Biz Check');													
					}
				}
			}
			//If accountprofilecomplete don't create any cases or tasks
			if(eventType !='accountprofilecomplete'){
				//If EventType equals buyercreated and buyer status is inactive/NA 
				if(eventType == 'buyercreated' && buyerstatus != '0' &&  buyerstatus != '1'){
					if(acct.Is_AuctionAccess_User__c == true){
						AddNewCase(caseSettings.get('New Auction Access Review'),'New Auction Access Review');
					}else{			
						AddNewCase(caseSettings.get('New Reg Review'),'New Reg Review');									
					}
				}//Event equals Buyer Create and Account.Is AuctionAccess = true and the buyer status is Active and Billing State = Wisconson - IAA-217
				else if (eventType == 'buyercreated' && (buyerstatus == '0' ||  buyerstatus == '1') && acct.Is_AuctionAccess_User__c == true && acct.ShippingState == 'WI'){
					AddNewCase(caseSettings.get('New Auction Access Review - Wisconsin'),'New Auction Access Review - Wisconsin');
				}
				
				if(cse !=null){
					if(isCaseExisting == false){
						String successId = DMLHelper(cse,'insert','Could not insert Case with Key: ' + authUserKeyRegModel);
					}
					//check to see if tasks need to be created iaa-8,iaa-9,iaa-12 then create tasks for iaa-13	
					CreateTasks('registrationInfo');				
				}
			}
			List<License__c> licenses = new List<License__c>();
			List<Document__c> documents = new List<Document__c>();
			System.debug('Got here!' + acct.recordTypeId + ' : ' + developerNameRecordTypeIds.get('Prospect_Buyer') + ' previousBuyerId: ' +previousBuyerId +  ' buyerId : ' + buyerId);
			Boolean getRelatedRecords = false;
			//IAA-78 when Account RT is Prospect Buyer or Buyer Account AND the Buyer Id (API_Buyer_ID) is first populated
			//the system should remove all licenses and documents and then the system should get: licenses and documents and notes
			if((acct.recordTypeId == developerNameRecordTypeIds.get('Prospect_Buyer') || acct.recordTypeId == developerNameRecordTypeIds.get('Buyer_Account')) && String.isBlank(previousBuyerId) && String.isNotBlank(String.Valueof(acct.API_Buyer_Id__c))){				
				
				List<Document__c> docs = [SELECT Id,Name,Account__c FROM Document__c WHERE Account__c =: acct.Id LIMIT 10000];
				List<License__c> liczs = [SELECT Id,Name,Account__c FROM License__c WHERE Account__c =: acct.Id LIMIT 10000];
				//go delete documents and change account status	
				string errorMsgDocuments = Utils.DMLDeleteHelperList(docs,'Could not delete documents: ');
				if(String.isNotBlank(errorMsgDocuments)){
					throw new custException(errorMsgDocuments);
				}				
				string errorMsgLicenses = Utils.DMLDeleteHelperList(liczs,'Could not delete licenses: ');
				if(String.isNotBlank(errorMsgLicenses)){
					throw new custException(errorMsgLicenses);
				}
				getRelatedRecords = true;
				
			}else{
				//If fields have Licenses
				licenses = populateSObjects(regModel,'License__c','BusinessPayload.Licenses', settings.get('License__c'),String.Valueof(acct.id),'Account__c');
				System.debug('licenses' + licenses.size());
				if(!licenses.isEmpty()){
					System.debug('*licenses' +licenses[0]);
				}

				//If fields have Documents
				documents = populateSObjects(regModel,'Document__c','Files',settings.get('Document__c'),String.Valueof(acct.id),'Account__c');
				System.debug('documents' + documents.size());
				if(!documents.isEmpty()){
					System.debug('*documents' +documents[0]);
				}
			}
			

			//service event					
			Service_Event__c serviceEvent = new Service_Event__c();
			populateSObject(eventMap,'Service_Event__c',serviceEvent, settings.get('Service_Event__c'));
			serviceEvent.Account__c =acct.id;
			System.debug('*Service Event: ' + serviceEvent);
			System.debug('*acct:' + acct.Name + ' : ' + acct.recordTypeId);
			DMLHelper(acct,'update','Could not update Account: ' + authUserKeyRegModel);
			DMLHelper(con,'update','Could not update Contact: ' + authUserKeyRegModel);
			if(!licenses.isEmpty()){
				DMLHelperUpsertList(licenses,'File_Identifier__c','License__c','Could not insert Licenses: ' + authUserKeyRegModel);
			}
			if(!documents.isEmpty()){
				DMLHelperUpsertList(documents,'Document_Key__c','Document__c','Could not insert Documents: ' + authUserKeyRegModel);
			}
			DMLHelper(serviceEvent,'insert','Could not insert Service Event: ' + authUserKeyRegModel);
			//IAA-78 - continued 
			if(getRelatedRecords == true){
				AccountTriggerHelper.getBuyerLicenses(acct);
				AccountTriggerHelper.getBuyerDocuments(acct);
				AccountTriggerHelper.getAccountAPIs(acct,new List<String>{'GetBuyerNotes'});
			}

		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);
			errorMessage =errorMsg;	
			if(sp1 != null){
				System.debug('*Rollback Other');
				Database.rollback(sp1);		
			}
		}
		return errorMessage;
	} 

	/********************************
 	***********************************************************************
    * @description if event type is other just populate all custom metadata fields marked as other.
		Similar to the parsePayloadAndOtherEventTypes, except this one is used for profileupdate - segmentation.
	* @param regModel registration model under parent object	
	* @param eventMap entire payload deserialized in map<string,Objects>
    * @return Error message if applicable
    */
	Public String parsePayloadAndOtherEventTypesByBuyerId(Map<String, Object> regModel,Map<String, Object> eventMap){	

		String errorMessage = '';
		try{
			System.debug('started parsePayloadAndOtherEventTypesByBuyerId');	
			if(acct == null){			
				List<Account> accts = [SELECT Id,Name,OCR_Status__c,Business_Response_Code__c,Buyer_Promo_Code__c,Company_Name__c,API_Buyer_Id__c,RecordTypeId,Is_AuctionAccess_User__c,
					(SELECT ID,Address_Varies_from_ID__c,Individual_Response_Code__c FROM Contacts WHERE AuthUserKey__c=:authUserKeyRegModel LIMIT 1) FROM Account WHERE API_Buyer_Id__c=:buyerId For Update];
				
				if(!accts.isEmpty() ){
					acct = accts[0];
					System.debug('found Account: ' + acct.Id);
					previousBuyerId = acct.API_Buyer_Id__c;
					System.debug('previousBuyerId: ' + acct.API_Buyer_Id__c);
					List<Contact> cons = acct.Contacts;					
					if(cons.isEmpty()){
						throw new custException('Can not find Contact from buyer id: ' + authUserKeyRegModel + ' buyerId: '  + buyerId + ' acctId: ' + acct.Id);
					}else{
						con = cons[0];
					}	
				}else{
					throw new custException('Can not find Account from buyer id: ' + authUserKeyRegModel + ' buyerId: '  + buyerId);
				}
			}
			populateSObject(regModel,'Account',acct, settings.get('profileupdate - segmentationAccount'));
			DMLHelper(acct,'update','Could not update Account: ' + authUserKeyRegModel);
			// populateSObject(regModel,'Contact',con, settings.get('Contact')); In the future, we may want to parse contact data from the payload. For now, it's only the account.
			return errorMessage;
	
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);
			errorMessage =errorMsg;	
			if(sp1 != null){
				System.debug('*Rollback Other');
				Database.rollback(sp1);		
			}
		}
		return errorMessage;
	} 

	/*******************************************************************************************************
    * @description Dynamically populates a Case based on custom metadata
	* @param caseEvents - custom metadata list that is specific to case being created
	* @param caseType - type of case being added
    * @return void
    */
	Public void AddNewCase(List<BSO_Case_Service_Event__mdt> caseEvents,String caseType){
		AddNewCase(caseEvents,caseType,false);
	}
	Public void AddNewCase(List<BSO_Case_Service_Event__mdt> caseEvents,String caseType,Boolean appendEventNameToSubject){
		cse = new Case();
		for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
			if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
				String lookupType = caseEvent.Field_API__c;					
				if(lookupType == 'Contact'){
					if(eventType.startsWith('profileupdate') && con == null){
						cse.put('AccountId',acct.Id);						
					}else{
						cse.put(caseEvent.Field_API__c + 'Id',con.Id);
					}
				}else if(lookupType == 'Account'){
					cse.put(caseEvent.Field_API__c + 'Id',acct.Id);
				}					
			}
			else if(caseEvent.Field_API__c == 'RecordTypeId'){
					System.debug('RecordType: ' + caseEvent.Value__c);
					Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
					cse.put('RecordTypeId',recordTypeId);
			}
			else if(caseEvent.Field_API__c == 'Subject' && appendEventNameToSubject == true){
				cse.put(caseEvent.Field_API__c,caseEvent.Value__c + ' ' + eventType);		
			}
			else{
				cse.put(caseEvent.Field_API__c,caseEvent.Value__c);							
			}
		}
		System.debug('*case: ' + caseType + ' : ' + cse);
		//If there is a case already open related to the account, Status <> Closed,Case Origin = Auction Center and same subject do not create a new case
		List<Case> existingCases = new List<Case>();
		if(String.isNotBlank(cse.Subject)){
			if(String.isBlank(buyerId)){
			//if(String.isBlank(case.WhoId)){
				existingCases= [SELECT Id,OwnerId FROM CASE WHERE STATUS != 'Closed' AND contactId=:con.Id AND Origin = 'Auction Center' AND Subject =: cse.Subject LIMIT 1];
			}else{
				 existingCases = [SELECT Id,OwnerId FROM CASE WHERE STATUS != 'Closed' AND contactId=:con.Id AND Origin = 'Auction Center' AND Subject =: cse.Subject LIMIT 1];				
			}
			if(existingCases.size() > 0){
				isCaseExisting = true;
				cse = existingCases[0];
			}
		}else{
			throw new custException('There is not a subject for case: ' + cse + ' for Key ' + authUserKeyRegModel + ' BuyerId ' + buyerId);
		}
		System.debug('Is Case Existing: ' +isCaseExisting);
	}

	/*******************************************************************************************************
    * @description Creates new tasks based on type from custom metadata
	* @param type - registrationInfo or upgrade
    * @return void
    */
	Public void CreateTasks(String type){
		System.debug('started Create Tasks:' + type + ' caseId: ' + cse.Id);
		//go get case again since caseOwner might be different due to omni channel case assignments
		List<Case> newCases  = [SELECT Id,OwnerId FROM Case WHERE  Id=: cse.Id];
		if(newCases.size() != 1){
			throw new custException('Could not case created ' + cse.Id +' for Auth Key:' + authUserKeyRegModel);
		}
		//registration info
		if(type == 'registrationInfo'){
			System.debug('*acct.OCR_Status__c: ' + acct.OCR_Status__c);
			System.debug('*con.Address_Varies_From_Id__c: ' +con.Address_Varies_From_Id__c);
			System.debug('*con.Individual_Response_Code__c: ' + con.Individual_Response_Code__c);
			System.debug('*acct.Company_Name__c: ' + acct.Company_Name__c);
			System.debug('*acct.Business_Response_Code__c: ' + acct.Business_Response_Code__c);
			System.debug('*acct.Buyer_Promo_Code__c: ' + acct.Buyer_Promo_Code__c);
			if(acct.OCR_Status__c == '2' || acct.OCR_Status__c =='3' ){ 
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_OCR');				
			}
			if(con.Address_Varies_From_Id__c == true){
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_Residence_Address');	
			}
			if(con.Individual_Response_Code__c  == '1' || con.Individual_Response_Code__c  == '2' || con.Individual_Response_Code__c  == '3' && eventType != 'buyercreated' ){
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_BG_Check');	
			}
			if(String.isNotBlank(String.valueof(acct.Company_Name__c))){
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_License');
			}
			if(acct.Business_Response_Code__c  == '1' || acct.Business_Response_Code__c  == '2' || acct.Business_Response_Code__c  == '3' && eventType != 'buyercreated'){
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_Biz_Check');	
			}
			if(String.isNotBlank(String.valueof(acct.Buyer_Promo_Code__c))){
				AddNewTask('New Reg (For Tasks)','New_Reg_Task_Promo_Code');				
			}
		}
		//upgrade
		else if(type == 'upgrade'){				
			AddNewTask('Upgrade (For Tasks)','Upgrade_Task_License');
			if(bizCheck.accountResponseCode == '3'){
				AddNewTask('Upgrade (For Tasks)','Upgrade_Task_Biz_Check');
			}
		}	
		System.debug('tsks: ' + subjectTasks.size());
		//If there is a task already open with the same subject and related to same case, do not create a new one
		List<Task> existingTasks= [SELECT Id,Subject FROM Task WHERE STATUS != 'Completed' AND whatId=:cse.Id AND Subject IN:subjectTasks.keyset()];
		for(Task existingTask:existingTasks){
			if(subjectTasks.containsKey(existingTask.subject)){
				System.debug('Removing current task: ' + subjectTasks.remove(existingTask.subject));
			}
		}
		if(!subjectTasks.isEmpty()){
			DMLHelperList(subjectTasks.values(),'insert','Could not insert Tasks with Key: ' + authUserKeyRegModel + '. Type: upgrade');
		}
	}
	/*******************************************************************************************************
    * @description Creates new task base on type from custom metadata
	* @param type - registrationInfo or upgrade
	* @param taskName - Developer Name of custom metadata for task Name
    * @return void
    */
	Public void AddNewTask(String taskType,String taskName){
		Task tsk = new Task();
		String subject;
		List<BSO_Case_Service_Event__mdt> taskEvents = caseSettings.get(taskType);
		for(BSO_Case_Service_Event__mdt taskEvent:taskEvents){
			
			if(taskEvent.Field_API__c == 'RecordTypeId'){
					System.debug('Task RecordType: ' + taskEvent.Value__c);
					Id recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(taskEvent.Value__c).getRecordTypeId();
					tsk.put('RecordTypeId',recordTypeId);
			}
			else if(taskEvent.Field_API__c == 'ActivityDate'){
				String val = taskEvent.Value__c;
				if(val.contains('TODAY()')){
					val = val.right(val.length() -8);
					val = val.trim();
					Integer today = Integer.valueOf(val);
					System.debug('today: ' + today);
					tsk.put(taskEvent.Field_API__c,System.Today().addDays(today));
				}
			}
			else if(taskEvent.Field_API__c == 'WhatId'){
				String lookupValue = taskEvent.Lookup_Value__c;
				if( taskEvent.Lookup_Value__c == 'Case'){
					tsk.put(taskEvent.Field_API__c, cse.Id);
				}else if( taskEvent.Lookup_Value__c == 'Account'){
					tsk.put(taskEvent.Field_API__c, cse.Id);
				}
			}
			else if(taskEvent.Field_API__c == 'WhoId'){
				if( taskEvent.Lookup_Value__c == 'Contact'){
					tsk.put(taskEvent.Field_API__c,con.Id);
				}
			}
			else if(taskEvent.Field_API__c == 'Subject' && taskEvent.DeveloperName == taskName){
				System.debug('Tasks Subject: ' + taskEvent.DeveloperName + ' task Name ' + taskName);				
				tsk.put(taskEvent.Field_API__c,taskEvent.Value__c);	
				subject = taskEvent.Value__c;
			}
			else if(taskEvent.Field_API__c != 'Subject'){				
				tsk.put(taskEvent.Field_API__c,taskEvent.Value__c);	
			}
		}
		if(String.isBlank(subject)){
			throw new CustException('Task subject is blank: ' + tsk);
		}else{
			System.debug('subject: ' + subject + ' task: ' + tsk);
			subjectTasks.put(subject,tsk);
		}

	}

	/*******************************************************************************************************
    * @description Reuseable function for DML for sObject
	* @param sobj sObject
	* @param dmlType insert or update
	* @param errorMessage errormessage
    * @return void
    */
	Public String DMLHelper(sObject sobj,String dmlType,String errorMessage){
		String successId;
		Database.SaveResult sr;
		if(dmlType == 'insert'){
			sr =  Database.insert(sobj,false);
		}else if(dmlType == 'update'){
			sr= Database.update(sobj,false);
		}
		
		if(sr.isSuccess()) {
			successId = sr.getId();
		}
		else{
			for(Database.Error err : sr.getErrors()) {				
				errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobj
					: errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobj;
			}		
			throw new custException(errorMessage);	
		}
		return successId;
	}
	/*******************************************************************************************************
    * @description Reuseable function for DML for List<sObject>
	* @param sobj List<sObject>
	* @param dmlType insert or update
	* @param errorMessage errormessage
    * @return list of successful Ids
    */
	Public Set<String> DMLHelperList(List<sObject> sobjs,String dmlType,String errorMessage){		
		Set<String> returnedIds = new Set<String>();
		Database.SaveResult[] srList;
		if(dmlType == 'insert'){
			srList =  Database.insert(sobjs,false);
		}else if(dmlType == 'update'){
			srList= Database.update(sobjs,false);
		}
		Boolean hasError =false;
		for(Integer i=0;i<srList.size();i++){
			if (!srList.get(i).isSuccess()) {
				if(hasError==false){
					hasError = true;
				}
				for(Database.Error err :srList.get(i).getErrors()) {				
					errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobjs.get(i)
						: errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobjs.get(i);
				}				
				//throw new custException(errorMessage);	
			}else{
				String successId = srList.get(i).getId();
				if(String.IsNotBlank(successId)){
					returnedIds.add(successId);
				}
			}
		}
		if(hasError == true){
			System.debug('*hasError' + hasError);
			throw new custException(errorMessage);	
		}
		return returnedIds;
	}
	/*******************************************************************************************************
    * @description Reuseable function for DML for Upserting List<sObject>
	* @param sobj List<sObject>
	* @param dmlType insert or update
	* @param errorMessage errormessage
    * @return list of successful Ids
    */
	Public Set<String> DMLHelperUpsertList(List<sObject> sobjs,String upsertField,String objType,String errorMessage){		
		Set<String> returnedIds = new Set<String>();
		Schema.SObjectField f =Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap().get(upsertField);

		Database.UpsertResult[] srList =Database.upsert(sobjs,f,false);		
		Boolean hasError =false;
		for(Integer i=0;i<srList.size();i++){
			if (!srList.get(i).isSuccess()) {
				if(hasError==false){
					hasError = true;
				}
				for(Database.Error err :srList.get(i).getErrors()) {				
					errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobjs.get(i)
						: errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  sobjs.get(i);
				}				
				//throw new custException(errorMessage);	
			}else{
				String successId = srList.get(i).getId();
				if(String.IsNotBlank(successId)){
					returnedIds.add(successId);
				}
			}
		}
		if(hasError == true){
			System.debug('*hasError' + hasError);
			throw new custException(errorMessage);	
		}
		return returnedIds;
	}
	/*******************************************************************************************************
    * @description if populateSObject with configuration
   	* @param regModel registration model under parent object	
	* @param sObjecttype as string 'Account'
	* @param sobj actual sObject
	* @param serviceEventFields customSettings for mappings  
    * @return void
    */
	Public void populateSObject(Map<String, Object> regModel,String sobjectType,sObject sobj, List<ServiceEventField__mdt> serviceEventFields){	
		
		String errorMessage = '';
		try{
			for(ServiceEventField__mdt serviceEventField: serviceEventFields){
				String apiField =  serviceEventField.Field__c;
				List<String> apiFields = New List<String>();
				List<String> apiFieldsTwo = New List<String>();
				List<String> apiFieldsThree = New List<String>();
				if (String.isNotBlank(apiField)) {
					apiFields = apiField.split('\\.');
				}else if(serviceEventField.DefaultValue__c == Null &&  serviceEventField.ConcatenateFields__c == Null){
					throw new custException('Configuration is incorrect for type: ' + sobjectType + '. Please check the configuration.' + serviceEventField.label);
				}
				if (String.isNotBlank(serviceEventField.FieldTwo__c)) {
					apiFieldsTwo = serviceEventField.FieldTwo__c.split('\\.');
				}
				if (String.isNotBlank(serviceEventField.FieldThree__c)) {
					apiFieldsThree = serviceEventField.FieldThree__c.split('\\.');
				}
				//if size =1 then just get the attribute
				if(apiFields.size() <=1){
					if(serviceEventField.DataType__c == 'RecordType'){
						System.debug('RecordType: ' + serviceEventField.DefaultValue__c);
						Id recordTypeId =  Schema.getGlobalDescribe().get(sobjectType).getDescribe().getRecordTypeInfosByDeveloperName().get(serviceEventField.DefaultValue__c).getRecordTypeId();
						sobj.put('RecordTypeId',recordTypeId);
					}else{
						Object obj = regModel.get(apiField);
						obj =  String.isBlank(String.valueOf(obj)) ? serviceEventField.DefaultValue__c : obj;	
						AddFieldToSObject(sobj,serviceEventField.Label,obj,serviceEventField.DataType__c);
					}
				}
				//if size =2 then go get the child map first and then get the attribute
				else if(apiFields.size() ==2){					
					
					Map<String, Object> childObjectMap = (Map<String, Object>) regModel.get(apiFields[0]);
					if(childObjectMap != Null){
					Object obj = childObjectMap.get(apiFields[1]);
						obj = obj == Null ? serviceEventField.DefaultValue__c : obj;
						if (String.isNotBlank(serviceEventField.FieldTwo__c)) {
							AddFieldToSObject(sobj,serviceEventField.Label,childObjectMap.get(apiFields[1]), childObjectMap.get(apiFieldsTwo[1]),serviceEventField.DataType__c);
						}else{
							AddFieldToSObject(sobj,serviceEventField.Label,childObjectMap.get(apiFields[1]),serviceEventField.DataType__c);
						}
					}
				}	
				//if size =3 then go get the grandchild map or list first and then get the attribute
				else if(apiFields.size() ==3){
					Object parentobj = regModel.get(apiFields[0]);
					String objTopType = Utils.returnType(parentobj);
					if(objTopType == 'Map<String,Object>'){
						Map<String, Object> childObject = (Map<String, Object>) parentobj;
						if(childObject != Null){
							Object grandChildObject = childObject.get(apiFields[1]);
							if(grandChildObject != Null){
								String objType = Utils.returnType(grandChildObject);
								if(objType == 'Map<String,Object>'){
									Map<String, Object> grandChildMap = (Map<String, Object>)childObject.get(apiFields[1]);
									if (String.isNotBlank(serviceEventField.FieldThree__c)) {
										System.debug('*three ' + apiFields[2] + ' : ' + apiFieldsTwo[2] + ' : ' + apiFieldsThree[2]);
										AddFieldToSObject(sobj,serviceEventField.Label,grandChildMap.get(apiFields[2]),grandChildMap.get(apiFieldsTwo[2]),grandChildMap.get(apiFieldsThree[2]),serviceEventField.DataType__c);
									}else{
										AddFieldToSObject(sobj,serviceEventField.Label,grandChildMap.get(apiFields[2]),serviceEventField.DataType__c);
									}
								}
							}
						}
					}
					
				}							
			}			
			System.debug('*' +sobjectType + ': ' + sobj);			
		}
		
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMsg);
			errorMessage =errorMsg;
			throw new  custException(errorMsg);
		}
		 
	}
	/*******************************************************************************************************
    * @description if populates Account and Contact with Business and Individual Check information dynamically
   	* @param regModel registration model under parent object	
	* @param serviceEventFields customSettings for mappings  
	* @param businessCheckPath  //LexusNexisResults
    * @return Custom Class with infor for business check used later for case creation
    */
	Public businessCheck populateSObjectWithBusinessCheck(Map<String, Object> regModel, List<ServiceEventField__mdt> serviceEventFields,string businessCheckPath,boolean populateSObjects){
		String newLine = '\n' ;
		
		String errorMessage='';
		try{
			Object parentobj = regModel.get(businessCheckPath);			
			String objTopType = Utils.returnType(parentobj);
			if(objTopType == 'List<Object>'){
				List<Object> childObjectList =  (List<Object>) parentobj;
				//loop through list and can have individual = contact or business user type = account
				for(Object ob:childObjectList){
					String usertype = '';
					String respCode = '';
					Map<String, Object> grandChildMap = (Map<String, Object>)ob;
					for(String grandChild:grandChildMap.keySet()){
						if(grandChild == 'UserType'){
							userType =String.valueof(grandChildMap.get(grandChild));
						}else if(grandChild == 'ResponseCode'){
							
							respCode =String.valueof(grandChildMap.get(grandChild));
							System.debug('*ResponseCode:' + respCode);
						}							
					}
					userType = usertype == '1' ? 'Contact' : usertype == '2' ? 'Account' : usertype; //Individual:1 Enum //Business:2 Enum
					if(String.isNotBlank(usertype)){
						if(usertype == 'Contact'){
							bizCheck.hasContact = true;
						}if(usertype == 'Account'){
							bizCheck.hasAccount = true;
						}						
						if(usertype == 'Contact' && String.isNotBlank(respCode)){
							bizCheck.contactResponseCode = respCode;
						}else if(usertype == 'Account' && String.isNotBlank(respCode)){
							bizCheck.accountResponseCode = respCode;
						}
						Map<String,ServiceEventField__mdt> eventFields = new Map<String,ServiceEventField__mdt>();
						for(ServiceEventField__mdt serviceEventField: serviceEventFields){
							eventFields.put(serviceEventField.Type__c + '|' + serviceEventField.Field__c, serviceEventField);
							System.debug('serviceKey ' + serviceEventField.Type__c + '|' + serviceEventField.Field__c);
						}
						if(populateSObjects == true){
							for(String grandChild:grandChildMap.keySet()){
								Object grandChildObject = grandChildMap.get(grandChild);
								String grandChildType = Utils.returnType(grandChildObject);
								System.debug('grandChild ' + grandChild + ' : ' + grandChildType); 
								List<String> concatenateFields = new List<String>();
								String concatenateValue = '';

								string key = usertype + '|' +  grandChild;
								System.debug('*key ' + key);
								ServiceEventField__mdt serviceEventField;
								if(eventFields.containsKey(key)){
									//get serviceFieldMap type + Field
									serviceEventField = eventFields.get(key);
									String concat =String.valueOf(serviceEventField.ConcatenateFields__c);
									if(String.isNotBlank(concat)){
										concatenateFields = concat.split(',');
									}
									//System.debug('*concatenateFields ' + concatenateFields );
								}
								if(grandChildType != 'Map<String,Object>' && grandChildType != 'List<Object>'){
									if(eventFields.containsKey(key)){									
										System.debug('adding to= ' + usertype + ' : ' + grandChildObject);
										if(usertype == 'Account'){
											AddFieldToSObject(acct,serviceEventField.Label,grandChildObject,serviceEventField.DataType__c);
										}else{
											AddFieldToSObject(con,serviceEventField.Label,grandChildObject,serviceEventField.DataType__c);
										}								
									}								
								}
								else if(grandChildType == 'Map<String,Object>'){
									Map<String, Object> greatGrandChildMap = (Map<String, Object>)grandChildObject;
									for(String greatGrandChild:greatGrandChildMap.keySet()){
										
										Object greatGrandChildObject = greatGrandChildMap.get(greatGrandChild);
										String greatGrandChildType = Utils.returnType(greatGrandChildObject);
										System.debug('*greatGrandChild Map ' + greatGrandChild + ' type: ' + greatGrandChildType);
										string greatGrandChildkey = usertype + '|' +  greatGrandChild;
										System.debug('*key Map ' + greatGrandChildkey);
										ServiceEventField__mdt greatGrandChildServiceEventField;
										if(eventFields.containsKey(greatGrandChildkey)){
											greatGrandChildServiceEventField = eventFields.get(greatGrandChildkey);
										}
										if(greatGrandChildType != 'Map<String,Object>' && greatGrandChildType != 'List<Object>'){
											System.debug('*greatGrandChild string');
											//System.debug('*greatGrandChild got here string ' + greatGrandChildServiceEventField);
											//if just regular string field add to account or contact
											if(greatGrandChildServiceEventField != null){	
												if(String.isBlank(String.valueOf(greatGrandChildServiceEventField.ConcatenateFields__c))){
													//System.debug('adding to= ' + usertype + ' : ' + greatGrandChildObject + ' : ' + greatGrandChildServiceEventField.Label + ' : ' + greatGrandChildServiceEventField.DataType__c);
													if(usertype == 'Account'){
														AddFieldToSObject(acct,greatGrandChildServiceEventField.Label,greatGrandChildObject,greatGrandChildServiceEventField.DataType__c);
													}else{
														AddFieldToSObject(con,greatGrandChildServiceEventField.Label,greatGrandChildObject,greatGrandChildServiceEventField.DataType__c);
													}													
												} 					
											}
											if( concatenateFields.contains(greatGrandChild)){
												concatenateValue = String.isBlank(concatenateValue) ? greatGrandChild + ' : ' + String.valueOf(greatGrandChildObject) : concatenateValue + newLine + greatGrandChild + ' : ' + String.valueOf(greatGrandChildObject);
											}									
										}else if(greatGrandChildType == 'List<Object>'){
											List<Object> greatGreatGrandChildList = (List<Object>)greatGrandChildObject;
											for(Object greatGreatGrandChildObj:greatGreatGrandChildList ){
												System.debug('*greatGreatGrandChildObj ' + greatGreatGrandChildObj);
												String greatGreatGrandChildObjType = Utils.returnType(greatGreatGrandChildObj);	
												System.debug('*greatGreatGrandChildObjType ' + greatGreatGrandChildObjType);											
												if(greatGreatGrandChildObjType == 'Map<String,Object>'){													
													Map<String, Object> greatGreatGrandChildMap = (Map<String, Object>)greatGreatGrandChildObj;
													for(String greatGreatGreatGrandChild:greatGreatGrandChildMap.keySet()){
														Object greatGreatGreatGrandChildObj = greatGreatGrandChildMap.get(greatGreatGreatGrandChild);
														String keyField = greatGrandChild + '.' +greatGreatGreatGrandChild;
														System.debug('*greatGreatGrandChildKeyField: ' + keyField);
														System.debug('*greatGreatGrandChildKeyField Contains:' + concatenateFields.contains(keyField));
														if( concatenateFields.contains(keyField)){	
															concatenateValue = String.isBlank(concatenateValue) ? greatGreatGreatGrandChild + ' : ' + String.valueOf(greatGreatGreatGrandChildObj) : concatenateValue + newLine + greatGreatGreatGrandChild + ' : ' + String.valueOf(greatGreatGreatGrandChildObj);
														}
													}

												}
											}
										}
										if(String.isNotBlank(concatenateValue)){
											System.debug('*concatenateValues ' + concatenateValue);
											if(usertype == 'Account'){
												AddFieldToSObject(acct,serviceEventField.Label,concatenateValue,'String');
											}else{
												AddFieldToSObject(con,serviceEventField.Label,concatenateValue,'String');
											}	
										}
									}
								}
							}
						}
					}
				}
			}
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMsg);
			errorMessage =errorMsg;
			bizCheck.errorMessage = errorMsg;
		}
		return bizCheck;
	}
	Public class businessCheck{
		Boolean hasContact =false;
		Boolean hasAccount = false;
		String contactResponseCode;
		String AccountResponseCode;
		String errorMessage;
	}
	/*******************************************************************************************************
    * @description populate List of SObjects with configuration
   	* @param regModel registration model under parent object	
	* @param sObjecttype as string 'Account'
	* @param path path to sobjects in payload
	* @param serviceEventFields customSettings for mappings 
	* @param relatedToId Id that new Sobjects with be related to. I.E. Licenses are related to Accounts
	* @param relatedToApiName name of lookup or masterdetail field
    * @return List<Sobject>
    */
	Public  List<sObject> populateSObjects(Map<String, Object> regModel,String sobjectType,String path, List<ServiceEventField__mdt> serviceEventFields,String relatedToId,string relatedToApiName){	
		String errorMessage = '';
		List<sObject> sobjList = new List<sObject>();
		List<String> apiFields = New List<String>();
		List<Object> objListFromPayload = new List<Object>();
		try{
			System.debug('serviceEventFields' + serviceEventFields);
			apiFields = path.split('\\.');
			if(apiFields.size() ==1){
				Object obj = regModel.get(apiFields[0]);
				String objType = Utils.returnType(obj);
				if(objType == 'List<Object>'){
					objListFromPayload = (List<Object>)obj;
					for(Object obectt:objListFromPayload){
						//Create new License or Document
						sObject sObj = Schema.getGlobalDescribe().get(sobjectType).newSObject();
						sObj.put( relatedToApiName,relatedToId);
						sobjList.add(sObj);
						System.debug('sObj' + sObj);
					}					
					if(objListFromPayload.isEmpty()){
						return sobjList;
					}					
				}
				else{
					return sobjList;
				}

			}
			else if(apiFields.size() ==2){
				Map<String, Object> obj = (Map<String, Object>) regModel.get(apiFields[0]);
				if(obj != Null){
					Object childObject = obj.get(apiFields[1]);
					String objType = Utils.returnType(childObject);
					if(objType == 'List<Object>'){
						objListFromPayload = (List<Object>)childObject;
						for(Object obectt:objListFromPayload){
							//Create new License or Document
							sObject sObj = Schema.getGlobalDescribe().get(sobjectType).newSObject();
							sObj.put( relatedToApiName,relatedToId);
							sobjList.add(sObj);
							System.debug('sObj' + sObj);
						}
						if(objListFromPayload.isEmpty()){
							return sobjList;
						}					
					}
					else{
						return sobjList;
					}
				}
			}
			for(Integer i=0;i<sobjList.size();i++){				
				Map<String,Object> objectFromPayload = (Map<String,Object>)objListFromPayload[i];
				Map<String,String> masterPickValues= getAnyMasterPickListValues(objectFromPayload,serviceEventFields);
				System.debug('masterPickValues' + masterPickValues);
				System.debug('objectFromPayload' + objectFromPayload);
				for(ServiceEventField__mdt serviceEventField: serviceEventFields){
					String apiFld =  serviceEventField.Field__c;
					if(serviceEventField.DataType__c == 'DependPickList' && masterPickValues.containsKey(serviceEventField.FieldTwo__c)){
						String fieldValue = String.valueOf(objectFromPayload.get(serviceEventField.Field__c));
						System.debug('fieldValue '+ fieldValue);
						String masterPickValue = masterPickValues.get(serviceEventField.FieldTwo__c);
						System.debug('masterPickValue: '+ masterPickValue + ' Field : ' + serviceEventField.Field__c);
						//if(masterPickValue == serviceEventField.Field__c && String.isNotBlank(fieldValue)){	
							System.debug('adding ' + sobjList[i] + ' label: ' + serviceEventField.Label + ' value: ' + fieldValue);						
							AddFieldToSObject(sobjList[i],serviceEventField.Label,fieldValue,'String');
						//}
					}else{
						AddFieldToSObject(sobjList[i],serviceEventField.Label,objectFromPayload.get(apiFld),serviceEventField.DataType__c);
					}
					
				}
			}
		
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMsg);
			errorMessage =errorMsg;
			throw new  custException(errorMsg);
		}
		return sobjList;
		 
	}
	public Map<String,String> getAnyMasterPickListValues(Map<String,Object> objectFromPayload,List<ServiceEventField__mdt> serviceEventFields){
		Map<String,String> masterPickLists = new Map<String,String>();
		for(ServiceEventField__mdt serviceEventField: serviceEventFields){
			if(serviceEventField.DataType__c == 'MasterPickList'){
				masterPickLists.put(serviceEventField.Field__c,String.valueOf(objectFromPayload.get(serviceEventField.Field__c)));
			}
		}
		return masterPickLists;
	}
	/*******************************************************************************************************
    * @description populate Map with configuration for parent object
   	* @param eventMap parent object
	* @param objSettings returned map of string,string for mappings
	* @param serviceEventFields customSettings for mappings 
    * @return void
    */
	Public  String populateMap(Map<String, Object> eventMap,Map<String,String> objSettings, List<ServiceEventField__mdt> serviceEventFields){	
		String errorMessage = '';
		try{
			for(ServiceEventField__mdt serviceEventField: serviceEventFields){
				String apiField =  serviceEventField.Field__c;
				List<String> apiFields = New List<String>();
				List<String> apiFieldsTwo = New List<String>();
				if (String.isNotBlank(apiField)) {
					apiFields = apiField.split('\\.');
				}else if(serviceEventField.DefaultValue__c == Null){
					throw new custException('Configuration is incorrect for type: ObjSettings. Please check the configuration.');
				}
				if (String.isNotBlank(serviceEventField.FieldTwo__c)) {
					apiFieldsTwo = serviceEventField.FieldTwo__c.split('\\.');
				}
				System.debug('apiFields.size: ' + apiFields.size());
				//if size =1 then just get the attribute
				if(apiFields.size() <=1){					
					Object obj = eventMap.get(apiField);
					System.debug('apiField: ' + apiField);
					System.debug('apiField: ' + String.valueOf(obj));
					obj =  String.isBlank(String.valueOf(obj)) ? serviceEventField.DefaultValue__c : obj;	
					objSettings.put(serviceEventField.Label,String.Valueof(obj));					
				}
				//if size =2 then go get the child map first and then get the attribute
				else if(apiFields.size() ==2){					
					Map<String, Object> childObjectMap = (Map<String, Object>) eventMap.get(apiFields[0]);
					if(childObjectMap != Null){
						Object obj = childObjectMap.get(apiFields[1]);
						obj = obj == Null ? serviceEventField.DefaultValue__c : obj;
						objSettings.put(serviceEventField.Label,String.Valueof(obj));
					}
				}	
				//if size =3 then go get the grandchild map or list first and then get the attribute
				else if(apiFields.size() ==3){
					Map<String, Object> childObject = (Map<String, Object>)eventMap.get(apiFields[0]);
					if(childObject != null){
						Object grandChildObject = childObject.get(apiFields[1]);
						Map<String, Object> grandChildMap = (Map<String, Object>)childObject.get(apiFields[1]);
						if( grandChildMap!= null){
							Object obj = grandChildMap.get(apiFields[2]);
							objSettings.put(serviceEventField.Label,String.Valueof(obj));
						}
					}
				}						
			}			
			System.debug('*ObjSettings:' + objSettings);			
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMsg);
			errorMessage =errorMsg;
		}
		return errorMessage; 
	}
	private class CustException extends Exception{}
	
}