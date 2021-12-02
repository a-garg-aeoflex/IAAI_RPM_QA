/**
* @author LevDigital
* @date 2020
*
* @group Utility
* @group-content ../../ApexDocContent/Utility.htm
*
* @description Utils - utility class
*/

public with sharing class Utils {
    private static final EnvironmentSetting__mdt ENVIRONMENT_SETTING = [SELECT Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName = 'Key'];
    @AuraEnabled
    public static string setParms(String value) {
       return encrypt(value);
    }
    /*******************************************************************************************************
    * @description  Decrypts the Attributes sent from Auction Center and if the parms list, will add to the list and return 
    * @param  parms List<String> list of parameters to return if found in the encrypted values
    * @param  values String of encrypted values from Auction Center
    * @return  List<Options> list of wrapper class need to for input parameters of the Salesforce flow
    */
    @AuraEnabled
    public static List<Options> getParms(List<String> params, String values) {
        List<Options> retVals = new List<Options>();
        try{
            String decoded = decrypt(values);
            System.debug('values: ' +decoded);
            Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(decoded);
            System.debug('att: ' + attributes);
            for(String param:params){
                if(attributes.containsKey(param)){
                   String val = String.Valueof(attributes.get(param));
                   retVals.add(new Options(param,'String',val));
                }
            }
            System.debug(' retVal' +  retVals.size());
        } 
        Catch(Exception e){
           System.debug('Exception: ' + e.getLineNumber() + ' : ' + e.getMessage());
        }
        return retVals;
    }
    public class Options{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String value{get;set;}
        public Options(String nme,String tpe,String val){
            this.name = nme;
            this.type = tpe;
            this.value = val;
        }
    }
    /*******************************************************************************************************
    * @description  Encrypts String
    * @param  value - Value to be encrypted
    * @return  encrypted value in a string form
    */
    public static string encrypt(string value) {
        String encryptedDataValue;
        Blob data = Blob.valueOf(value);
        Blob crypted =  EncodingUtil.base64Decode(ENVIRONMENT_SETTING.Value__c);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', crypted, data);
        encryptedDataValue =EncodingUtil.base64encode(encryptedData);       
        return encryptedDataValue;
    }
    /*******************************************************************************************************
    * @description  Decrypts String
    * @param  value - Value to be decrypted that was previously encrypted by the above encrypt method
    * @return  decencrypted value
    */
    public static string decrypt(string value){
        String decryptedDataValue;
        Blob data = EncodingUtil.base64Decode(value);
        Blob crypted =  EncodingUtil.base64Decode(ENVIRONMENT_SETTING.Value__c);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', crypted, data);
        decryptedDataValue = decryptedData.toString();
        return decryptedDataValue;
    }
    /*******************************************************************************************************
    * @description  Tries to get the user info
    * @return  decencrypted value
    */
    @AuraEnabled
    public static List<Options> getLoggedONInfo(List<String> params){
        List<Options> retVals = new List<Options>();
        System.debug(': ' + UserInfo.getUserType());
        List<User> us = [SELECT Id,contactId,Contact.Account.BI_ID__c,FirstName,LastName,Email,Phone FROM User where Id =: UserInfo.getUserId() ];
        System.debug('us ' + us.Size());
        if(us.size() == 1){
            User u = us[0];
            if(params.contains('Usertype')){
                retVals.add(new Options('Usertype','String','true'));
            }
            Map<String, Object> attributes = new Map<String, Object>{};
            if(u.Contact.Account.BI_ID__c != NULL && params.contains('BuyerID')){
                
                retVals.add(new Options('BuyerID','String',u.Contact.Account.BI_ID__c));
            }
            if(u.FirstName != NULL && params.contains('Firstname')){
                retVals.add(new Options('Firstname','String',u.FirstName));
            }
            if(u.LastName != NULL && params.contains('LastName')){
                retVals.add(new Options('LastName','String',u.FirstName));
            }
            if(u.Phone != NULL && params.contains('PhoneNumber')){
                 retVals.add(new Options('PhoneNumber','String',u.Phone));
            }
            if(u.Email != NULL  && params.contains('Email')){
                retVals.add(new Options('Email','String',u.Email));
            }

            System.debug('retvals: ' + retVals);
        }
        return retVals;
    }
    /*******************************************************************************************************
    * @description  create an Integration Log
    * @param  parms requestBody - httpRequest
    * @param  values responseBody -httpResponse
    * @return transactionType - api Type
    */
    public static Integration_logs__c createIntegrationLog(string requestBody,string responseBody,string transactionType,Boolean  isInsert){
       return createIntegrationLog(requestBody,responseBody,transactionType,'','',isInsert);
    }
    public static Integration_logs__c createIntegrationLog(string requestBody,string responseBody,string transactionType,string key,string eventType, Boolean  isInsert){
            Integration_logs__c log = new Integration_logs__c(
			Request_Body__c = requestBody.length() < 32767 ? requestBody : requestBody.substring(0, 32767),
            Response_Body__c = responseBody.length() < 32767 ? responseBody : responseBody.substring(0, 32767),
            Transaction_Type__c = String.IsBlank(transactionType) ? 'Incoming Service Event' : transactionType,
            Transection_Id__c = key,
            Sent_To__c = eventType
        );
        if (isInsert) { insert log; }
        return log;
    }  
    /*******************************************************************************************************
    * @description  create an Outbound Integration Log
    * @param  parms requestBody - httpRequest
    * @param  values responseBody -httpResponse
    * @return transactionType - api Type
    */
    //Lev 7.29.2021 - change for success and failed outbound logging
    public static Integration_logs__c createOutboundLog(Integration_logs__c intLog){
        return createOutboundLog(intLog,'',true);
    }
    public static Integration_logs__c createOutboundLog(Integration_logs__c intLog,Boolean  isInsert){
        return createOutboundLog(intLog,'',isInsert);
    }
    public static Integration_logs__c createOutboundLog(Integration_logs__c intLog,String recordTypeDevName, Boolean  isInsert){
        if(String.isBlank(recordTypeDevName)){
            recordTypeDevName = 'ASAP_Outbound';
        }
        Id intLogRecordTypeId=  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId(); 
        intLog.RecordTypeId = intLogRecordTypeId;
        intLog.Request_Body__c =  intLog?.Request_Body__c?.length() < 32767 ? intLog?.Request_Body__c : intLog?.Request_Body__c?.substring(0, 32767);
        intLog.Response_Body__c =  intLog?.Response_Body__c.length() < 32767 ? intLog?.Response_Body__c : intLog?.Response_Body__c?.substring(0, 32767);
        intLog.Transaction_Type__c = String.IsBlank(intLog?.Transaction_Type__c) ? 'Incoming Service Event' : intLog?.Transaction_Type__c;
        intLog.API_Type__c = 'Outbound';
       
        if (isInsert) {  System.debug('INSERTING!: ' + intLog); insert intLog; }  
        return intLog;      
    } 

    /*******************************************************************************************************
    * @description returns the datatype of an object
    * @param  whatTypeAmI - object
    * @return datatype
    */
    public static string returnType( Object whatTypeAmI )
    {
        String name = 'undefined';
        if( whatTypeAmI instanceof Integer )
        {
            name = 'Integer';
        }
        else if( whatTypeAmI instanceof Double)
        {
            name = 'Double';
        }
        else if( whatTypeAmI instanceof String)
        {
            name = 'String';
        }
        else if( whatTypeAmI instanceof Blob)
        {
            name = 'Blob';
        }
        else if( whatTypeAmI instanceof Boolean)
        {
            name = 'Boolean';
        }
        else if( whatTypeAmI instanceof Date)
        {
            name = 'Date';
        }
        else if( whatTypeAmI instanceof Datetime)
        {
            name = 'DateTime';
        }
        else if( whatTypeAmI instanceof Decimal)
        {
            name = 'Decimal';
        }
        else if( whatTypeAmI instanceof ID)
        {
            name = 'Id';
        }
        else if( whatTypeAmI instanceof Long)
        {
            name = 'Long';
        }
        else if( whatTypeAmI instanceof Time)
        {
            name = 'Time';
        }
        else if ( whatTypeAmI instanceof map<String,Object>){
            name = 'Map<String,Object>';
        }
        else if ( whatTypeAmI instanceof List<object>){
            name = 'List<Object>';
        }
        return(name);
    } 
    /*******************************************************************************************************
    * @description - Reuseable method for adding attributes to api payload
    * @param sobj - Map to add to
    * @param fldType - JSON attribute type
    * @param fldName - JSON attribute name
    * @param fldValue - JSON attribute value
  
    * @return 
    */
    public static void AddFieldToSObject(Map<String, Object> sobj,string fldType,String fldName,Object fldValue){	
        String inputs;	
		try{
            inputs = ' *fldName: ' + fldName + ' fldValue: ' + fldValue+ ' fldType: ' + fldType ;
            //System.debug('inputs:'  + inputs);
			if(fldValue!=Null){
				if (fldType == 'Date'){					
                    String stringValue = String.Valueof(fldValue);
                    //strValue = strValue.left(10);                			
                    if(String.isNotBlank(stringValue)){
                        Integer idxOf = stringValue.indexOf(' 00:00:00');                                
                        if(idxOf != -1){
                            stringValue = stringValue.left(idxOf) + 'T00:00:00.000Z';
                        }
                        DateTime dt = (DateTime)Json.deserialize('"'+stringValue+'"', DateTime.class);
					    sobj.put(fldName, dt);
                    }else{
                        Date d = (Date)Json.deserialize('"'+stringValue+'"', Date.class);
                        sobj.put(fldName, d);
                    }   
                    //Date d = (Date)Json.deserialize('"'+strValue+'"', Date.class);
                    //String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/yyyy');
                    						
										
				}else if (fldType == 'Datetime') {		
                    String stringValue = String.Valueof(fldValue);
                    if(String.isNotBlank(stringValue)){
                        Integer idxOf = stringValue.indexOf(' 00:00:00');                                
                        if(idxOf != -1){
                            stringValue = stringValue.left(idxOf) + 'T00:00:00.000Z';
                        }                       
                    }	
					DateTime dt = (DateTime)Json.deserialize('"'+stringValue+'"', DateTime.class);
					sobj.put(fldName, dt);
				}else if (fldType == 'Boolean') {
					Boolean b = Boolean.valueOf(fldValue);
					sobj.put(fldName, b);
				}else if (fldType == 'Integer') {
					Integer i = Integer.valueOf(fldValue);
					sobj.put(fldName, i);
				}else if (fldType == 'Currency') {
					decimal d = decimal.valueOf(String.valueOf((fldValue)));
					sobj.put(fldName, d);		}                       
				else {
					sobj.put(fldName, fldValue);
				}
			}else {
                sobj.put(fldName, '');
            }
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			
			System.debug(errorMsg);
			throw new custException(errorMsg + inputs);
		}
		
	}
    /*******************************************************************************************************
    * @description - Reuseable method for adding attributes to api payload
    * @param sobj - Map to add to
    * @param fldType - JSON attribute type
    * @param fldName - JSON attribute name
    * @param fldValue - JSON attribute value
  
    * @return 
    */
    public static void AddFieldToSObject(sObject sobj,string fldType,String fldName,Object fldValue){	
        String inputs;	
		try{
            inputs = ' *fldName: ' + fldName + ' fldValue: ' + fldValue+ ' fldType: ' + fldType ;
            //System.debug('inputs:'  + inputs);
			if(fldValue!=Null){
				if (fldType == 'Date'){					
                    String strValue = String.Valueof(fldValue);
                    Matcher pm = Pattern.compile('\\d{2}\\/\\d{2}\\/\\d{4}$').matcher(strValue);                    
                    if(strValue.contains('TODAY()')){
                        sobj.put(fldName, System.Today());
                    }//mm/dd/yyyy
                    else if(pm.matches()==true){
                        Date d = Date.parse(strValue);
                        sobj.put(fldName,d);                        
                    }//Normal SF date yyyy-MM-dd
                    else{

                        Date d = (Date)Json.deserialize('"'+strValue+'"', Date.class);
                        sobj.put(fldName, d);
                    }    				
				}else if (fldType == 'Datetime') {	
                    String strValue = String.Valueof(fldValue);
                    if(strValue.contains('NOW()')){
                        DateTime dt = (DateTime)Json.deserialize('"'+System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'"', DateTime.class);
                        sobj.put(fldName, dt);
                    }else{		
					    DateTime dt = (DateTime)Json.deserialize('"'+fldValue+'"', DateTime.class);
					    sobj.put(fldName, dt);
                    }
				}else if (fldType == 'Boolean') {
					Boolean b = Boolean.valueOf(fldValue);
					sobj.put(fldName, b);
				}else if (fldType == 'Integer') {
					Integer i = Integer.valueOf(fldValue);
					sobj.put(fldName, i);
				}else if (fldType == 'Currency') {
					decimal d = decimal.valueOf(String.valueOf((fldValue)));
					sobj.put(fldName, d);		}                       
				else {
					sobj.put(fldName, fldValue);
				}
			}else {
                sobj.put(fldName, '');
            }
		}
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			
			System.debug(errorMsg);
			throw new custException('Utils: ' + errorMsg + inputs);
		}
		
	}
    /*******************************************************************************************************
    * @description - Reuseable method for sending api callouts
    * @param method - api method
    * @param endpoint - endpoint of api
    * @param body - body of api
    * @param isCompressed - boolean if api is compressed
    * @param headerValues - map of headers for api callout
    * @param timeOut - add this value timeout is extend,else leave blank and default timeout is used
    * @param type - name of api
    * @return 
    */
    public static HttpResponse sendRequest(String method, String endpoint, String body, boolean isCompressed, Map<String, String> headerValues,Integer timeOut,String type) {
        HttpResponse response = new HttpResponse();
      
        System.debug('SendRequest ' + type + ' endpoint ' + endpoint );
        System.debug('headerValues ' + headerValues );
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);        
        request.setEndpoint(endpoint);   
        if (body != null && body.trim() != '') {
            request.setBody(body);
        }
        request.setCompressed(isCompressed);
        if (headerValues != null && !headerValues.isEmpty()) {
            for (String name: headerValues.keySet()) {
                request.setHeader(name, headerValues.get(name));
            }
        }
        if(String.isNotBlank(String.Valueof(timeOut)) && timeOut > 0){
            request.setTimeout(timeOut);
        }
        System.debug(request);
        response = http.send(request);
        System.debug(response);
        return response;
    }
    /*******************************************************************************************************
    * @description - Returns true if Response is good from api callout
    * @param HttpResponse response from callout
    * @return true or false 
    */
    public static Boolean isResponseGood(HttpResponse response){
        Boolean responseGood= false;
        string responseStatus =response.getStatus();
        integer responseCode = response.getStatusCode();
        System.debug('Response Status: ' + responseStatus + ' Response Code: ' + responseCode);
        if(responseStatus =='OK' && responseCode == 200){
            responseGood = true;
        }else if(responseStatus =='Created' && responseCode == 201){
            responseGood = true;
        }else if(responseStatus==' Accepted' && responseCode == 202){
            responseGood = true;
        }
        return responseGood; 
    }
     /*******************************************************************************************************
    * @description upsertRecords a list of Records
    * @param sobjs to upsert
    * @param sObjectName name of sobject
    * @param f Schema.SObjectField to upsert
    * @return void
    */
    //Lev 7.29.2021 - Moved method into Utils object for Reuseability
    public static void upsertRecords(List<sobject> sobjs,String sObjectName, Schema.SObjectField f){
        System.debug(sObjectName + sobjs.size());
        String errorMessage;        
        Database.UpsertResult[] srList =Database.upsert(sobjs,f,false);
        Integer successCount =0;
        Integer failedCount = 0;		
        for(Integer i=0;i<srList.size();i++){
            if (srList.get(i).isSuccess()) {                       
                successCount++;
            }
            else {
                failedCount ++;
                for(Database.Error err :srList.get(i).getErrors()) {				
                    errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + sObjectName + ' : ' + sobjs.get(i)
                    : errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + sObjectName + ' : ' +  sobjs.get(i);
                    System.debug('errorMessage: ' + errorMessage);    
                }	
            }
        }
        System.debug('*SuccessCount: ' + successCount);
        System.debug('*FailedCount: ' + failedCount);
        if(String.isNotBlank(errorMessage)){
            throw new custException(errorMessage);
        }
    }
    /*******************************************************************************************************
    * @description Reuseable function for deleteing records
	* @param sobj List<sObject>
	* @param errorMessage errormessage
    * @return list of successful Ids
    */
	Public static String  DMLDeleteHelperList(List<sObject> sobjs,String errorMessage){	
        System.debug('*sobjs ' +  sobjs);	
		String returnedErrorMessage;
		Database.DeleteResult[] srList  =  Database.delete(sobjs,false);
		
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
				throw new custException(errorMessage);	
			}
		}
		if(hasError == true){
			returnedErrorMessage =errorMessage;	
		}
		return returnedErrorMessage;
	}
    /*******************************************************************************************************
    * @description Reuseable function for offset of Datetime
	* @param dateValue - string that a DateTime with no timezone I.E. 2020-10-15T09:03:04
    * @param sfTimeZone - Salesforce timezone I.E. 'America/Chicago'
    * @return Changed Datetime
    */
	Public static Datetime ChangeDateTimeOffset(string dateValue, string sfTimeZone){	
        Datetime dt = Datetime.newInstanceGmt(Integer.Valueof(dateValue.substring(0,4)), Integer.Valueof(dateValue.substring(5,7)),
        Integer.Valueof(dateValue.substring(8,10)),Integer.Valueof(dateValue.substring(11,13)), 
        Integer.Valueof(dateValue.substring(14,16)), Integer.Valueof(dateValue.substring(17,19)));          
        Timezone tz = Timezone.getTimeZone(sfTimeZone);
        Integer offset = ((tz.getOffset(dt)/1000) / 60 / 60) * -1;
        Datetime offsetDateTime = dt.addhours(offset);
        return offsetDateTime;
    }
    //parses payload and addes to sObjects dynamically if payload starts out with object and tranverses child object and child lists
    //Or can get called from populateSObject with Array List<Object>
    Public static Integer populateSObject(Map<String, Object> incomingObj,Map<String,List<SObject>> settings, Map<String,SObjectWrapper> sObjectMap,Integer count,String parentProperty){	
		String errorMessage = '';
        Account acct = new Account();
		try{
            List<String> apiFields = New List<String>();
            for(String property : incomingObj.keySet()){                
                Object obj = incomingObj.get(property);
                if(parentProperty !='topObject'){                
                    property = parentProperty + '.' + property;
                }
                String objType = Utils.returnType(obj);
                //System.debug('*objType: ' + objType);
                if(objType =='List<Object>'){
                    List<Object> childList = (List<Object>)obj;
                    count = populateSObject( childList,settings, sObjectMap ,count,property);     
                }else if(objType =='Map<String,Object>'){
                    Map<String, Object> childObjectMap = (Map<String, Object>)obj;
                    count = populateSObject(childObjectMap,settings,sObjectMap,count,property);
                }else{
                    //System.debug('map property: ' + property + ' : ' + String.Valueof(obj));                   
                    AddFieldValueToSObject(property,settings,sObjectMap,obj);
                }               
            }
            return count;
        }		
		Catch(Exception e){
			String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' +errorMsg);
			errorMessage =errorMsg;
			throw new  custException(errorMsg);
		}		 
	}
    //parses payload dynamically if payload starts out with list and tranverses child object and child lists
    //Or can get called from populateSObject with object/map<string,Object>
    Public static Integer populateSObject(List<Object> incomingList,Map<String,List<SObject>> settings, Map<String,SObjectWrapper> sObjectMap ,Integer count,String parentProperty){	
		String errorMessage = '';
		try{
            List<String> apiFields = New List<String>();
            for(Object obj : incomingList){
                String objType = Utils.returnType(obj);
                System.debug(logginglevel.FINER,'*objType: ' + objType);
                if(objType =='List<Object>'){
                    List<Object> childList = (List<Object>)obj;
                    count = populateSObject( childList,settings, sObjectMap ,count,parentProperty);  
                }else if(objType =='Map<String,Object>'){
                    Map<String, Object> childObjectMap = (Map<String, Object>)obj;
                    count = populateSObject(childObjectMap,settings,sObjectMap,count,parentProperty);
                }else{
                    System.debug('*Unknown List objectType: ' + objType);
                }               
            }
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' +errorMsg);
            errorMessage =errorMsg;
            throw new  custException(errorMsg);
        }
        return count;
    }
    //Populates fields of sobjects 
    //Is called from populateSObject with object/map<string,Object> or populateSObject with Array List<Object>
    public Static void AddFieldValueToSObject(String property,Map<String,List<SObject>> settings,Map<String,SObjectWrapper> sObjectMap,Object obj){
        property = property?.trim();
        if(settings.containsKey(property)){
            List<SObject> customSettings = settings.get(property);
            for(SObject customSetting:customSettings){
                SObjectWrapper sobjWrapper =sObjectMap.get(customSetting.get('Type__c').toString());
                System.debug(logginglevel.FINER, 'property: ' + property + ' contains: ' + settings.containsKey(property) + ' Is Mapped: ' + Boolean.valueOf(customSetting.get('IsMapped__c') == false));
                if(Boolean.valueOf(customSetting.get('IsMapped__c') == false)){
                    sobjWrapper.additionalProperties.put(property,obj);
                }else{                    
                    if(String.IsNotBlank(String.valueof(customSetting.get('DefaultValue__c'))?.trim())){

                        AddFieldToSObject(sobjWrapper.sobj,customSetting.get('dataType__c')?.toString()?.trim(),customSetting.get('Label').toString()?.trim(),customSetting.get('DefaultValue__c')?.toString()?.trim()); 
                    }else{    
                        AddFieldToSObject(sobjWrapper.sobj,customSetting.get('dataType__c')?.toString()?.trim(),customSetting.get('Label').toString()?.trim(),obj);                                                                  
                    }
                }
            }
        }   

    }    
    //Wrapper class from Sobject is instantiated from populateSObject
    public class SObjectWrapper{
        Public SObject sobj;
        Public Map<String,Object> additionalProperties = new Map<String,Object>();
        public SObjectWrapper(sObject sObjt){
            this.sobj = sObjt;
        }
    }
    private class CustException extends Exception{}
}