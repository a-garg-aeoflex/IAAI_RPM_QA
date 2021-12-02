/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/Document__c.htm
*
* @description DocumentService is called from AccountTriggerHelper
*/
public without sharing class DocumentService implements Queueable, Database.AllowsCallouts{
    public string acctId;
    public String apiName;
    public String buyerId;
    public Account acct;
    public Boolean enqueueGetLicenses = false;
  
    private List<OutboundField__mdt> outboundFields;
    Map<String, List<OutboundField__mdt>> typeOutboundFields = new Map<String, List<OutboundField__mdt>>();

    /*******************************************************************************************************
    * @description Constructor - gets custom metadata
    * @return void
    */
    public  DocumentService(){
        outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c FROM OutboundField__mdt
        WHERE Type__c IN ('GetBuyerDocuments')];
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
    * @description sends a getbuyerdocuments api callout
    * @return void
    */
    public void GetAPI(){
        Account updateAcct;
        HttpResponse resp = new  HttpResponse();
        String endpoint;
        try{
            updateAcct = [SELECT Id,Get_Document_Status__c FROM Account WHERE Id=:acctId];
            updateAcct.Get_Document_Status__c = 'Available';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/GetBuyerDocuments/' + buyerId +'/400';
            resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, 'GetBuyerDocuments');
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                resp = Utils.sendRequest('GET',  endpoint, '', false,headers, 0, 'GetBuyerDocuments');
            }
            if(Utils.isResponseGood(resp)){
                System.debug('resp:' + resp.getBody() );
                List<Object> payload = (List<Object>)JSON.deserializeUntyped(resp.getBody());
                parsePayload(payload,endpoint );
            }else{
                //Lev 7.29.2021 - change for success and failed outbound logging
                Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Documents_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                    Request_Body__c='',Response_Body__c = resp.getStatus() + ' : ' + resp.getStatusCode() + ' : ' +resp?.getBody(),Account__c = acctId,Transection_Id__c = buyerId));
            } 
            update updateAcct; 

            if(enqueueGetLicenses && acct != null && buyerId != null){
                LicenseService licService = new LicenseService();
                licService.buyerId = String.valueOf(buyerId);
                licService.acct = acct;
                licService.apiName ='GetBuyerLicenses';
                System.enqueueJob(licService);
            }
        }
        Catch(Exception e){
            String errorMsg = e.getlineNumber() + ' : ' + e.getMessage();
			System.debug(errorMsg);
            //Lev 7.29.2021 - change for success and failed outbound logging
            Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Documents_Api').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                Request_Body__c='',Response_Body__c = errorMsg +  '\n' + resp?.getBody(),Account__c = acctId,Transection_Id__c = buyerId));
            update updateAcct; 
        } 
    }
    /*******************************************************************************************************
    * @description standard execute method for Queueable that calls GetAPI method
    * @return void
    */
    public void execute(QueueableContext context){
        AccountTriggerHelper.accountFirstRun = false;        
        System.debug('apiName: ' + apiName);
        System.debug('buyerId: '+ buyerId);
        if(apiName == 'GetBuyerDocuments'){
            GetAPI();
        }
    }
    /*******************************************************************************************************
    * @description parses the response from getbuyerdocument api
    * @param  payload List<Object> from parsed response
    * @return void
    */
    public Void parsePayload(List<Object> payload,String endpoint){
        
        System.debug('parsePayload');
        Map<String,Document__c> imageIdDocs = new  Map<String,Document__c>();
        Map<String,Image> imageIdLics = new Map<String,Image>();
        Map<String,Image> imageIdEmps = new Map<String,Image>();
        Map<String,List<String>> asapLicIdImageIds = new Map<String,List<String>>();
        Map<String,List<String>> empIdImageIds = new Map<String,List<String>>();
        try{
            Map<String, OutboundField__mdt> apiFieldOutboundFields = new Map<String, OutboundField__mdt>();
            List<OutboundField__mdt> outboundFields = typeOutboundFields.get('GetBuyerDocuments');
            List<License__c> licensesToUpsert = new List<License__c>();
            for(OutboundField__mdt outboundField:outboundFields){
                apiFieldOutboundFields.put(outboundField.label,outboundField);
            }

            //GetLicenseIds and EmployeIds
            for(Object obj:payload){
                
                if(obj!=null){
                    String objTopType = Utils.returnType(obj);
                    if(objTopType == 'Map<String,Object>'){
                        Map<String, Object> objectMap = (Map<String, Object>) obj; 
                        String imageId;
                        String licId;
                        String empId;
                        Document__c doc = new Document__c(Account__c = acctId );
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
                                    if(sfFieldName == 'Contact__c'){
                                        empId = stringFldValue;
                                    }else if(sfFieldName == 'License__c'){
                                        licId= stringFldValue;
                                    }else if(sfFieldName == 'Document_Key__c'){
                                        imageId = stringFldValue;
                                        doc.put(sfFieldName,stringFldValue);
                                    }
                                    else{
                                        if (fldType == 'DateTime'){                                                                                 
                                            //IIA-133 change timezone to central since asap is always sending central timezone
                                            doc.put(sfFieldName, Utils.ChangeDateTimeOffset(stringFldValue, 'America/Chicago'));
                                        }else{
                                            doc.put(sfFieldName,stringFldValue);
                                        }
                                    }
                                }
                            }                            
                        }
                        if(String.isNotBlank(imageId)){
                            System.debug('empId: ' + empId);
                            if(String.isNotBlank(empId)){
                                if(!empIdImageIds.containsKey(empId)){
                                    empIdImageIds.put(empId,new List<String>());
                                }
                                List<String> imgIds = empIdImageIds.get(empId);
                                imgIds.add(imageId);
                                empIdImageIds.put(empId,imgIds);
                               // imageIdEmps.put(imageId,new Image(imageId,empId));
                            }
                            System.debug('licId: ' + licId);
                            if(String.isNotBlank(licId)){
                                if(!asapLicIdImageIds.containsKey(licId)){
                                    asapLicIdImageIds.put(licId,new List<String>());
                                }
                                List<String> imgIds = asapLicIdImageIds.get(licId);
                                imgIds.add(imageId);
                                asapLicIdImageIds.put(licId,imgIds);
                                //imageIdLics.put(imageId,new Image(imageId,licId));
                            }
                            imageIdDocs.put(imageId,doc);
                        }
                        //System.debug('imageId: ' + imageId + ' licId: ' + licId + ' empId: ' + empId);
                        imageId = '';
                        licId = '';
                        empId = '';
                    }
                }
            }
            //Go get licenseIDs and EmployeeIds
            System.debug('asapLicIdImageIds: ' + asapLicIdImageIds.size());
            System.debug('empIdImageIds: ' + empIdImageIds.size());
            System.debug('imageIdDocs: ' + imageIdDocs.size());
            
            if(!asapLicIdImageIds.isEmpty()){
                List<License__c> lics = [SELECT Id,ASAP_License_ID__c FROM License__c WHERE ASAP_License_Id__c IN:asapLicIdImageIds.keyset()];
                System.debug('Licenses: ' + lics.Size());
                for(License__c lic: lics){
                    List<String> imageIds= asapLicIdImageIds.get(lic.ASAP_License_ID__c);
                    for(String imageId:imageIds){
                        imageIdLics.put(imageId,New Image(lic.ASAP_License_ID__c,lic.Id));                   
                    }
                }
            }
            if(!empIdImageIds.isEmpty()){
                List<Contact> cons = [SELECT Id,Buyer_Employee_ID__c FROM Contact WHERE Buyer_Employee_ID__c IN:empIdImageIds.keyset()];
                System.debug('Contacts: ' + cons.Size());
                for(Contact con: cons){
                    List<String> imageIds= empIdImageIds.get(con.Buyer_Employee_ID__c);
                    for(String imageId:imageIds){
                        imageIdEmps.put(imageId,New Image(con.Buyer_Employee_ID__c,con.Id));  
                    }
                    
                }
            }
            if(!imageIdLics.isEmpty() || !imageIdEmps.isEmpty()){
                //System.debug('adding imageIdLics: ' + imageIdLics + ' imageIdEmps: ' + imageIdEmps);
                for(String imgId:imageIdDocs.keyset()){
                    
                    Document__c doc = imageIdDocs.get(imgId);
                   
                    if(imageIdEmps.containsKey(imgId)){
                        Image img = imageIdEmps.get(imgId);
                        System.debug('imageIdEmployee: '+ imgId + 'image: ' + JSON.serializePretty(img));
                        doc.Contact__c = img.sfId;
                    }
                    if(imageIdLics.containsKey(imgId)){
                        Image img = imageIdLics.get(imgId);
                        System.debug('imageId:License: '+ imgId + 'image: ' + JSON.serializePretty(img));
                        doc.License__c = img.sfId;
                    }
                }
            }

            Set<Id> documentIdsUpserted = new Set<Id>();
            if(!imageIdDocs.isEmpty()){
                
                String errorMessage;
                Schema.SObjectField f = Document__c.Fields.Document_Key__c;	
                System.debug(imageIdDocs.Values());
                Database.UpsertResult[] srList =Database.upsert(imageIdDocs.Values(),f,false);
                Integer successCount =0;
                Integer failedCount = 0;		
                for(Integer i=0;i<srList.size();i++){
                    documentIdsUpserted.add(srList.get(i).getId());
                    if (srList.get(i).isSuccess()) {                       
                        successCount++;
                    }
                    else {
                        failedCount ++;
                        for(Database.Error err :srList.get(i).getErrors()) {				
                            errorMessage = String.isBlank(errorMessage) ? err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Document : ' + imageIdDocs.Values().get(i)
                                : errorMessage +': '+ err.getStatusCode() + ': ' + err.getMessage() + ': ' + err.getFields() + ' Document: ' + imageIdDocs.Values().get(i);
                            System.debug('errorMessage: ' + errorMessage);    
                        }	
                    }
                }

                
                
                
            
                System.debug('*SuccessCount: ' + successCount);
                System.debug('*FailedCount: ' + failedCount);
                if(String.isNotBlank(errorMessage)){
                    throw new custException(errorMessage);
                }else{
                    //Lev 7.29.2021 - change for success and failed outbound logging
                    Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Documents_Api').Value__c,Sent_To__c=endpoint,Status__c='Success',
                        Response_Body__c=EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message')?.Value__c,Account__c = acctId,Transection_Id__c = buyerId));
                }
            }

            List<Document__c> documentsNotInPayLoad = new List<Document__c>();
            if(acctId != null){
                 documentsNotInPayLoad = [
                    SELECT Id 
                    FROM Document__c
                    WHERE Id NOT IN :documentIdsUpserted
                        AND Account__c = :acctId
                ];
            }
            
            if(documentsNotInPayLoad.size() > 0){
                Database.DeleteResult[] drList = Database.delete(documentsNotInPayLoad, false);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        System.debug('Successfully deleted document with ID: ' + dr.getId());
                    }
                    else {             
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred during document delete:');                    
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
    public class Image{
        Image(String asap_Id,string sf_Id){
            asapId = asap_Id;
            sfId = sf_Id;
        }      
        public string asapId;
        public String sfId;
    }
    private class CustException extends Exception{}

}