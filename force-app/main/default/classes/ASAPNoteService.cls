/*
* @author LevDigital
* @date 2021
*
* @group ASAP_Note__c
* @group-content ../../ApexDocContent/ASAP_Note__c.htm
*
* @description ASAPNoteService is called from the ASAPNoteTriggerHelper
*/
public with sharing class ASAPNoteService implements Queueable, Database.AllowsCallouts{
    public ASAP_Note__c asapNote;
    public List<String> apiNames = new List<String>();
    public String buyerId;
    private List<OutboundField__mdt> outboundFields;
    public Map<String, List<OutboundField__mdt>> typeOutboundFields = new Map<String, List<OutboundField__mdt>>();
    private Map<String,ASAP_Note__c> uniqueKeyASAPNotes = new Map<String,ASAP_Note__c>();   
    private static final string NO_CONTACT_ERROR = 'Could not get contacts for ';
    private static final String NEW_LINE = '\n' ;
    public Account acct;
    private Account updateAcct;
    public ASAPNoteService(List<String> apis){   
        apiNames = apis;        
        outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c,SFObject__c,RequiredField__c FROM OutboundField__mdt
                        WHERE Type__c IN:apiNames];
        System.debug('outboundFields: ' + outboundFields);
        for(OutboundField__mdt outboundField:outboundFields){
            if(!typeOutboundFields.containsKey(String.Valueof(outboundField.Type__c))){
                typeOutboundFields.put(String.Valueof(outboundField.Type__c),New List<OutboundField__mdt>());
            }
            List<OutboundField__mdt> outFields = typeOutboundFields.get(String.Valueof(outboundField.Type__c));
            outFields.add(outboundField);
            typeOutboundFields.put(String.Valueof(outboundField.Type__c),outFields);
            
        }
    }
     /*******************************************************************************************************
    * @description sends an UploadNote api callout
    * @return void
    */
    public void SendUploadNoteAPI(){  
        String apiName = 'UploadNote'; 
        HttpResponse resp = new  HttpResponse(); 
        String endpoint;
        String jsonstring;
        String buyerId;
        try{
            asapNote = getASAPNote(asapNote.Id,typeOutboundFields.get(apiName));
            System.debug('asap: ' + asapNote);
            jsonstring =createUploadNotePayload(typeOutboundFields.get(apiName));
            System.debug('jsonstring: ' + jsonstring);
            buyerId = asapNote.Account__r.API_Buyer_Id__c;
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/UploadNote';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
            resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 0, apiName);
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                System.debug('retry');
                resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 0, apiName);
            }
            //If response is good
            if(Utils.isResponseGood(resp)){  
                System.debug('Response is good!' + resp.getBody());
                String respBody =  resp.getBody();
                if(String.isNotBlank(respBody)){
                    respBody = (String)JSON.deserializeUntyped(respBody);
                }
                if(String.isBlank(respBody)){
                    throw new CustException('Error sending UploadNote could not get createdatetime');
                }
                
                String buyerEmployeeId;                
                String uniqueKey;
                if(asapNote.contact__r!= null){
                   Contact con = asapNote.contact__r;
                   if(String.isNotBlank(String.valueOf(con.Buyer_Employee_ID__c))){
                       buyerEmployeeId =String.valueOf(con.Buyer_Employee_ID__c);
                   }                   
                }                
                if(String.isNotBlank(buyerEmployeeId)){
                    uniqueKey = buyerId +buyerEmployeeId + respBody;
                }else{
                    uniqueKey = buyerId + respBody;
                }
                asapNote.ASAP_Id__c = uniqueKey;
                System.debug('uniqueKey: ' +uniqueKey);
                System.debug('asapNote: ' +  asapNote);
                Database.SaveResult sr = Database.update(asapNote,false);
                String errorMessage;
                if(sr.isSuccess()) { 
                    //Lev 7.29.2021 - change for success and failed outbound logging 
                    Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                    Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Note_Success_Message')?.Value__c,Account__c = asapNote?.Account__c,Transection_Id__c = buyerId));
                }else{
                    for(Database.Error err : sr.getErrors()) {				
                        errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' ASAPNote Value: ' + asapNote
                            : errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' ASAPNote Value: ' + asapNote;
                    }		
                    throw new custException(errorMessage);	
                }    
            }else{

                throw new CustException('Error sending UploadNote');
            } 
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' + errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Send_Upload_Note_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                    Request_Body__c=jsonstring,  Response_Body__c=errorMsg + NEW_LINE + resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp?.getBody(),Account__c = asapNote?.Account__c,Transection_Id__c = buyerId));
           
        } 
    }
    /*******************************************************************************************************
    * @description - creates the payload for the UploadNote API
    * @param outboundFields custom metadata for specified callout name
    * @return 
    */
    public String createUploadNotePayload(List<OutboundField__mdt> outboundFields ){
        String jsonstring;
        Map<String, Object> payload = new Map<String, Object>();
        for(OutboundField__mdt outboundField:outboundFields){
            string apiField =  outboundField.Label;
            string sfField =  String.Valueof(outboundField.Value__c);
            List<String> sfFields = New List<String>();
            String defaultValue = String.Valueof(outboundField.DefaultValue__c);
            if(String.isNotBlank(apiField)){
                if(String.isBlank(sfField)){
                    Utils.AddFieldToSObject(payload,outboundField.dataType__c,apiField,defaultValue);
                }else{
                    sfFields = sfField.split('\\.'); 
                    if(sfFields.size() ==1){ 
                        Object obj = asapNote.get(sfField);
                        String stringValue = String.Valueof(obj);  
                        if(((String.isNotBlank(stringValue) && outboundField.RequiredField__c == false) || (outboundField.RequiredField__c ==true))){   
                            Utils.AddFieldToSObject(payload,outboundField.dataType__c,apiField,obj);
                        }
                    }else if(sfFields.size() ==2){                        
                        String sObjectParent = sfFields[0];
                        if(String.isNotBlank(sObjectParent)){
                            Integer count = sObjectParent.indexof('__r');
                            if(count > 3){
                                String sObjectName = sObjectParent.left(count) + '__c';
                                Object parentObject = asapNote.get(sObjectName);
                                if(parentObject!=null){
                                    Object obj = asapNote.getSObject(sfFields[0]).get(sfFields[1]);
                                    String stringValue = String.Valueof(obj);  
                                    if(((String.isNotBlank(stringValue) && outboundField.RequiredField__c == false) || (outboundField.RequiredField__c ==true))){   
                                        Utils.AddFieldToSObject(payload,outboundField.dataType__c,apiField,obj);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        jsonstring = json.serializePretty(payload);
        return jsonstring;
    }
    /*******************************************************************************************************
    * @description retrieves the ASAPNote with the fields from custom metadata
    * @return void
    */
    public ASAP_Note__c getASAPNote(String asapId,List<OutboundField__mdt> outboundFields){
        
        ASAP_Note__c aspNote;
        try{
            Set<String> fields = new Set<String>{'Id'}; 
            for(OutboundField__mdt outboundField:outboundFields){
                String val = outboundField.Value__c;
                if(String.isNotBlank(val)){                   
                    fields.add(val); 
                    Integer count = val.indexof('__r');
                    if(count > 3){
                        String sObjectName = val.left(count) + '__c';
                        fields.add(sObjectName);
                    }                                
                }
            }
            List<String> fieldsList = new List<String>();
            fieldsList.addAll(fields);
            if(!fieldsList.contains('Account__c')){
                fieldsList.add('Account__c');
            }
            String flds = String.join(fieldsList,', ');
            System.debug('*flds ' + flds);
            String query = 'SELECT ' + String.escapeSingleQuotes(flds) + ' FROM ASAP_Note__c WHERE Id = :asapId';    

            System.debug('*query ' + query);
            List<ASAP_Note__c> asapNotes = Database.query(query);
            if(!asapNotes.isEmpty()){
                aspNote = asapNotes[0];
                System.debug('ASAPNote: ' + aspNote);
            }
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error ' + errorMsg);
			throw new custException(errorMsg);
        }
        return aspNote;
    }    
    /*******************************************************************************************************
    * @description sends a GetBuyerNotes api callout
    * @return void
    */
    //Lev 7.29.2021 - Moved Buyer Notes to ASAP Notes Service
    public void GetBuyerNotes(){
        ASAPNoteTriggerHelper.asapNoteFirstRun = false;
        String apiName = 'GetBuyerNotes';        
        HttpResponse resp = new  HttpResponse();
        String endpoint;
        
        try{           
            System.debug('GetBuyerNotes:');
            updateAcct.Get_Note_Status__c = 'Available';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'};
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/GetBuyerNotes/' + buyerId + '/400';
            resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, apiName);
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0,apiName);
            }
            if(Utils.isResponseGood(resp)){
                System.debug('resp:' + resp.getBody() );
                Map<String,Object> payload = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                parseGetBuyerNotesPayload(payload,apiName,endpoint );
            }else{

                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                    Request_Body__c='',Response_Body__c= resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp?.getBody(),Account__c = acct?.Id,Transection_Id__c = buyerId));
            } 
            
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            //Utils.createIntegrationLog('',resp.getBody() + ' Error: ' + errorMsg,EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,acct.Id,endpoint,true);
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c=errorMsg  +  '\n' + resp?.getBody(),Account__c = acct?.Id,Transection_Id__c = buyerId));
            update updateAcct; 
           
        } 
    }
     /*******************************************************************************************************
    * @description parses the response from GetBuyerNotes api
    * @param  payload List<Object> from parsed response
    * @return void
    */
    public Void parseGetBuyerNotesPayload(Map<String,Object> payload,String apiName,string endpoint ){
        System.debug('parseGetBuyerNotes');
        try{
            Map<String, OutboundField__mdt> apiFieldOutboundFields = new Map<String, OutboundField__mdt>();
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get(apiName);
            List<Object> buyerNotes = new  List<Object>();
            List<Object> buyerEmployeeNotes= new  List<Object>();
            Boolean isError = false;
            Map<String,UniqueKeysContactId> buyerEmpIdUniqueKeyConIds = new Map<String,UniqueKeysContactId>();
            List<License__c> licensesToUpsert = new List<License__c>();
            
            for(OutboundField__mdt outboundField:outboundFields){
                apiFieldOutboundFields.put(outboundField.label,outboundField);
            }
            if(payload.containsKey('buyerNotes')){
                buyerNotes=(List<Object>) payload.get('buyerNotes');
            }
            if(payload.containsKey('buyerEmployeeNotes')){
                buyerEmployeeNotes =(List<Object>) payload.get('buyerEmployeeNotes');
            }
            //Loop through and parse the buyerNotes JSON Array
            if(!buyerNotes.isEmpty()){
                System.debug('buyerNotes: ' + buyerNotes.size());
                for(Object obj:buyerNotes){                
                    if(obj!=null){
                        String objTopType = Utils.returnType(obj);
                        if(objTopType == 'Map<String,Object>'){
                            Map<String, Object> objectMap = (Map<String, Object>) obj; 
                            parseASAPNote( objectMap,'buyerNotes',uniqueKeyASAPNotes,apiFieldOutboundFields,buyerEmpIdUniqueKeyConIds);
                        }
                    }
                }
            }
            //Loop through and parse the buyerEmployeeNotes JSON Array
            if(!buyerEmployeeNotes.isEmpty()){
                System.debug('buyerEmployeeNotes: ' + buyerNotes.size());
                for(Object obj:buyerEmployeeNotes){                
                    if(obj!=null){
                        String objTopType = Utils.returnType(obj);
                        if(objTopType == 'Map<String,Object>'){
                            Map<String, Object> objectMap = (Map<String, Object>) obj; 
                            parseASAPNote( objectMap,'buyerEmployeeNotes',uniqueKeyASAPNotes,apiFieldOutboundFields,buyerEmpIdUniqueKeyConIds);
                        }
                    }
                }
            }
            //if there are buyerEmployeeIds, then go get the contactIds and add them to buyerEmpIdUniqueKeyConIds
            if(!buyerEmpIdUniqueKeyConIds.isEmpty()){
                List<Contact> cons= [SELECT Id,Buyer_Employee_ID__c,LastModifiedDate,AccountId,LastName,CreatedDate FROM Contact WHERE AccountId =:acct.Id AND Buyer_Employee_ID__c IN :buyerEmpIdUniqueKeyConIds.keyset() Order by Buyer_Employee_ID__c,CreatedDate DESC];
                for(Contact con:cons){
                    UniqueKeysContactId uniqueKeyConId = buyerEmpIdUniqueKeyConIds.get(con.Buyer_Employee_ID__c);
                    //In case there are multiple contactIds, since we ordered by CreatedDate desc
                    //add the first one which is the most recent modified and no other contactIds for that buyerId
                    //System.debug('contact.Id: '+ con.Id  + ' LastName: ' + con.LastName + ' CreatedDate: ' + con.CreatedDate);
                    if(String.isBlank(String.ValueOf(uniqueKeyConId.contactId))){
                        System.debug('con.Id: '+ con.Id);
                        uniqueKeyConId.contactId = con.Id;                            
                        buyerEmpIdUniqueKeyConIds.put(con.Buyer_Employee_ID__c,uniqueKeyConId);
                    }
                }
                
                //Loop through buyerEmpIdUniqueKeyConIds and get the ASAP Note by the unique Key and add the contactId
                for(String buyerId:buyerEmpIdUniqueKeyConIds.keySet()){
                    UniqueKeysContactId uniqueKeyConId =buyerEmpIdUniqueKeyConIds.get(buyerId);
                    if(String.isNotBlank(String.ValueOf(uniqueKeyConId.contactId))){
                        for(String uniqueKee:uniqueKeyConId.uniqueKeys){
                            if(uniqueKeyASAPNotes.containsKey(uniqueKee)){
                                ASAP_Note__c aspNote = uniqueKeyASAPNotes.get(uniqueKee);
                                
                                aspNote.Contact__c = uniqueKeyConId.contactId;
                                uniqueKeyASAPNotes.put(uniqueKee,aspNote);
                            }
                        }
                    }else{
                        for(String uniqueKee:uniqueKeyConId.uniqueKeys){
                            if(uniqueKeyASAPNotes.containsKey(uniqueKee)){
                                ASAP_Note__c aspNote = uniqueKeyASAPNotes.get(uniqueKee);
                                uniqueKeyASAPNotes.put(uniqueKee,aspNote);
                            }
                        }
                        String errorMsg =  NO_CONTACT_ERROR + 'Account: ' + acct.Id + ' and BuyerEmployee Id: ' +  buyerId;     
                        System.debug('Error: ' + errorMsg);
                        isError = true;
                        //Utils.createIntegrationLog(errorMsg,JSON.serializePretty(payload),EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,acct.Id,endpoint,true);
                        Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                            Request_Body__c='',Response_Body__c=errorMsg + '\n' + JSON.serializePretty(payload),Account__c = acct?.Id,Transection_Id__c = buyerId));
                    }
                }   
                
            } 
            //If there are ASAPNotes to upsert 
            if(!uniqueKeyASAPNotes.isEmpty()){
                Schema.SObjectField f = ASAP_Note__c.Fields.ASAP_Id__c;	
                utils.upsertRecords(uniqueKeyASAPNotes.Values(),'ASAP_Note__c', f);
            }           
            update updateAcct; 

            if(isError == false){
                //set success integration log
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                    Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message')?.Value__c,Account__c = acct.Id,Transection_Id__c = buyerId));
            }
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            throw new custException(errorMsg);          	
        }
    }
     /*******************************************************************************************************
    * @description parses the ASAP Notes
    * @param objectMap Map<String, Object> parsed Note JSON Object 
    * @param type is buyerNotes or buyerEmployeeNotes
    * @param uniqueKeyASAPNotes Map uniquekey which is a concatenation of fields and ASAP_Note__c
    * @param apiFieldOutboundFields custom metadata for api
    * @param buyerEmpIdUniqueKeyConIds map to hold the buyerId,uniqueKeys and to fill in the contactId later
    * @return void
    */
    public void parseASAPNote( Map<String, Object> objectMap,String type,Map<String,ASAP_Note__c> uniqueKeyASAPNotes,Map<String, OutboundField__mdt> apiFieldOutboundFields,Map<String,UniqueKeysContactId> buyerEmpIdUniqueKeyConIds){
        ASAP_Note__c asapNote = new ASAP_Note__c(Account__c =acct.Id);
        String uniqueKey;
        String buyerId;
        String buyerEmployeeId;
        String createdDateTime;  
        Set<String> uniqueKeys = new Set<String>();
        for(String field: objectMap.keyset()){
            
            if(apiFieldOutboundFields.containsKey(field)){
                OutboundField__mdt outField = apiFieldOutboundFields.get(field);
                String fieldName = String.valueOf(outField.Label);
                String sfFieldName =  String.valueOf(outField.Value__c);
                Object fldValue = objectMap.get(field);
                String stringFldValue = string.valueOf(fldValue);
                String fldType = String.valueOf(outField.DataType__c);
                
                //System.debug('stringFldValue: ' + stringFldValue + ' sfFieldName: ' + sfFieldName);
                if(fldValue != null &&  stringFldValue != 'null'){
                    if(String.isNotBlank(stringFldValue)){
                        stringFldValue = stringFldValue.trim();
                    }
                    if(sfFieldName == 'Account__c'){
                        buyerId = stringFldValue;                                              
                    }else if(sfFieldName == 'Contact__c'){
                        buyerEmployeeId= stringFldValue;
                    }
                    else{
                        if(sfFieldName == 'Ext_Date_Time_Created__c'){
                            createdDateTime =stringFldValue;
                            Datetime dt = Datetime.newInstanceGmt(Integer.Valueof(stringFldValue.substring(0,4)), Integer.Valueof(stringFldValue.substring(5,7)),
                            Integer.Valueof(stringFldValue.substring(8,10)),Integer.Valueof(stringFldValue.substring(11,13)), 
                            Integer.Valueof(stringFldValue.substring(14,16)), Integer.Valueof(stringFldValue.substring(17,19)));
                            //Getting timezone for Central since ASAP sends central             
                            Timezone tz = Timezone.getTimeZone('America/Chicago');
                            //Getting Offset incase of DST                              
                            Integer offset = ((tz.getOffset(dt)/1000) / 60 / 60) * -1;                            
                            Datetime UtcDate = dt.addhours(offset );
                            asapNote.put(sfFieldName,utcDate);                            
                        }else{
                            Utils.AddFieldToSObject(asapNote,outField.DataType__c,sfFieldName,stringFldValue);
                        }
                    }                        
                    
                }
            }                            
        }
        if(type =='buyerNotes'){
            //uniqueKey for buyerNotes items are buyerId and createDateTime
            uniqueKey = buyerId + createdDateTime;
            asapNote.ASAP_Id__c = uniqueKey;
        }else if(type == 'buyerEmployeeNotes'){
            //uniqueKey for buyerEmployeeNotes items are buyerId and createDateTime
            uniqueKey = buyerId +buyerEmployeeId + createdDateTime;
            asapNote.ASAP_Id__c = uniqueKey;
            if(String.isnotBlank(buyerEmployeeId)){
                if(!buyerEmpIdUniqueKeyConIds.containsKey(buyerEmployeeId)){
                    buyerEmpIdUniqueKeyConIds.put(buyerEmployeeId,new UniqueKeysContactId());
                }
                UniqueKeysContactId uniqueKeyConId =buyerEmpIdUniqueKeyConIds.get(buyerEmployeeId);
                uniqueKeyConId.uniqueKeys.add(String.valueOf(uniqueKey));
                buyerEmpIdUniqueKeyConIds.put(buyerEmployeeId,uniqueKeyConId);
            }
            
        }
        if(!uniqueKeys.contains(uniqueKey)){
            //System.debug('asapNote: ' + asapNote);
            uniqueKeyASAPNotes.put(uniqueKey,asapNote);
            uniqueKeys.add(uniqueKey);
        }
    }
    
    public class UniqueKeysContactId{
        public Set<String> uniqueKeys = new Set<String>();
        public String contactId;       
    }
    /*******************************************************************************************************
    * @description standard execute method for Queueable that calls GetAPI methods
    * @return void
    */
    public void execute(QueueableContext context){  
        AccountTriggerHelper.accountFirstRun = false;
        ContactTriggerDispatcher.ContactFirstRun = false;
        
        System.debug('apiName: ' + apiNames);
        System.debug('asapNote: '+ asapNote);
        if(apiNames.contains('UploadNote')){
            SendUploadNoteAPI();
        }else if(apiNames.contains('GetBuyerNotes')){
            updateAcct = [SELECT Id,Get_Note_Status__c FROM Account WHERE Id=:acct.Id];
            GetBuyerNotes();
        }
        
    }
    private class CustException extends Exception{}
}