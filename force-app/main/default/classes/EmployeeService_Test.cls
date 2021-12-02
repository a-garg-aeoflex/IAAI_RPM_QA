/**
* Lev - updated exisiting test class and adding commments
* @date 2021
*
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
*
* @description Apex coverage for EmployeeService
*/
@isTest
private class EmployeeService_Test {
    static Branch__c branch;
    static Account acct;
    static Id brokerAccountRecTypeId;
    static {
        branch = TestDataFactory.createBranches(true,1,713)[0];
        acct = TestDataFactory.createAccounts(false,1,'test','')[0];
        brokerAccountRecTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
    }

    @isTest
    private static void EmployeePositive(){
       
        acct.BI_ID__c = '440523';
        acct.recordTypeId = brokerAccountRecTypeId;
        insert acct;
        String myJSON ='{'+
        ''+
        '  \"Updates\": ['+
        ''+
        '    {'+
        ''+
        '      \"Buyer\": null,'+
        ''+
        '      \"Employees\": {'+
        ''+
        '        \"BuyerId\": \"440523\",'+
        ''+
        '        \"BuyerEmployeeId\": \"788388\",'+
        ''+
        '        \"StatusCode\": \"ACT\",'+
        ''+
        '        \"JobTitleCode\": \"OWNR\",'+
        ''+
        '        \"FirstName\": \"Nino\",'+
        ''+
        '        \"LastName\": \"Tkemaladze\",'+
        ''+
        '        \"Address1\": \"Khataetist 481101\",'+
        ''+
        '        \"City\": \"Tbilisi\",'+
        ''+
        '        \"State\": \"XX \",'+
        ''+
        '        \"Country\": \"GE\",'+
        ''+
        '        \"Zip\": \"0110\",'+
        ''+
        '        \"Phone\": \"\",'+
        ''+
        '        \"EMailAddress1\": \"bsoni@iaai.com\",'+
        ''+
        '        \"ContactTypeBuyerOrUser\": \"U\",'+
        ''+
        '        \"MiddleInitial\": \" \",'+
        ''+
        '        \"UserId\": \"16688970\",'+
        ''+
        '        \"MobilePhoneNumber\": \"\",'+
        ''+
        '        \"Gender\": \" \",'+
        ''+
        '        \"PrimaryContactMethodCode\": \"BE\",'+
        ''+
        '        \"BirthDate\": \"09/02/1997\",'+
        ''+
        '        \"LanguageCode\": \"ENG\"'+
        ''+
        '      }'+
        ''+
        '    }'+
        ''+
        '  ],'+
        ''+
        '  \"TransactionID\": \"c9fceabb-bf13-4a11-8dfc-40a40abc1f66\",'+
        ''+
        '  \"CreatedTime\": \"2020-06-19T08:50:29.1109815-05:00\",'+
        ''+
        '  \"SentFrom\": \"IAAI\",'+
        ''+
        '  \"SentTo\": \"SCRM\",'+
        ''+
        '  \"TransactionType\": \"IAAI_EMPLOYEE_UPDATE\",'+
        ''+
        '  \"Version\": \"V1.0\"'+
        ''+
        '}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--manish.my.salesforce.com/services/apexrest/updateEmployee';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;    
        System.Test.startTest();   
        EmployeeService objBS = new EmployeeService();
        EmployeeService.updateEmployee();   
        EmployeeService.SalesforceError objne = new  EmployeeService.SalesforceError('123','tes');
        System.Test.stopTest();
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody); 
        EmployeeResp resp =  (EmployeeResp)JSON.deserializeStrict(respBody, EmployeeResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Contact is blank' + sfId  + ' : ' + resp?.response);
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is not greate than zero: ' + logs.size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is not zero: ' + logs.size() + ' : ' + logsConcat);
     }    
     @isTest
    private static void NoBuyerEmployeeIdNegative(){
    
        
        acct.BI_ID__c = '440523';
        acct.recordTypeId = brokerAccountRecTypeId;
        insert acct;
        //possible creating a contact?
        String myJSON ='{'+
        ''+
        '  \"Updates\": ['+
        ''+
        '    {'+
        ''+
        '      \"Buyer\": null,'+
        ''+
        '      \"Employees\": {'+
        ''+
        '        \"BuyerId\": \"440523\",'+
        ''+
        '        \"BuyerEmployeeId\": \"\",'+
        ''+
        '        \"StatusCode\": \"ACT\",'+
        ''+
        '        \"JobTitleCode\": \"OWNR\",'+
        ''+
        '        \"FirstName\": \"Nino\",'+
        ''+
        '        \"LastName\": \"Tkemaladze\",'+
        ''+
        '        \"Address1\": \"Khataetist 481101\",'+
        ''+
        '        \"City\": \"Tbilisi\",'+
        ''+
        '        \"State\": \"XX \",'+
        ''+
        '        \"Country\": \"GE\",'+
        ''+
        '        \"Zip\": \"0110\",'+
        ''+
        '        \"Phone\": \"\",'+
        ''+
        '        \"EMailAddress1\": \"bsoni@iaai.com\",'+
        ''+
        '        \"ContactTypeBuyerOrUser\": \"U\",'+
        ''+
        '        \"MiddleInitial\": \" \",'+
        ''+
        '        \"UserId\": \"16688970\",'+
        ''+
        '        \"MobilePhoneNumber\": \"\",'+
        ''+
        '        \"Gender\": \" \",'+
        ''+
        '        \"PrimaryContactMethodCode\": \"BE\",'+
        ''+
        '        \"BirthDate\": \"09/02/1997\",'+
        ''+
        '        \"LanguageCode\": \"ENG\"'+
        ''+
        '      }'+
        ''+
        '    }'+
        ''+
        '  ],'+
        ''+
        '  \"TransactionID\": \"c9fceabb-bf13-4a11-8dfc-40a40abc1f66\",'+
        ''+
        '  \"CreatedTime\": \"2020-06-19T08:50:29.1109815-05:00\",'+
        ''+
        '  \"SentFrom\": \"IAAI\",'+
        ''+
        '  \"SentTo\": \"SCRM\",'+
        ''+
        '  \"TransactionType\": \"IAAI_EMPLOYEE_UPDATE\",'+
        ''+
        '  \"Version\": \"V1.0\"'+
        ''+
        '}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--manish.my.salesforce.com/services/apexrest/updateEmployee';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();   
        EmployeeService objBS = new EmployeeService();
        EmployeeService.updateEmployee(); 
        EmployeeService.SalesforceError objne = new  EmployeeService.SalesforceError('123','tes');  
        System.Test.stopTest();  
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody); 
        EmployeeResp resp =  (EmployeeResp)JSON.deserializeStrict(respBody, EmployeeResp.class);
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assertEquals(0, successAndErrorLogs.get('Success').size(), 'Success Log count is not zero: ' + logs.size() + ' : ' + logsConcat); 
        System.assert(successAndErrorLogs.get('Error').size() >0, 'Error Log count is not equal to 1 or more: ' + logs.size() + ' : ' + logsConcat); 
    }
    @IsTest
    static void BadPayloadNegative(){
        String payload = 'test234';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/updateEmployee';
        req.requestBody = Blob.valueof(payload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();   
        EmployeeService objBS = new EmployeeService();
        EmployeeService.updateEmployee();   
        EmployeeService.SalesforceError objne = new  EmployeeService.SalesforceError('123','tes');
        System.Test.stopTest();       
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody); 
        EmployeeResp resp =  (EmployeeResp)JSON.deserializeStrict(respBody, EmployeeResp.class);
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assertEquals(0, successAndErrorLogs.get('Success').size(), 'Success Log count is not zero: ' + logs.size() + ' : ' + logsConcat); 
        System.assert(successAndErrorLogs.get('Error').size() >0, 'Error Log count is not equal to 1 or more: ' + logs.size() + ' : ' + logsConcat);    
    }
    @IsTest
    static void AuctionAccessPositive(){
        acct.BI_ID__c = '440523';
        acct.recordTypeId = brokerAccountRecTypeId;
        insert acct;
        String payload = '{"Updates":[{"Buyer":null,"Employees":{"BuyerId":"440523","BuyerEmployeeId":"740250","StatusCode":"ACT","JobTitleCode":"BRKR","FirstName":"Chaitali","LastName":"Shah","Address1":"25 Oak Leigh Ct","City":"Henrico","State":"VA","Country":"US","Zip":"23238","Phone":"8322081440","EMailAddress1":"chaitali.shah@iaai.com","ContactTypeBuyerOrUser":"B","MiddleInitial":" ","UserId":"17674283","MobilePhoneNumber":"","Gender":" ","PrimaryContactMethodCode":"BE","BirthDate":"1970-01-01","LanguageCode":"ENG","AuctionAccessMemberID":"12321","IAAIdentification":{"IDNumber":"J160-555-3467","IDStateIssued":"US-VA","CountryIssued":"US","IDExpirationDate":"2025-04-19","IdentificationType":"1"},"AuctionAccessIdentification":{"IDNumber":"J160-555-3467","IDStateIssued":"US-VA","CountryIssued":"US","IDExpirationDate":"2025-04-19","IdentificationType":"1"}}}],"TransactionID":"d8f9e3e3-0b0c-452e-8438-8b2ab8cdc671","CreatedTime":"2021-03-30T14:24:44.8492455-05:00","SentFrom":"IAAI","SentTo":"SCRM","TransactionType":"IAAI_EMPLOYEE_UPDATE","Version":"V1.0"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/updateEmployee';
        req.requestBody = Blob.valueof(payload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();   
        EmployeeService objBS = new EmployeeService();
        EmployeeService.updateEmployee();   
        EmployeeService.SalesforceError objne = new  EmployeeService.SalesforceError('123','tes');
        System.Test.stopTest();          
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody); 
        EmployeeResp resp =  (EmployeeResp)JSON.deserializeStrict(respBody, EmployeeResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Contact is blank' + sfId  + ' : ' + resp?.response);
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is not greate than zero: ' + logs.size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is not zero for auctionAccessPositive: ' + logs.size() + ' : ' + logsConcat); 
    }

    public class EmployeeResp {
        public Response response;
    }
    public class Response {
		public String status;
		public String message;
		public String sfId;
	}
}