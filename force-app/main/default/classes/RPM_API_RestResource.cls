@RestResource(urlMapping='/iaai_rpm/*')
///services/apexrest/iaai_rpm
global with sharing class RPM_API_RestResource {
/* Post webservice for Carvio to send Stock update  
     * @param xml : XML String 
     * return     : Error per updated Email ID
    */
    public static string apiReturnedbody;
    public static string apiError;
    public static string apiStockNumber;
    public static string apiTRANS_ID;
    public static string apitransactionType;

    @HttpPost
    webService static String doPost() {
        RestRequest req = RestContext.request;
        Dom.Document doc = new Dom.Document();   
        String soapRequest = req.requestbody.tostring();
        Integration_logs__c objLog = new Integration_logs__c();
        objLog.Sent_From__c = 'AEO';
        objLog.Sent_To__c = 'AEO';
        objLog.Request_Body__c = soapRequest;
        objLog.CRC_Response_Body__c = soapRequest;
        insert objLog;
       
          
        if(soapRequest != null){
            try{
                //insert objLog;
                RPM_APIControllerHelper.RPM_PraseXML(soapRequest,null,'RPM');
                system.debug('---(apiReturnedbody)----'+apiReturnedbody);
                system.debug('---(apiError)----'+apiError);
                system.debug('---(apiStockNumber)----'+apiStockNumber);
                system.debug('---(apiTRANS_ID)----'+apiTRANS_ID);
                system.debug('---(apitransactionType)----'+apitransactionType);
                apiReturnedbody= createResponseForRPM(null,apiTRANS_ID,apiStockNumber,apitransactionType);
                RPM_APIController.createLog('RPM', 'Salesforce', 'Call from ASAP', soapRequest, apiReturnedbody,'https://iaaicsr--vpe2devpro.my.salesforce.com/services/apexrest/iaai_rpm','Success');
                //insert objLog;
                database.executebatch(new CRC_Priority_Update(),200);
                return apiReturnedbody;
            }catch(Exception e){
                
                system.debug('---(apiReturnedbody1)----'+apiReturnedbody);
                system.debug('---(apiError1)----'+apiError);
                system.debug('---(apiStockNumber1)----'+apiStockNumber);
                system.debug('---(apiTRANS_ID1)----'+apiTRANS_ID);
                system.debug('---(apitransactionType1)----'+apitransactionType);
                apiReturnedbody = createResponseForRPM(e.getMessage(),apiTRANS_ID,apiStockNumber,apitransactionType);
                RPM_APIController.createLog('RPM', 'Salesforce', 'Call from ASAP', soapRequest, apiReturnedbody,'https://iaaicsr--vpe2devpro.my.salesforce.com/services/apexrest/iaai_rpm','Failed');
                
                return apiReturnedbody;
            }
        }else{
            return 'Invalid request body';
        }



    }


    public static string createResponseForRPM(String error,String TRAN_ID,String stockNumber,String transactionType){
                 system.debug('---(error)----'+error);
                system.debug('---(TRANS_ID)----'+TRAN_ID);
                system.debug('---(stockNumber)----'+stockNumber);
                system.debug('---(transactionType)----'+transactionType);
        XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument( null, '1.0' );
            w.writeStartElement( null, 'IAAI_ASSIGNMENT_INFO', null );
            w.writeAttribute( null, null, 'xmlns','http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');
            w.writeAttribute( null, null, 'xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
            w.writeStartElement( null, 'TRAN_ID', null ); w.writeCharacters(TRAN_ID); w.writeEndElement();
            w.writeStartElement( null, 'CREATE_DATETIME', null ); w.writeCharacters(String.valueOf(System.now())); w.writeEndElement();
            w.writeStartElement( null, 'SENT_FROM', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName); w.writeEndElement();
            w.writeStartElement( null, 'VERSION', null ); w.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c); w.writeEndElement();
            w.writeStartElement( null, 'TRANSACTION_TYPE', null ); w.writeCharacters(transactionType); w.writeEndElement();
            w.writeStartElement( null, 'IAAI_STOCK_NUMBER', null ); w.writeCharacters(stockNumber); w.writeEndElement();
            if(error != null){
                w.writeStartElement( null, 'STATUS_CODE', null ); w.writeCharacters('REJECT'); w.writeEndElement();
                w.writeStartElement( null, 'REJECT_REASON_DESCRIPTION', null ); w.writeCharacters(error); w.writeEndElement();
            }else{
                w.writeStartElement( null, 'STATUS_CODE', null ); w.writeCharacters('ACCEPT'); w.writeEndElement();
            }
            w.writeEndElement();
            w.writeEndDocument();
            String payload = w.getXmlString();
            system.debug( 'Payload to send back ' + payload );
         w.close();

         return payload;
    }


}