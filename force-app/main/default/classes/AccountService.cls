/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/Account.htm
*
* @description AccountService is called from AccountTriggerHelper
*/

public with sharing class AccountService implements Queueable, Database.AllowsCallouts{
    public Account acct;
    
    public List<String> apiNames;
    public String buyerId;
    private Account updateAcct = new Account();
    private Account updateAcctError= new Account(Get_LexisNexis_Result__c = 'Available');
    private Contact updateCon;
    
    private List<OutboundField__mdt> outboundFields;
    Map<String, List<OutboundField__mdt>> typeOutboundFields = new Map<String, List<OutboundField__mdt>>();
    List<String> acctfields = new List<String>{'Id','Get_LexisNexis_Result__c'}; 
    List<String> contactfields = new List<String>{'Id','Title'};   
    private static final String NEW_LINE = '\n' ;
    Boolean foundContact = false;
   
    private static final string NO_CONTACT_OWNER_ERROR = 'Could Not find contact owner for Account: ';
    private static final string NO_MATCH_ERROR = 'Could not find matching value for ';   

    private Map<String,String> contactIndRespCodeLabelValue = new Map<String,String>();
    private Map<String,String> acctBusRespCodLabelValue = new Map<String,String>();
    private Map<String, Integration_logs__c> integrationLogs = new Map<String, Integration_logs__c>();

    /*******************************************************************************************************
    * @description Constructor - gets custom metadata
    * @return void
    */
    public AccountService(List<String> apis) {
        apiNames = apis;       
        outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c,SFObject__c,RequiredField__c FROM OutboundField__mdt
        WHERE Type__c IN:apiNames];
        for(OutboundField__mdt outboundField:outboundFields){
            if(!typeOutboundFields.containsKey(String.Valueof(outboundField.Type__c))){
                typeOutboundFields.put(String.Valueof(outboundField.Type__c),New List<OutboundField__mdt>());
            }
            List<OutboundField__mdt> outFields = typeOutboundFields.get(String.Valueof(outboundField.Type__c));
            outFields.add(outboundField);
            typeOutboundFields.put(String.Valueof(outboundField.Type__c),outFields);
            String sfFieldName = outboundField.Value__c;
            if(String.isNotBlank(sfFieldName)){
                if(outboundField.SFObject__c == 'Account'){
                    acctfields.add(sfFieldName);
                }else if(outboundField.SFObject__c == 'Contact'){
                    contactfields.add(sfFieldName);
                }
            }
        }
        List<Schema.PicklistEntry> conRespCodePickListEntries = Schema.SObjectType.Contact.fields.getMap().get('Individual_Response_Code__c').getDescribe().getPicklistValues(); 
        for(Schema.PicklistEntry pickEntry:conRespCodePickListEntries){
            contactIndRespCodeLabelValue.put(pickEntry.label,pickEntry.value);
        }
        List<Schema.PicklistEntry> acctRespCodePickListEntries = Schema.SObjectType.Account.fields.getMap().get('Business_Response_Code__c').getDescribe().getPicklistValues(); 
        for(Schema.PicklistEntry pickEntry:acctRespCodePickListEntries){
            acctBusRespCodLabelValue.put(pickEntry.label,pickEntry.value);
        } 
    }
    /*******************************************************************************************************
    * @description - gets the Account and Contact related to account, if multiple contacts are found
    *                               then the contact with the Owner title is used.
    * @return void
    */
    public void getAccountAndContact(){
        String acctFlds = String.join( acctfields,', ');

        String acctId = acct.Id;
        String acctQuery = 'SELECT ' + String.escapeSingleQuotes(acctFlds) + ' FROM Account WHERE Id = :acctId'; 
        System.debug('*acctQuery ' + acctQuery);
        
        updateAcct = Database.query(acctQuery);
        updateAcct.Get_LexisNexis_Result__c = 'Available';

        if(contactfields.size()> 2){
            String contactFlds = String.join( contactfields,', ');

            String contactQuery = 'SELECT ' + String.escapeSingleQuotes(contactFlds) + ' FROM Contact WHERE accountId = :acctId Order by Title'; 
            System.debug('*contactQuery ' +  contactQuery);
            List<Contact> cons = Database.query(contactQuery);
            if(cons.size() == 1){
                updateCon = cons[0];
                foundContact = true;
            }else{                
                for(Contact con:cons){
                    if(con.Title == 'OWNR'){
                        updateCon = con;
                        foundContact = true;
                    }
                }
            }           
        }
        if(apiNames.contains('UpdateBuyer')){
            SendUpdateBuyer();
        }else if(apiNames.contains('GetLexisNexisCheck') && foundContact == true){
            getLexisNexisCheck();
        }else if(apiNames.contains('GetLexisNexisCheck') && foundContact == false){
            //Lev 7.29.2021 - change for success and failed outbound logging
            integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Sent_To__c='',Status__c='Failed',
            Request_Body__c='',Response_Body__c= NO_CONTACT_OWNER_ERROR,Account__c = acct.Id,Transection_Id__c = buyerId), false));
            writeLogs();
        }  

    }
    /*******************************************************************************************************
    * @description sends an UpdateBuyer api callout
    * @return void
    */
    public void SendUpdateBuyer(){    
        String endpoint;
        String jsonPayload;
        String apiName = 'UpdateBuyer';
        HttpResponse resp = new HttpResponse();
        try{
            System.debug('SendUpdateBuyer:');
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get('UpdateBuyer');
            endpoint = 'callout:ASAPIntegration'+ '/api/BuyerServices/UpdateBuyer';
            Map<String,Object> payload = new Map<String,Object>();
            for(OutboundField__mdt outboundField:outboundFields){
                String fieldName = String.valueOf(outboundField.Label);
                String sfFieldName =  String.valueOf(outboundField.Value__c);
                String defaultValue = String.valueOf(outboundField.DefaultValue__c);
                
                if(String.IsNotBlank(defaultValue)){
                    Utils.AddFieldToSObject(payload,outboundField.dataType__c,fieldName,defaultValue);
                }else{
                    Object obj = updateAcct.get(sfFieldName);
                    String stringValue = String.Valueof(obj);                     
                    //IAA-14 -for UpdateBuyer exclude blank values if not required by api
                    if(((String.isNotBlank(stringValue) && outboundField.RequiredField__c == false) || (outboundField.RequiredField__c ==true))){                          
                        Utils.AddFieldToSObject(payload,outboundField.dataType__c,fieldName,obj);
                    }
                }
            }
            jsonPayload = JSON.serializePretty(payload);
            System.debug('Payload: ' +jsonPayload);
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'};
            resp = Utils.sendRequest('POST',  endpoint, jsonPayload, false,headers, 0, apiName);
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                resp = Utils.sendRequest('POST',  endpoint, jsonPayload, false,headers, 0,apiName);
            }
            if(Utils.isResponseGood(resp)){
                System.debug('UpdateBuyer Resp Is Good: ' + resp.getBody() );   
                //Lev 7.29.2021 - change for success and failed outbound logging
                //set success integration log
                integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message')?.Value__c,Account__c = acct.Id,Transection_Id__c = buyerId),false));               
            }else{
                //Lev 7.29.2021 - change for success and failed outbound logging
                integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                        Response_Body__c=resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' + jsonPayload,Account__c = acct.Id,Transection_Id__c = buyerId),false));               
            }
            if(apiNames.contains('GetLexisNexisCheck')){                    
                getLexisNexisCheck();
            }else{
                writeLogs();
            }
            
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging
            integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c= errorMsg + NEW_LINE + resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +jsonPayload,Account__c = acct.Id,Transection_Id__c = buyerId),false));
            update updateAcctError;	
            writeLogs();	
        }
        
    }
    /*******************************************************************************************************
    * @description sends a getLexisNexisCheck api callout
    * @return void
    */
    public void getLexisNexisCheck(){
        String apiName = 'GetLexisNexisCheck';
        
        HttpResponse resp = new  HttpResponse();
        String endpoint;
        try{           
            System.debug('GetLexisNexisCheck:');
            updateAcct.Get_LexisNexis_Result__c = 'Available';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'};
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/GetLexisNexisCheck/' + buyerId ;
            resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, apiName);
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0,apiName);
            }
            if(Utils.isResponseGood(resp)){
                System.debug('resp:' + resp.getBody() );
                List<Object> payload = (List<Object>)JSON.deserializeUntyped(resp.getBody());
                parseLexisNexisCheckPayload(payload,endpoint );
            }else{
                //Lev 7.29.2021 - change for success and failed outbound logging
                integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                    Request_Body__c='',Response_Body__c=resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp.getBody(),Account__c = acct.Id,Transection_Id__c = buyerId),false));
                writeLogs();
            } 
            
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging
            integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c=errorMsg +  NEW_LINE +  resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp?.getBody(),Account__c = acct.Id,Transection_Id__c = buyerId),false));
            writeLogs();
            update updateAcctError; 
        } 
    }
    
    /*******************************************************************************************************
    * @description parses the response from  getLexisNexisCheck api
    * @param  payload List<Object> from parsed response
    * @return void
    */
    public Void parseLexisNexisCheckPayload(List<Object> payload,String endpoint ){
        System.debug('parseLexisNexisCheckPayload');
        try{
            Map<String, Map<String, OutboundField__mdt>> apiFieldOutboundFields = new Map<String, Map<String, OutboundField__mdt>>
            {'Business'=>New Map<String, OutboundField__mdt>(),'Background'=>New Map<String, OutboundField__mdt>() };
            Map<String, Map<String, OutboundField__mdt>> apiDefaultOutboundFields = new Map<String, Map<String, OutboundField__mdt>>
            {'Business'=>New Map<String, OutboundField__mdt>(),'Background'=>New Map<String, OutboundField__mdt>() };
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get('GetLexisNexisCheck');
            List<License__c> licensesToUpsert = new List<License__c>();
            String validationTypeAttribute;
            Map<String,List<String>> respDescFields = new Map<String,List<String>>();
            
            for(OutboundField__mdt outboundField:outboundFields){
                if(outboundField.SFObject__c == 'Other' ){
                    validationTypeAttribute = outboundField.label;
                }else if(outboundField.Value__c == 'Individual_Response_Description__c' || outboundField.Value__c == 'Business_Response_Desc__c'){
                    String attr = outboundField.label;
                    if(String.isNotBlank(attr)){
                        List<String> attributes = attr.split(',');
                        if(outboundField.SFObject__c == 'Account'){
                            respDescFields.put('Business',attributes);
                        }else{
                            respDescFields.put('Background',attributes);
                        }
                    }
                }
                else{
                    if(outboundField.SFObject__c == 'Account'){
                        if(String.isBlank(String.valueOf(outboundField.APIType__c))){
                            Map<String, OutboundField__mdt> apiFields =  apiDefaultOutboundFields.get('Business');
                            apiFields.put(outboundField.label,outboundField);
                            apiDefaultOutboundFields.put('Business',apiFields);
                        }else{
                            Map<String, OutboundField__mdt> apiFields =  apiFieldOutboundFields.get('Business');
                            apiFields.put(outboundField.label,outboundField);
                            apiFieldOutboundFields.put('Business',apiFields);
                        }
                    }else{
                        if(String.isBlank(String.valueOf(outboundField.APIType__c))){
                            Map<String, OutboundField__mdt> apiFields =  apiDefaultOutboundFields.get('Background');
                            apiFields.put(outboundField.label,outboundField);
                            apiDefaultOutboundFields.put('Background',apiFields);
                        }else{
                            Map<String, OutboundField__mdt> apiFields =  apiFieldOutboundFields.get('Background');
                            apiFields.put(outboundField.label,outboundField);
                            apiFieldOutboundFields.put('Background',apiFields);
                        }
                    }
                    
                }
            }
            for(Object obj:payload){
                if(obj!=null){
                    String objTopType = Utils.returnType(obj);
                    if(objTopType == 'Map<String,Object>'){
                        String validationType;                        
                        Map<String, Object> topObjectMap = (Map<String, Object>) obj; 
                        
                        Object childObj;
                        for(String  topAttrName:topObjectMap.keySet()){
                            if(topAttrName == validationTypeAttribute){
                                validationType = String.valueOf(topObjectMap.get(topAttrName));
                                System.debug('validationType: ' + validationType);
                            }
                            else{
                                childObj = topObjectMap.get(topAttrName);
                            }
                        }
                        if(childObj!=null && String.isNotBlank(validationType)){
                            Map<String, OutboundField__mdt> apiFields =  apiFieldOutboundFields.get(validationType);
                            System.debug('API Fields: ' + apiFields.size());
                            //Add any default fields that are not included in the api response
                            Map<String, OutboundField__mdt> defaultFields =  apiDefaultOutboundFields.get(validationType);
                            System.debug('defaultFields: ' + defaultFields);
                            for(String label :defaultFields.keyset()){
                                OutboundField__mdt defaultField = defaultFields.get(label);
                                System.debug('label:' + label + ' : ' +defaultField);
                                if(validationType == 'Background'){
                                    //System.debug('validationType bg:' );
                                    Utils.AddFieldToSObject(updateCon,defaultField.DataType__c,String.valueOf(defaultField.Value__c),defaultField.DefaultValue__c);
                                }else{
                                    //System.debug('validationType biz:' );
                                    Utils.AddFieldToSObject( updateAcct,defaultField.DataType__c,String.valueOf(defaultField.Value__c),defaultField.DefaultValue__c);
                                }                                
                            }
                            String childObjType = Utils.returnType(childObj);
                            if(childObjType == 'Map<String,Object>'){
                                Map<String, Object> childObjectMap = (Map<String, Object>) childObj;
                                for(String  childAttrName:childObjectMap.keySet()){
                                    if(childObjectMap.containsKey( childAttrName)){
                                        Object grandChild =childObjectMap.get( childAttrName);
                                        String grandChildObjType = Utils.returnType( grandChild);
                                        if(grandChildObjType != 'Map<String,Object>' && grandChildObjType != 'List<Object>'){
                                            if(apiFields.containsKey(childAttrName)){
                                                OutboundField__mdt outField = apiFields.get(childAttrName);
                                                Object fldValue =grandChild;
                                                String stringFldValue = string.valueOf(fldValue);
                                                System.debug('outField.Value__c: ' + outField.Value__c);
                                                stringFldValue = String.isBlank(stringFldValue) ? outField.Value__c : stringFldValue;
                                                if(fldValue != null &&  stringFldValue != 'null'){
                                                    if(String.isNotBlank(stringFldValue)){
                                                        stringFldValue = stringFldValue.trim();
                                                    }
                                                    if(validationType == 'Background'){
                                                        if(outField.Value__c =='Individual_Response_Code__c'){
                                                            //Get numeric value of Individual_Response_Code__c because Auction center sends the numeric value and ASAP sends the text value
                                                            if(contactIndRespCodeLabelValue.containsKey(stringFldValue)){
                                                                Utils.AddFieldToSObject(updateCon,outField.DataType__c,String.valueOf(outField.Value__c),contactIndRespCodeLabelValue.get(stringFldValue));
                                                            }else{
                                                                throw new custException(NO_MATCH_ERROR + 'Contact.Individual_Response_Code__c: ' + stringFldValue);
                                                            }
                                                        }else{
                                                            Utils.AddFieldToSObject(updateCon,outField.DataType__c,String.valueOf(outField.Value__c),stringFldValue);
                                                        }
                                                    }else{
                                                        if(outField.Value__c == 'Business_Response_Code__c'){
                                                            //Get numeric value of Business_Response_Code__c because Auction center sends the numeric value and ASAP sends the text value
                                                            if(acctBusRespCodLabelValue.containsKey(stringFldValue)){
                                                                Utils.AddFieldToSObject( updateAcct,outField.DataType__c,String.valueOf(outField.Value__c),acctBusRespCodLabelValue.get(stringFldValue));
                                                            }else{
                                                                throw new custException(NO_MATCH_ERROR + 'Account.Business_Response_Code__c: ' + stringFldValue);
                                                            }
                                                            
                                                        }
                                                        else{
                                                            Utils.AddFieldToSObject( updateAcct,outField.DataType__c,String.valueOf(outField.Value__c),stringFldValue);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else if(grandChildObjType == 'Map<String,Object>'){
                                            List<String> concatAttributes = respDescFields.get(validationType);
                                            System.debug('concatAttributes: ' + concatAttributes);
                                            String concatenateValue = '';
                                            Map<String, Object> grandChildObjMap = (Map<String, Object>) childObjectMap.get(childAttrName); 
                                            for(String grandChildAttrName:grandChildObjMap.keySet()){
                                                Object greatGrandChild = grandChildObjMap.get(grandChildAttrName);
                                                String greatGrandChildObjType = Utils.returnType( greatGrandChild);
                                                //System.debug('greatGrandChildObjType: ' + greatGrandChildObjType + ' : ' + grandChildAttrName + ' : ' + greatGrandChild);
                                                if(greatGrandChildObjType != 'Map<String,Object>' && greatGrandChildObjType != 'List<Object>'){
                                                    String stringFldValue = string.valueOf(greatGrandChild);
                                                    if(String.isNotBlank(stringFldValue)){
                                                        stringFldValue = stringFldValue.trim();
                                                    }                               
                                                    System.debug('grandChildAttrName: ' + grandChildAttrName);                 
                                                    //System.debug('grandChildContains: ' + concatAttributes.contains(grandChildAttrName));  
                                                    System.debug('concatAttributes: ' + concatAttributes);
                                                    if(String.isNotBlank(stringFldValue)){
                                                        if(concatAttributes.contains(grandChildAttrName)){                                                        
                                                            concatenateValue = String.isBlank(concatenateValue) ? grandChildAttrName + ' : ' +stringFldValue : 
                                                            concatenateValue + NEW_LINE + grandChildAttrName + ' : '+ stringFldValue;   
                                                        }else{
                                                            OutboundField__mdt outField = apiFields.get(grandChildAttrName);
                                                            if(validationType == 'Background'){
                                                                Utils.AddFieldToSObject(updateCon,outField.DataType__c,String.valueOf(outField.Value__c),stringFldValue);
                                                            }else{
                                                                Utils.AddFieldToSObject( updateAcct,outField.DataType__c,String.valueOf(outField.Value__c),stringFldValue);
                                                            }
                                                        }
                                                    }
                                                }
                                                else if(greatGrandChildObjType == 'List<Object>'){
                                                    List<Object> greatreatGrandChildObjList = (List<Object>) grandChildObjMap.get(grandChildAttrName); 
                                                    for(Object greatGreatGrandChildObj:greatreatGrandChildObjList){
                                                        String greatGreatGrandChildObjType = Utils.returnType( greatGreatGrandChildObj);
                                                        if(greatGreatGrandChildObjType == 'Map<String,Object>'){
                                                            Map<String, Object> greatGreatGrandObjMap = (Map<String, Object>) greatGreatGrandChildObj;
                                                            for(String greatGreatGreatGrandChildAttrName:greatGreatGrandObjMap.keySet()){
                                                                Object greatGreatGreatGrandChild = greatGreatGrandObjMap.get(greatGreatGreatGrandChildAttrName);
                                                                String greatGreatGreatGrandChildObjType = Utils.returnType( greatGreatGreatGrandChild);
                                                                if(greatGreatGreatGrandChildObjType == 'String'){                                                       
                                                                    String stringFldValue = string.valueOf(greatGreatGreatGrandChild);                                                                
                                                                    if(String.isNotBlank(stringFldValue)){
                                                                        stringFldValue = stringFldValue.trim();
                                                                    } 
                                                                    System.debug('greatGreatGreatGrandChildAttrName: ' + greatGreatGreatGrandChildAttrName);
                                                                    if(concatAttributes.contains(greatGreatGreatGrandChildAttrName)){
                                                                        concatenateValue = String.isBlank(concatenateValue) ? greatGreatGreatGrandChildAttrName + ' : ' + stringFldValue : 
                                                                        concatenateValue + NEW_LINE + greatGreatGreatGrandChildAttrName + ' : ' + stringFldValue;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }                                                
                                                }
                                            }
                                            //making change so that if prior Descriptions were populated previously due to fail check
                                            //and now biz or bg check is success, update descriptions to blank
                                            System.debug('*concatenateValues ' + concatenateValue);
                                            if(validationType == 'Background'){
                                                Utils.AddFieldToSObject(updateCon,'String','Individual_Response_Description__c',concatenateValue);
                                            }else{
                                                Utils.AddFieldToSObject(updateAcct,'String','Business_Response_Desc__c',concatenateValue);
                                            }
                                            
                                        }
                                    }   
                                }
                            }
                        }
                    }
                }
            }
            System.debug('Update acct: '+ JSON.serializePretty(updateAcct));
            System.debug('Update contact: '+ JSON.serializePretty(updateCon));            
            
            System.debug('updateAcct and updateCon'); 
            update updateAcct; 
            update updateCon;
            //set success integration log
            integrationLogs.put(EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message')?.Value__c,Account__c = acct.Id,Transection_Id__c = buyerId),false));
            writeLogs();
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            throw new custException(errorMsg);
            
        }
        
    }
     /*******************************************************************************************************
    * @description writes out integration logs
    * @return void
    */
    public void writeLogs(){
        System.debug('Integration Logs: ' + IntegrationLogs?.size());
        if(!IntegrationLogs.isEmpty()){
            Database.SaveResult[] srList = Database.insert(IntegrationLogs.Values(),false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {                               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error inserting Integration logs' +err.getStatusCode() + ': ' + err.getMessage() + err.getFields());
                    }
                }
            }
        }
    }
    /*******************************************************************************************************
    * @description standard execute method for Queueable that calls GetAPI methods
    * @return void
    */
    public void execute(QueueableContext context){  
        AccountTriggerHelper.accountFirstRun = false;
        System.debug('AccountTriggerHelper.accountFirstRun: ' + AccountTriggerHelper.accountFirstRun);    
        System.debug('apiName: ' + apiNames);
        System.debug('buyerId: '+ buyerId);
        System.debug('acctId: ' + acct.Id); 
        updateAcctError.Id = acct.Id;
        updateAcct.Id = acct.Id;
        //go get the account and contact 
        getAccountAndContact();
    }
    private class CustException extends Exception{}
}