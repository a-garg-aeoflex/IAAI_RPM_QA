public without sharing class RPM_APIController {
    
	@AuraEnabled
    public static void refreshFromRPM(String raId){
        //Create Release Assignment
        Id storageLocationRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Storage Location').getRecordTypeId();
        Id residentialRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Residential').getRecordTypeId();
         
        Case objCase = [SELECT Id,Stock__c,Stock__r.Name,CRC_Checksum__c,Account.BI_ID__c,CRC_Salvage_Id__c ,RecordTypeId FROM Case where Id=: raId];
        
        if(objCase.RecordTypeId != null && (objCase.RecordTypeId != storageLocationRT && objCase.RecordTypeId != residentialRT)){
            throw new CRC_Exception('Case does not have appropriate record type.'); 
        }

        try{
            if(objCase != null && objCase.Stock__c != null ){
                 RPM_AssignmentDetail(objCase);  
            }
        }catch(Exception e){
            throw new CRC_Exception(e.getMessage()); 
        }
    }
    
    public static void RPM_AssignmentDetail(Case objCase) {

        if(objCase.CRC_Salvage_Id__c == null){
            throw new CRC_Exception('Salvage Id on Case is null'); 
        }
      
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument( null, '1.0' );
        w.writeStartElement( null, 'IAAI_ASSIGNMENT_INFO', null );
        w.writeAttribute( null, null, 'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
        w.writeAttribute( null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
        w.writeAttribute( null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');
        w.writeStartElement( null, 'TRAN_ID', null ); w.writeCharacters(String.valueOf(System.now().millisecond()));  w.writeEndElement();
        w.writeStartElement( null, 'CREATE_DATETIME', null ); w.writeCharacters(String.valueOf(System.now()).replace(' ', 'T')); w.writeEndElement();
        w.writeStartElement( null, 'SENT_FROM', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName); w.writeEndElement();
        w.writeStartElement( null, 'VERSION', null ); w.writeCharacters('CC V1.0'); w.writeEndElement();
        w.writeStartElement( null, 'TRANSACTION_TYPE', null ); w.writeCharacters('ASGN DETAIL'); w.writeEndElement();
        w.writeStartElement( null, 'IAAI_STOCK_NUMBER', null ); w.writeCharacters(objCase.Stock__r.Name); w.writeEndElement();
        w.writeStartElement( null, 'SALVAGE_ID', null ); w.writeCharacters(objCase.CRC_Salvage_Id__c); w.writeEndElement();
        w.writeStartElement( null, 'RETURN_ALL_NOTES', null ); w.writeCharacters('Y'); w.writeEndElement();
        w.writeEndElement();
        w.writeEndDocument();
        String payload = w.getXmlString();
        system.debug( 'Payload is ' + payload);
        w.close();


    String soapResponse;
    RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
    Map<String,String> inputHeaderMap = new  Map<String,String>();
    Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
    String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
    inputHeaderMap.put('Authorization', authorizationHeader);
    obj.inputHttpHeaders_x = inputHeaderMap;
    obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
    
    soapResponse = obj.IAAI_ASSIGNMENT_INFO(payload,CRC_Constants.RPM_CREDENTIALS.DeveloperName);
    
    if(soapResponse != null && soapResponse.contains('<STATUS_CODE>ACCEPT</STATUS_CODE>')){
        EventBus.publish(new Console_Tab__e(Stock_Number__c=objCase.Stock__r.Name)); //Added by Anuj on 25th Nov, 21 as part of testing
        createLog('RPM', 'IAAI Salesforce', 'Refresh from ASAP/RPM' ,payload, soapResponse,CRC_Constants.RPM_CREDENTIALS.Endpoint__c,'Success');
        try{
            RPM_APIControllerHelper.RPM_PraseXML(soapResponse,objCase.CRC_Checksum__c,'salesforce');
        }catch(Exception e){
            throw new CRC_Exception(e.getMessage());
        }
    }else if(soapResponse.contains('<STATUS_CODE>REJECT</STATUS_CODE>')){
        createLog('RPM', 'IAAI Salesforce', 'Refresh from ASAP/RPM' ,payload, soapResponse,CRC_Constants.RPM_CREDENTIALS.Endpoint__c,'Failed');
        String str = soapResponse;
        str = str.substringAfter('<TRAN_ID>');
        str = '<IAAI_ASSIGNMENT_INFO><TRAN_ID>'+str;
        Dom.Document doc = new  Dom.Document();
        doc.load(str);
        Dom.XMLNode objMainNode = doc.getRootElement();
        String REJECT_REASON_CODE = objMainNode.getChildElement('REJECT_REASON_CODE', null).getText();
        String REJECT_REASON_DESCRIPTION = objMainNode.getChildElement('REJECT_REASON_DESCRIPTION', null).getText();
        String STATUS_CODE = objMainNode.getChildElement('STATUS_CODE', null).getText();
        throw new CRC_Exception('Error:'+STATUS_CODE + ':' + REJECT_REASON_CODE + ':' + REJECT_REASON_DESCRIPTION);
    }
    
}


    @AuraEnabled
    public static Map<String, Object> RPM_AddUserNotes(Map<String, Object> inputData) {
    
        Case c;
        if(inputData != null && inputData.get('Id') != null){
            String noteId = String.valueOf(inputData.get('Id'));
            c = [Select Id,CRC_Salvage_Id__c,Stock__r.Name from  case where Id =:noteId ];
        }

        XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument( null, '1.0' );
            w.writeStartElement( null, 'IAAI_ADD_USER_NOTE', null );
            w.writeAttribute( null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_add_user_note/');
            w.writeAttribute( null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
            w.writeStartElement( null, 'TRAN_ID', null ); w.writeCharacters(String.valueOf(System.now().millisecond()));  w.writeEndElement();
            w.writeStartElement( null, 'CREATE_DATETIME', null ); w.writeCharacters(String.valueOf(System.now()).replace(' ', 'T')); w.writeEndElement();
            w.writeStartElement( null, 'SENT_FROM', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName); w.writeEndElement();
            w.writeStartElement( null, 'VERSION', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c); w.writeEndElement();
            w.writeStartElement( null, 'TRANSACTION_TYPE', null ); w.writeCharacters('ADD NEW NOTE'); w.writeEndElement();
            w.writeStartElement( null, 'IAAI_STOCK_NUMBER', null ); w.writeCharacters(c.Stock__r.Name); w.writeEndElement();
            w.writeStartElement( null, 'SALVAGE_ID', null ); w.writeCharacters(c.CRC_Salvage_Id__c); w.writeEndElement();
            w.writeStartElement( null, 'ASAP_USER_ID', null ); w.writeCharacters('3'); w.writeEndElement();
            w.writeStartElement( null, 'CALL_CENTER_ID', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c); w.writeEndElement();
            w.writeStartElement( null, 'CALL_CENTER_USER_ID', null ); w.writeCharacters('csr2913'); w.writeEndElement();
            w.writeStartElement( null, 'CALL_CENTER_USER_NAME', null ); w.writeCharacters('Martinez Donna'); w.writeEndElement();
            w.writeStartElement( null, 'NOTE_CATEGORY', null ); w.writeCharacters(String.valueof(inputData.get('CRC_Note_Category__c'))); w.writeEndElement();
            w.writeStartElement( null, 'NOTE_TEXT', null ); w.writeCharacters(String.valueof(inputData.get('Description'))); w.writeEndElement();
            w.writeStartElement( null, 'PUBLIC_VIEWABLE_IND', null ); w.writeCharacters('Y'); w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            String payload = w.getXmlString();
            system.debug( 'Payload is ' + payload );
         w.close();

        String soapResponse;
        RPM_NotesController.BasicHttpBinding_INotes obj = new RPM_NotesController.BasicHttpBinding_INotes();
        Map<String,String> inputHeaderMap = new  Map<String,String>();
        Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
        String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
        inputHeaderMap.put('Authorization', authorizationHeader);
        obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
        obj.inputHttpHeaders_x = inputHeaderMap;
        soapResponse = obj.IAAI_ADD_USER_NOTE(payload,CRC_Constants.RPM_CREDENTIALS.DeveloperName);
        
        system.debug( 'Payload is soapResponse' + soapResponse );
        if(soapResponse != null && soapResponse.contains('<STATUS_CODE>ACCEPT</STATUS_CODE>')){
           
            createLog('CRCC', 'ASAP', 'ADD NEW NOTE' ,payload, soapResponse,CRC_Constants.RPM_CREDENTIALS.Endpoint__c,'Success');
           
             return new Map<String, Object>{'success' => true};
        }else if(soapResponse.contains('<STATUS_CODE>REJECT</STATUS_CODE>')){
            createLog('CRCC', 'ASAP', 'ADD NEW NOTE' ,payload, soapResponse,CRC_Constants.RPM_CREDENTIALS.Endpoint__c,'Failed');
           
            return new Map<String, Object>{'success' => false};
        }
        
        return new Map<String, Object>{'success' => false};
    }
    

    public static void testCallout() {
        String xmlSt = '<IAAI_STORAGE_LOCATION_LOOKUP xmlns="http://eai.iaa.com/AssignmentRelease/iaai_storage_location_lookup/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                        '<TRAN_ID>36bf689a-c1a4-4c34-aacc-414c1614a5aa</TRAN_ID>'+
                        '<CREATE_DATETIME>2019-04-22T16:21:16.564Z</CREATE_DATETIME>'+
                        '<SENT_FROM>CRCC</SENT_FROM>'+
                        '<VERSION>CC V1.9</VERSION>'+
                        '<TRANSACTION_TYPE>STOR LOC LOOKUP</TRANSACTION_TYPE>'+
                        '<LOCATION_SEARCH_CRITERIA>'+
                            '<COMPANY_NAME>residence</COMPANY_NAME>'+
                            '<ADDRESS_LINE1>'+
                                
                            '</ADDRESS_LINE1>'+
                            '<CITY>'+
                                
                            '</CITY>'+
                            '<STATE>NJ</STATE>'+
                            '<COUNTRY>US</COUNTRY>'+
                            '<ZIP>'+
                                
                            '</ZIP>'+
                        '</LOCATION_SEARCH_CRITERIA>'+
                    '</IAAI_STORAGE_LOCATION_LOOKUP>';
        
        String soapResponse;


        RPM_StorageLocationController.BasicHttpBinding_IStorageLocation obj = new RPM_StorageLocationController.BasicHttpBinding_IStorageLocation();
        IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'RPM'];
        Blob headerValue = Blob.valueOf('CRCC' + ':' + imdt.Password__c);
        String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
        Map<String,String> inputHeaderMap = new  Map<String,String>();
        inputHeaderMap.put('Authorization', authorizationHeader);
        obj.inputHttpHeaders_x = inputHeaderMap;
        soapResponse = obj.IAAI_STORAGE_LOCATION_LOOKUP(xmlSt, 'LYNX');
        System.debug(soapResponse);
    }

    public static void createLog(String fromName, String toName, String  callType ,String request, String response, String endpoint,String Status){
        Integration_logs__c objLog = new Integration_logs__c();
        objLog.Sent_From__c = fromName;
        objLog.Sent_To__c = toName;
        objLog.Endpoint_URL__c = endpoint;
        objLog.Transaction_Type__c = callType;
        objLog.Status__c = status;
        objLog.Request_Body__c = request;
        objLog.CRC_Response_Body__c = response;
        if(response.length()>32767){
            objLog.response_body__c = response.substring(0 , 32767);
         }else{
            objLog.response_body__c = response;
         }

        insert objLog;
    }

    
   
}