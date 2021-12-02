/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/License__c.htm
*
* @description LicenseService is called from LicenseTriggerHelper and AccountTriggerHelper
*/

public without sharing class LicenseService implements Queueable, Database.AllowsCallouts{
    
    
    public ContentDocumentLink licenseToUploadLink;
    public ContentDocumentLink userLink;
    public ContentDocumentLink licenseLinkToDelete;
    public String licenseId;
    public String apiName;
    public String buyerId;
    public Account acct;
    public String acctId;
    public String actionType;    
    private Account updateAcct;
    private ContentVersion document;
    private ContentDocument doc;
    private String jsonstring;
    private License__c lic;
    private List<OutboundField__mdt> outboundFields;
    Map<String, List<OutboundField__mdt>> typeOutboundFields = new Map<String, List<OutboundField__mdt>>();
    private static final Set<String> countriesWithNoX = new Set<String>{'US','CA','MX','GU','GT'};

    @TestVisible public static final String ADDED_MORE_THAN_ONE_DOC_ON_LICENSE = 'Only one document can be added to the License.';

    /*******************************************************************************************************
    * @description Constructor - gets custom metadata
    * @return void
    */
    public LicenseService(){
        outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c FROM OutboundField__mdt
                    WHERE Type__c IN ('UploadLicense','UpdateLicense','GetBuyerLicenses')];
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
    * @description sends an UploadLicense or UpdateLicense api callout
    * @return void
    */
    public void SendAPI(){    
        String endpoint;
        String jsonstring;
        String truncatedJsonstring ='';
        String respBody = '';
        HttpResponse resp = new HttpResponse();
        try{
            System.debug('licenseId: '+ licenseId);
            System.debug('contentDocId: ' +licenseToUploadLink);
            System.debug('apiName: ' + apiName);
            System.debug('userLink: ' +userLink);
            
            lic =  getLicense(licenseId,typeOutboundFields.get(apiName));        

            if(lic!= null){
                if(licenseToUploadLink !=null && apiName !='UploadLicense'){
                    document =  [
                        SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                        FROM ContentVersion
                        WHERE ContentDocumentId =: licenseToUploadLink.ContentDocumentId AND IsLatest = true
                        ];
                    doc = [SELECT Id FROM ContentDocument WHERE Id=:licenseToUploadLink.ContentDocumentId];
                }
                RequestPayload req =createPayload(typeOutboundFields.get(apiName));
                jsonstring = req.payload;
                truncatedJsonstring = req.truncatedPayload;
                system.debug('jsonString: ' + jsonstring);
                //system.debug('truncatedJsonstring: ' + truncatedJsonstring);
                if(jsonstring!= null){
                    endpoint= 'callout:ASAPIntegration';
                    if(apiName =='UploadLicense'){
                       endpoint= endpoint + '/api/BuyerServices/UploadLicense';
                    }else{
                        endpoint=  endpoint + '/api/BuyerServices/UpdateLicense';
                    }
                    Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
                    Boolean retried = false;
                   try{
                       resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 120000, apiName);
                    }
                    catch(exception e){
                        retried = true;
                        
                        System.debug('retry catch');
                        resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 120000, apiName);
                    }

                    //Blindly Retry Once
                    if(!Utils.isResponseGood(resp) && !retried){
                        System.debug('retry');
                        //Lev 7.29.2021 - Added timeout for retry
                        resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 120000, apiName);
                    }
                    
                    //If response is good
                    if(Utils.isResponseGood(resp)){   
                        String licId;                     
                        respBody = resp.getBody();
                        if(respBody == '[]')
                        {
                            throw new custException('UpdateLicense API Failed: ' + licenseId + ' Response: ' + respBody);
                        }
                        if(respBody == null){
                            System.debug('Response is good!  ASAP_LicenseId: is blank');
                        }else{
                            List<Object> respList = (List<Object>)JSON.deserializeUntyped(respBody);
                            for(Object respObj:respList){
                                String respItem = String.valueOf(respObj);
                                if(respItem == '0'){
                                    throw new custException('UpdateLicense API Failed: ' + licenseId + ' Response: ' + respBody);
                                }else{
                                    licId = respItem;
                                    System.debug('Response is good!: ASAP_LicenseId: ' + licId);
                                }
                            }
                        }
                        
                        //if upload update the license with new asap license Id
                        if(apiName =='UploadLicense' && string.isNotBlank(licId)){      
                            System.debug('Updating license.');    
                            //set static var so we don't go run update api again
                            LicenseTriggerHelper.licenseFirstRun = false;                          
                            License__c licz = [SELECT Id,ASAP_License_Id__c,By_API__c FROM License__c WHERE Id=:licenseId];
                            licz.ASAP_License_Id__c = licId;
                            licz.By_API__c = true;
                            licz.Apex_Updated__c = System.currentTimeMillis();
                            Database.SaveResult sr = Database.update(licz,false);
                            String errorMessage;
                            if(!sr.isSuccess()) {  
                                for(Database.Error err : sr.getErrors()) {				
                                    errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  licz
                                        : errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Value: ' +  licz;
                                }		
                                throw new custException(errorMessage);	
                            }                                
                        }
                        //Lev 7.29.2021 - change for success and failed outbound logging
                        //Log Success
                        Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =apiName =='UploadLicense' ? EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c :EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                            Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_License_Success_Message')?.Value__c,Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = licenseId));
                    }//Log Error
                    else{
                        //Lev 7.29.2021 - change for success and failed outbound logging
                        Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =apiName =='UploadLicense' ? EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c :EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                            Request_Body__c= truncatedJsonstring,Response_Body__c =  + resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' + resp?.getBody(),Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = licenseId));
                    }
                    
                    //Phase 1: If success then go delete document
                    //Phase 2: Regardless of the status, delete the document (IAA-224)
                    if(document!=null){
                        System.debug('Deleting Document.');
                        //Go delete File Attachment
                        List<ContentDocumentLink> docuLinks = new List<ContentDocumentLink>{licenseToUploadLink};
                        if(userLink!=null){
                            docuLinks.add(userLink);
                        }
                        string errorMsgUserLinks = Utils.DMLDeleteHelperList(docuLinks,'Could not delete userLinks:');
                        if(String.isNotBlank(errorMsgUserLinks)){
                            //Lev 7.29.2021 - change for success and failed outbound logging
                            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                                Request_Body__c= truncatedJsonstring,Response_Body__c=errorMsgUserLinks +  '\n' + respBody,Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = licenseId));
                        }else{
                            string errorMsgDocument = Utils.DMLDeleteHelperList(new List<ContentDocument>{doc},'Could not delete document:');
                            if(String.isNotBlank(errorMsgDocument)){
                                //Lev 7.29.2021 - change for success and failed outbound logging
                                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                                    Request_Body__c=truncatedJsonstring,Response_Body__c=errorMsgDocument +  '\n' + respBody,Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = licenseId));
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' + errorMsg);
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =apiName =='UploadLicense' ? EnvironmentSetting__mdt.getInstance('BSO_Upload_Licenses_Api').Value__c :EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c= truncatedJsonstring,Response_Body__c=errorMsg +  '\n' + resp?.getBody(),Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = licenseId));
        }       
    }
    /*******************************************************************************************************
    * @description if multiple documents are added, log the exception and delete the document.
    *    Used in Queueable because if the trigger has an adderror or document is deleted in trigger context,
    *       an error is thrown and the Log will be rolled back
    * @return void
    */
    public void deleteDoc(){        
        if(licenseLinkToDelete!= null){
            System.debug('licenseLinksToDelete' + licenseLinkToDelete);
            List<License__c> licses =[SELECT Id,Name,Account__c,Account__r.API_Buyer_Id__c FROM License__c WHERE Id =:licenseId];
            if(!licses.isEmpty()){
                License__c lic = licses[0];                       
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_License_Api').Value__c,Sent_To__c='',Status__c='Failed',
                    Request_Body__c='',Response_Body__c=ADDED_MORE_THAN_ONE_DOC_ON_LICENSE,Account__c = lic.Account__c,Transection_Id__c = lic.Account__r.API_Buyer_Id__c,License__c = lic.Id));
                List<ContentDocument> contentDocs =  [SELECT Id FROM ContentDocument WHERE Id =:licenseLinkToDelete.ContentDocumentId];
                    delete licenseLinkToDelete; 
                if(!contentDocs.isEmpty()){
                    delete contentDocs;
                }
            }               
        }        
    }
    /*******************************************************************************************************
    * @description sends a GetBuyerLicenses api callout
    * @return void
    */
    public void GetAPI(){
        HttpResponse resp = new  HttpResponse();
        String endpoint;
        try{
            System.debug('*Account: ' + acct.Id);
            System.debug('*BuyerId:' + buyerId);
            User u = [SELECT Id,Username,Profile.Name,Profile.Id From User WHERE Id =: userinfo.getUserId()][0];
            System.debug('Profile: ' + u.Profile.Name);
            updateAcct = [SELECT Id,Get_License_Status__c FROM Account WHERE Id=:acct.Id];
            updateAcct.Get_License_Status__c = 'Available';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/GetBuyerLicenses/' + buyerId +'/400';
            resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, 'GetBuyerLicenses');
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                System.debug('retry');
                resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, 'GetBuyerLicenses');
            }
            if(Utils.isResponseGood(resp)){
                System.debug('resp:' + resp.getBody() );
                List<Object> payload = (List<Object>)JSON.deserializeUntyped(resp.getBody());
                parsePayload(payload );
                 //Log Success
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message')?.Value__c,Account__c = acct.Id,Transection_Id__c = buyerId));
            }else{
                System.debug('Error: GetBuyerLicenses' + resp.getStatus() + ' : ' + resp.getStatusCode());
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c= resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp.getBody(),Account__c = acct.Id,Transection_Id__c = buyerId,License__c = licenseId));
            } 
            update updateAcct; 
           
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' + errorMsg);
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c=ErrorMsg +  '\n' + resp.getBody(),Account__c = acct.Id,Transection_Id__c = buyerId,License__c = licenseId));
           
        } 
    }
    /*******************************************************************************************************
    * @description standard execute method for Queueable that calls GetAPI method
    * if calls GetAPI method for GetBuyerLicenses api or SendAPI for Upload or Update License API
    * @return void
    */
    public void execute(QueueableContext context){
        AccountTriggerHelper.accountFirstRun = false;
        if(apiName == 'GetBuyerLicenses'){
            GetAPI();
        }else if(apiName == 'DeleteDoc'){
            DeleteDoc();
        }
        else{
            SendAPI();
        }       
    }
    /*******************************************************************************************************
    * @description parses the payload for the GetBuyerLicenses api
    * @param  payload List<Object> from parsed response
    * @return void
    */
    public Void parsePayload(List<Object> payload ){
       System.debug('parsePayload');
        try{
            Map<String, OutboundField__mdt> apiFieldOutboundFields = new Map<String, OutboundField__mdt>();
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get('GetBuyerLicenses');
            List<License__c> licensesToUpsert = new List<License__c>();
            for(OutboundField__mdt outboundField:outboundFields){
                apiFieldOutboundFields.put(outboundField.label,outboundField);
            }
            for(Object obj:payload){
                License__c lic = new License__c(Account__c = acct.Id, By_API__c = true,Apex_Updated__c = System.currentTimeMillis());
                 if(obj!=null){
                    String objTopType = Utils.returnType(obj);
                    if(objTopType == 'Map<String,Object>'){
                        Map<String, Object> objectMap = (Map<String, Object>) obj;   
                        String state;
                        String country;                 
                        for(String field: objectMap.keyset()){
                            if(apiFieldOutboundFields.containsKey(field)){
                                OutboundField__mdt outField = apiFieldOutboundFields.get(field);
                                String fieldName = String.valueOf(outField.Label);
                                String sfFieldName =  String.valueOf(outField.Value__c);
                                String fldType = String.valueOf(outField.DataType__c);
                                if(String.isNotBlank(fieldName)){
                                    Object fldValue = objectMap.get(field);
                                    String stringFldValue = string.valueOf(fldValue);
                                    //System.debug('stringFldValue: ' + stringFldValue + ' sfFieldName: ' + sfFieldName);
                                    if(fldValue != null &&  stringFldValue != 'null'){
                                        if(String.isNotBlank(stringFldValue)){
                                            stringFldValue = stringFldValue.trim();
                                        }
                                        if(sfFieldName == 'State__c'){
                                            state = stringFldValue;
                                        }else if(sfFieldName == 'Country__c'){
                                            country =stringFldValue;
                                            lic.put(sfFieldName,stringFldValue);                                            
                                        }
                                        else{
                                            if (fldType == 'Date'){                                           
                                                //If getting datetime, truncate time	
                                                if(fldValue !=null){
                                                    String strValue = String.Valueof(fldValue);
                                                    if(strValue.indexOf('T') != -1){
                                                        strValue = strValue.left(strValue.indexOf('T'));
                                                    }
                                                    Date dt = (Date)Json.deserialize('"'+strValue+'"', Date.class);
                                                    lic.put(sfFieldName, dt);
                                                }					
                                            }else{
                                                lic.put(sfFieldName,stringFldValue);
                                            }                                        
                                        }                                    
                                    }
                                }
                            }
                        }
                        //System.debug('state: ' + state + ' country: ' + country);
                        //add county-state to state field because there are multiple states with the same name for diff countries
                        if(String.isNotBlank(country) && String.isNotBlank(state)){
                            //System.debug('countriesWithNo' + countriesWithNoX.contains(country));
                            if(countriesWithNoX.contains(country)){
                                lic.put('State__c',country+ '-' + state);
                            }else{
                                lic.put('State__c','XX-' + state);
                            }
                            
                        }
                        licensesToUpsert.add(lic);
                    }
                }    
            }
            System.debug('licensesToUpsert size: ' + licensesToUpsert.size());
            Set<Id> licenseIdsUpserted = new Set<Id>();
            if(!licensesToUpsert.isEmpty()){
                
                String errorMessage;
                //set static var so we don't go run update api again
                LicenseTriggerHelper.licenseFirstRun = false;
                Schema.SObjectField f = License__c.Fields.ASAP_License_Id__c;
                Database.UpsertResult[] srList =Database.upsert(licensesToUpsert,f,false);
                Integer successCount =0;
                Integer failedCount = 0;		
                for(Integer i=0;i<srList.size();i++){
                    licenseIdsUpserted.add(srList.get(i).getId());
                    if (srList.get(i).isSuccess()) {                       
                        successCount++;
                    }
                    else {
                        failedCount ++;
                        for(Database.Error err :srList.get(i).getErrors()) {				
                            errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' License : ' +  licensesToUpsert.get(i)
                                : errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' License: ' +  licensesToUpsert.get(i);
                            System.debug('errorMessage: ' + errorMessage);    
                        }	
                    }
                }
                System.debug('*SuccessCount: ' + successCount);
                System.debug('*FailedCount: ' + failedCount);
                if(String.isNotBlank(errorMessage)){
                    throw new custException(errorMessage);
                }
               
            //}
            }

            List<License__c> licensesNotInPayLoad = new List<License__c>();
            if(acct.Id != null){
                licensesNotInPayLoad = [
                    SELECT Id 
                    FROM License__c
                    WHERE Id NOT IN :licenseIdsUpserted
                        AND Account__c = :acct.Id
                ];
            }
            if(licensesNotInPayLoad.size() > 0){
                Database.DeleteResult[] drList = Database.delete(licensesNotInPayLoad, false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        System.debug('Successfully deleted license with ID: ' + dr.getId());
                    }
                    else {             
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred during license delete:');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error' + errorMsg);
			throw new custException(errorMsg);	
        }
    }
    /*******************************************************************************************************
    * @description - creates the payload for the Upload or Update License API
    * @param outboundFields custom metadata for specified callout name
    * @return 
    */
    public RequestPayload createPayload(List<OutboundField__mdt> outboundFields ){
        String jsonstring;
        String truncatedJsonstring;
        RequestPayload reqPayload = new RequestPayload();

        Map<String, Object> payload = new Map<String, Object>(); 
        Map<String, Object> truncatedPayload = new Map<String, Object>(); 
        List<Object> buyerLicenses = new List<Object>();
        List<Object> truncatedBuyerLicenses = new List<Object>();
        if(apiName == 'UpdateLicense'){
            payload.put('buyerLicense',buyerLicenses);
            truncatedPayload.put('buyerLicense',truncatedBuyerLicenses);
        }else{
            payload.put('licenses',buyerLicenses);
            truncatedPayload.put('licenses',truncatedBuyerLicenses);
        }
        Map<String,Object> tempBuyerLicenses = new Map<String,Object>();
        Map<String,Object> truncatedTempBuyerLicenses = new Map<String,Object>();
        buyerLicenses.add(tempBuyerLicenses);
        truncatedBuyerLicenses.add(truncatedTempBuyerLicenses);
        for(OutboundField__mdt outboundField:outboundFields){
            string apiField =  outboundField.Label;
            string sfField =  String.Valueof(outboundField.Value__c); 
            if(String.isNotBlank(apiField)){
                List<String> apiFields = New List<String>();
                List<String> sfFields = New List<String>();
                apiFields = apiField.split('\\.'); 
                String fieldToSendtoAPI = apiFields.size() > 1 ? apiFields[1] :  apiFields[0];
               // System.debug('fieldToSendtoAPI: ' + fieldToSendtoAPI);
                //System.debug('apiFields size: ' + apiFields.size());              
                if(String.isNotBlank(sfField)){  
                    sfFields = sfField.split('\\.'); 
                    if(sfFields.size() ==1){ 
                       //System.debug('sfField: ' +sfField);
                       Object objj = lic.get(sfField);
                       if(sfField == 'State__c'){
                            String stringValue = String.Valueof(objj);
                            if(String.isNotBlank(stringValue)){
                                stringValue = stringValue.Right(stringValue.length()-3);
                            }
                            AddFieldToSObject(payload, tempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, stringValue ,apiFields); 
                            AddFieldToSObject(truncatedPayload, truncatedTempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, stringValue ,apiFields);                      
                       }else{
                            AddFieldToSObject(payload, tempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, objj,apiFields);   
                            AddFieldToSObject(truncatedPayload, truncatedTempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, objj,apiFields);                      
                       }
                       
                    }else if(sfFields.size() ==2){ 
                        if(String.isNotBlank(sfFields[1])){
                            if(sfField.startsWith('ContentVersion') && document !=null){
                                String binaryFile = EncodingUtil.base64Encode(document.VersionData);
                                String truncatedFile;
                                if(String.isNotBlank(binaryFile)){
                                    truncatedFile = binaryFile.Left(20);
                                }
                                System.debug('binaryFile: ' + binaryFile);
                                System.debug('truncatedFile: ' + truncatedFile);                                
                                AddFieldToSObject(payload,tempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, binaryFile,apiFields); 
                                AddFieldToSObject(truncatedPayload,truncatedTempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, truncatedFile,apiFields); 
                            }else if(!sfField.startsWith('ContentVersion')){
                                Object valueToSendToAPI = lic.getSObject(sfFields[0]).get(sfFields[1]);
                                //System.debug(' valueToSendToAPI: ' +  valueToSendToAPI);
                                if(String.isNotBlank(sfField)){   
                                    AddFieldToSObject(payload,tempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, valueToSendToAPI,apiFields); 
                                    AddFieldToSObject(truncatedPayload,truncatedTempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, valueToSendToAPI,apiFields); 
                                }
                            }                        
                        }    
                    }              
                }
                else{ 
                    //System.debug('fieldToSendtoAPI1:' + fieldToSendtoAPI + ': ' + actionType + ' : ' + outboundField.DefaultValue__c);
                    AddFieldToSObject(payload,tempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, outboundField.DefaultValue__c,apiFields); 
                    AddFieldToSObject(truncatedPayload,truncatedTempBuyerLicenses,outboundField.dataType__c,fieldToSendtoAPI, outboundField.DefaultValue__c,apiFields);                    
                } 
            }            
        }
        reqPayload.truncatedPayload =json.serializePretty(truncatedPayload);
        reqPayload.payload = json.serializePretty(payload);
        return reqPayload;
    }
    public class RequestPayload{
        public String payload;
        public String truncatedPayload;
    }
    /*******************************************************************************************************
    * @description - Is called from createPayload method and adds to top level payload or Licenses child Object depending on fields size
    * @param payload - Map<String,Object> top level Map in Request of API
    * @param tempBuyerLicenses - Map<String,Object> Child Map in Request of API
    * @param fldType - field data type. string, date,etc
    * @param fldName - name of json attribute
    * @param fldValue - value of json attribute
    * @param apiFields - array of the apiField that is split from the config. 
    * @return void
    */
    public void AddFieldToSObject( Map<String,Object> payload, Map<String,Object> tempBuyerLicenses,string fldType,String fldName,Object fldValue,List<String> apiFields){
        if(apiFields.size() >1){ 
          Utils.AddFieldToSObject(tempBuyerLicenses,fldType,fldName,fldValue);
        }
        else{   
           Utils.AddFieldToSObject(payload,fldType,fldName,fldValue);
        }
    }
    /*******************************************************************************************************
    * @description retrieves the license with the fields from custom metadata
    * @return void
    */
    public License__c getLicense(String licenseId,List<OutboundField__mdt> outboundFields){
        
        License__c license;
        try{
            List<String> fields = new List<String>{'Id'};        
           
            for(OutboundField__mdt outboundField:outboundFields){
                String val = outboundField.Value__c;
                if(String.isNotBlank(val)){
                    if(!val.startsWith('ContentVersion')){
                        fields.add(outboundField.Value__c);
                    }                    
                }
            }
            String flds = String.join( fields,', ');
            System.debug('*flds ' + flds);
            String query = 'SELECT ' + String.escapeSingleQuotes(flds) + ' FROM License__c WHERE Id = :licenseId';    

            System.debug('*query ' + query);
            List<License__c> licenses = Database.query(query);
            if(!licenses.isEmpty()){
                license = licenses[0];
                System.debug('License: ' + license);
            }
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error ' + errorMsg);
			throw new custException(errorMsg);
        }
        return license;
    }    
    private class CustException extends Exception{}
}