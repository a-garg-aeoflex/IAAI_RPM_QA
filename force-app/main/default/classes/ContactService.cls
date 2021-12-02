/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/Contact.htm
*
* @description ContactService is called from ContactTriggerDispatcher and ContentDocumentLinkHandler
*/
public with sharing class ContactService implements Queueable, Database.AllowsCallouts{
    public Contact con = new Contact();
    public Contact updateCon = new Contact();
    public String contactId;    
    public String buyerId;
    public List<String> apiNames = new List<String>();
    public String apiName;
    public ContentDocumentLink contactToUploadLink;
    public ContentDocumentLink contactLinkToDelete;
    public Contact contactRefContactLinkToDelete;
    public ContentDocumentLink userLink;
    
    private List<OutboundField__mdt> outboundFields;
    private ContentVersion document;
    private ContentDocument doc;

    @TestVisible public static final String ADDED_MORE_THAN_ONE_DOC_ON_CONTACT = 'Only one document can be added to the Contact.';
    private static final String NEW_LINE = '\n' ;
    Map<String, List<OutboundField__mdt>> typeOutboundFields = new Map<String, List<OutboundField__mdt>>();
    
    /*******************************************************************************************************
    * @description Constructor - gets custom metadata
    * @return void
    */
    public ContactService(){
        outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c,SFObject__c,RequiredField__c FROM OutboundField__mdt
                    WHERE Type__c IN ('UpdateEmployeeDocument','UpdateBuyerEmployee')];
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
    * @description sends an UpdateBuyerEmployee api callout
    * @return void
    */
    public void SendUpdateBuyerEmployeeAPI(List<OutboundField__mdt> outFields){    
        String endpoint;
        String jsonPayload;
        String apiName = 'UpdateBuyer';
        HttpResponse resp = new HttpResponse();
        try{
            System.debug('SendUpdateBuyerEmployee:');
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get('UpdateBuyer');
            Map<String,Object> identification = new Map<String,Object>();
            endpoint = 'callout:ASAPIntegration'+ '/api/BuyerServices/UpdateBuyerEmployee';

            Map<String,Object> payload = new Map<String,Object>{'identification' => new List<Object>{identification}};
            for(OutboundField__mdt outField:outFields){
                String fieldName = String.valueOf(outField.Label);
                String sfFieldName =  String.valueOf(outField.Value__c);
                String defaultValue = String.valueOf(outField.DefaultValue__c);
                List<String> apiFields = New List<String>();               
                apiFields = fieldName.split('\\.');
                
                if(String.IsNotBlank(defaultValue)){
                    if(apiFields.size() ==1){ 
                        Utils.AddFieldToSObject(payload,outField.dataType__c,fieldName,defaultValue);
                    }else  if(apiFields.size() ==2){
                        Utils.AddFieldToSObject(identification,outField.dataType__c,apiFields[1],defaultValue);
                    }
                }else{
                    System.debug('outboundField: ' + outField);
                    Object obj = con.get(sfFieldName);
                    String stringValue = String.Valueof(obj);                       
                    if(sfFieldName == 'ID_State_Issued__c'){                            
                        if(String.isNotBlank(stringValue)){
                            obj = stringValue.Right(stringValue.length()-3);
                        }
                    }
                    //IAA-14 -for UpdateEmployeeDocuments exclude blank values if not required by api
                    if(((String.isNotBlank(stringValue) && outField.RequiredField__c == false) || (outField.RequiredField__c ==true))){ 
                        if(apiFields.size() ==1){ 
                            Utils.AddFieldToSObject(payload,outField.dataType__c,fieldName,obj);
                        }else  if(apiFields.size() ==2){
                            Utils.AddFieldToSObject(identification,outField.dataType__c,apiFields[1],obj);
                        }
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
                System.debug('UpdateBuyerEmployee Response Is Good: ' + resp.getBody() );                
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                    Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Contact_Success_Message')?.Value__c,Account__c = con?.AccountId,Contact__c = con?.Id, Transection_Id__c = con.Account_API_Buyer_Id__c));
            }else{
                throw new CustException('Failed Updating UpdateBuyerEmployee: ' + resp.getBody());
            }

        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error: ' + errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging            	
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c=jsonPayload,  Response_Body__c=errorMsg + NEW_LINE + resp?.getBody(),Account__c = con?.AccountId,Contact__c = con?.Id, Transection_Id__c = con.Account_API_Buyer_Id__c));
        }

    }
    /*******************************************************************************************************
    * @description retrieves the contact with the fields from custom metadata
    * @return void
    */
    public void getContact(List<OutboundField__mdt> outboundFields){
        
        Contact con;
        try{
            List<String> fields = new List<String>{'Id'};        
           
            for(OutboundField__mdt outboundField:outboundFields){
                String sobjectName = outboundField.SFObject__c;
                if(sobjectName =='Contact'){                  
                    fields.add(outboundField.Value__c);
                }
            }
            if(!fields.contains('AccountId')){
                fields.add('AccountId');
            }
            String flds = String.join( fields,', ');
            System.debug('*flds ' + flds);
            String query = 'SELECT ' + String.escapeSingleQuotes(flds) + ' FROM Contact WHERE Id = :contactId';    

            System.debug('*query ' + query);
            List<Contact> cons = Database.query(query);
            if(!cons.isEmpty()){
                updateCon = cons[0];
                System.debug('updateCon: ' + updateCon);
            }
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug('Error ' + errorMsg);
			throw new custException(errorMsg);
        }
    }    
   
     /*******************************************************************************************************
    * @description - creates the payload for the UpdateEmployeeDocument api API
    * @param outboundFields custom metadata for specified callout name
    * @return 
    */
    public RequestPayload createPayload(List<OutboundField__mdt> outboundFields ){
        String jsonstring;
        String truncatedJsonstring;
        RequestPayload reqPayload = new RequestPayload();
       
        Map<String, Object> payload = new Map<String, Object>();
        Map<String, Object> truncatedPayload = new Map<String, Object>(); 
        Map<String,Object> employeeIdentifications = new Map<String,Object>();
        payload.put('employeeIdentification',employeeIdentifications);
        truncatedPayload.put('employeeIdentification',employeeIdentifications);
        for(OutboundField__mdt outboundField:outboundFields){
            string apiField =  outboundField.Label;
            string sfField =  String.Valueof(outboundField.Value__c); 
            if(String.isNotBlank(apiField)){
                List<String> apiFields = New List<String>();
                List<String> sfFields = New List<String>();
                apiFields = apiField.split('\\.'); 
                String fieldToSendtoAPI = apiFields.size() > 1 ? apiFields[1] :  apiFields[0];
                System.debug('fieldToSendtoAPI: ' + fieldToSendtoAPI);
                System.debug('apiFields size: ' + apiFields.size());              
                if(String.isNotBlank(sfField)){  
                    sfFields = sfField.split('\\.'); 
                    if(apiFields.size() ==1){ 
                        //System.debug('sfField: ' +sfField);
                        if(sfField.startsWith('ContentVersion') && document !=null){
                            String binaryFile = EncodingUtil.base64Encode(document.VersionData);
                            String truncatedFile;
                            if(String.isNotBlank(binaryFile)){
                                truncatedFile = binaryFile.Left(20);
                            }
                            AddFieldToSObject(payload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI,binaryFile,apiFields); 
                            //Add truncatedFile to truncatedPayload to shorten integration log object record since the file is only 32,000 chars
                            AddFieldToSObject(truncatedPayload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, truncatedFile,apiFields); 
                        }else{
                            Object obj = updateCon.get(sfField); 
                            String stringValue = String.Valueof(obj);  
                            //IAA-14 -for UpdateEmployeeDocuments exclude blank values if not required by api
                            if(((String.isNotBlank(stringValue) && outboundField.RequiredField__c == false) || (outboundField.RequiredField__c ==true))){ 
                                AddFieldToSObject(payload, employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, obj ,apiFields);    
                                AddFieldToSObject(truncatedPayload, employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, obj ,apiFields); 
                            }                                            
                        }                        
                    }else if(apiFields.size() ==2){
                        Object obj = updateCon.get(sfField);
                        String stringValue = String.Valueof(obj);
                        //System.debug(' valueToSendToAPI: ' +  stringValue);
                        if(sfField == 'ID_State_Issued__c'){                            
                            if(String.isNotBlank(stringValue)){
                                obj = stringValue.Right(stringValue.length()-3);
                            }
                        }
                        //IAA-14 -for UpdateEmployeeDocuments exclude blank values if not required by api
                        if(((String.isNotBlank(stringValue) && outboundField.RequiredField__c == false) || (outboundField.RequiredField__c ==true))){ 
                            AddFieldToSObject(payload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, obj,apiFields); 
                            AddFieldToSObject(truncatedPayload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, obj,apiFields); 
                        }
                     }              
                }
                else{ 
                    //System.debug('fieldToSendtoAPI1:' + fieldToSendtoAPI + ': ' + actionType + ' : ' + outboundField.DefaultValue__c);
                    AddFieldToSObject(payload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, outboundField.DefaultValue__c,apiFields); 
                    AddFieldToSObject(truncatedPayload,employeeIdentifications,outboundField.dataType__c,fieldToSendtoAPI, outboundField.DefaultValue__c,apiFields);                    
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
    * @description - Is called from createPayload method and adds to top level payload or employeeIdentifications child Object depending on fields size
    * @param payload - Map<String,Object> top level Map in Request of API
    * @param employeeIdentifications - Map<String,Object> Child Map in Request of API
    * @param fldType - field data type. string, date,etc
    * @param fldName - name of json attribute
    * @param fldValue - value of json attribute
    * @param apiFields - array of the apiField that is split from the config. 
    * @return void
    */
    public void AddFieldToSObject( Map<String,Object> payload, Map<String,Object> employeeIdentifications,string fldType,String fldName,Object fldValue,List<String> apiFields){
        if(apiFields.size() >1){ 
          System.debug(' AddFieldToSObject: apiFields' + apiFields.size());
          Utils.AddFieldToSObject(employeeIdentifications,fldType,fldName,fldValue);
          System.debug(' AddFieldToSObject: employeeIdentifications' + employeeIdentifications);
        }
        else{   
           Utils.AddFieldToSObject(payload,fldType,fldName,fldValue);
        }
    }
    /*******************************************************************************************************
    * @description sends an UpdateEmployeeDocument api callout
    * @return void
    */
    public void SendUpdateEmployeeDocumentAPI() {
        String endpoint;
        String jsonstring;
        String truncatedJsonstring ='';
        HttpResponse resp = new HttpResponse();
        String accountId;
        String buyerId;
        try{
            System.debug('contactId: '+ contactId);
            System.debug('contentDocId: ' +contactToUploadLink);
            System.debug('apiName: ' +apiName);
            getContact(typeOutboundFields.get(apiName));
            if(updateCon!= null){
                accountId = updateCon?.accountId;
                buyerId = updateCon?.Account_API_Buyer_Id__c;
                if(contactToUploadLink !=null){
                    document =  [
                        SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                        FROM ContentVersion
                        WHERE ContentDocumentId =: contactToUploadLink.ContentDocumentId AND IsLatest = true
                        ];
                    doc = [SELECT Id FROM ContentDocument WHERE Id=:contactToUploadLink.ContentDocumentId];
                }
                RequestPayload req =createPayload(typeOutboundFields.get(apiName));
                jsonstring = req.payload;
                truncatedJsonstring = req.truncatedPayload;
                system.debug('jsonString: ' + jsonstring);
                //system.debug('truncatedJsonstring: ' + truncatedJsonstring);
                if(jsonstring!= null){
                    endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/UpdateEmployeeDocument';
                    
                    Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
                    resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 0, apiName);
                    //Blindly Retry Once
                    if(!Utils.isResponseGood(resp)){
                        System.debug('retry');
                        resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers , 0, apiName);
                    }
                    //If response is good
                    if(Utils.isResponseGood(resp)){   
                        String licId;                     
                        String respBody = resp.getBody();
                        if(respBody == null){
                            System.debug('Response is good!' + respBody);
                        }
                        
                    
                    }//Log Error
                    else{
                        //Lev 7.29.2021 - change for success and failed outbound logging
                        Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                            Request_Body__c=truncatedJsonstring, Response_Body__c=resp?.getBody(),Account__c = accountId,Contact__c = contactId, Transection_Id__c = buyerId));
                    }   
                    Boolean docError = false;
                        //Phase 1: If success then go delete document
                        //Phase 2: Regardless of the status, delete the document (IAA-224)
                        if(document!=null){
                            System.debug('Deleting Document.');
                            //Go delete File Attachment
                            List<ContentDocumentLink> docuLinks = new List<ContentDocumentLink>{contactToUploadLink};
                            if(userLink!=null){
                                docuLinks.add(userLink);
                            }
                            string errorMsgUserLinks = Utils.DMLDeleteHelperList(docuLinks,'Could not delete userLinks:');
                            if(String.isNotBlank(errorMsgUserLinks)){
                                docError = true;
                                //Lev 7.29.2021 - change for success and failed outbound logging
                                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                                    Request_Body__c=truncatedJsonstring, Response_Body__c=errorMsgUserLinks + NEW_LINE + resp?.getBody(),Account__c = accountId,Contact__c = contactId, Transection_Id__c = buyerId));
                            }else{
                                string errorMsgDocument = Utils.DMLDeleteHelperList(new List<ContentDocument>{doc},'Could not delete document:');                                
                                if(String.isNotBlank(errorMsgDocument)){
                                    docError = true;
                                    ///Lev 7.29.2021 - change for success and failed outbound logging
                                    Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                                        Request_Body__c=truncatedJsonstring, Response_Body__c=errorMsgDocument + NEW_LINE + resp?.getBody(),Account__c = accountId,Contact__c = contactId, Transection_Id__c = buyerId));
                                }
                            }
                        }
                        //log Success
                        if(docError == false){
                            //Lev 7.29.2021 - change for success and failed outbound logging
                            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                                Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Contact_Success_Message')?.Value__c,Account__c = accountId,Contact__c = contactId, Transection_Id__c = buyerId));
                        }
                                     
                }    
            
            }
        }
        catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' + errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c=truncatedJsonstring, Response_Body__c=resp?.getBody(),Account__c = accountId,Contact__c = contactId, Transection_Id__c = buyerId));
            
        }
    }
    /*******************************************************************************************************
    * @description if multiple documents are added, log the exception and delete the document.
    *    Used in Queueable because if the trigger has an adderror or document is deleted in trigger context,
    *       an error is thrown and the Log will be rolled back
    * @return void
    */
    //Lev 7.29.2021 - change for success and failed outbound logging
    public void deleteDoc(){        
        if(contactLinkToDelete!= null){
            System.debug('contactLinkToDelete: ' + contactLinkToDelete);           
            if(contactRefContactLinkToDelete!= Null){                                   
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Update_Employee_Document_Api').Value__c,Sent_To__c='',Status__c='Failed',
                    Request_Body__c='',Response_Body__c=ADDED_MORE_THAN_ONE_DOC_ON_CONTACT,Account__c = contactRefContactLinkToDelete.AccountId,Transection_Id__c = contactRefContactLinkToDelete.Account.API_Buyer_Id__c,Contact__c = contactRefContactLinkToDelete.Id));
                List<ContentDocument> contentDocs =  [SELECT Id FROM ContentDocument WHERE Id =:contactLinkToDelete.ContentDocumentId];
                delete contactLinkToDelete; 
                if(!contentDocs.isEmpty()){
                    delete contentDocs;
                }
            }               
        }        
    }
    /*******************************************************************************************************
    * @description standard execute method for Queueable that calls GetAPI methods
    * @return void
    */
    public void execute(QueueableContext context){  
        ContactTriggerDispatcher.ContactFirstRun = false;
        System.debug('ContactTriggerDispatcher.ContactFirstRun: ' + ContactTriggerDispatcher.ContactFirstRun);    
        System.debug('apiName: ' + apiNames);
        //System.debug('buyerId: '+ buyerId);
        System.debug('conId: ' + con.Id);
        if(apiName == 'UpdateEmployeeDocument'){
            SendUpdateEmployeeDocumentAPI();
        }else if(apiNames.contains('UpdateBuyerEmployee')){
            SendUpdateBuyerEmployeeAPI(typeOutboundFields.get('UpdateBuyerEmployee'));
        }else if(apiName == 'DeleteDoc'){
            DeleteDoc();
        }


    }
    private class CustException extends Exception{}
}