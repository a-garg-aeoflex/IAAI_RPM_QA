/**
* Lev - updated exisiting test class and adding commments
* @date 2021
*
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
*
* @description Apex coverage for BrokerService
*/
@isTest
private class BrokerService_Test {
    static Branch__c branch;
    static {
        branch = TestDataFactory.createBranches(true,1,3359)[0];
    }
    @isTest
    private static void BrokerParentNotFoundNegative(){
     
        String myJSON = '{'+
        '  \"Updates\": ['+
        '    {'+
        '      \"Buyer\": {'+
        '        \"Buyer_ID\": \"446917\",'+
        '        \"Buyer_Name\": \"AMAYA USED  CARS TR\",'+
        '        \"Address_Line_1\": \"IND AREA 2 BEHIND THE FIRST INDUSTRIAL\",'+
        '        \"City_Name\": \"SHARJAH\",'+
        '        \"Zip_Code\": \"81566\",'+
        '        \"State_Abbreviation\": \"XX \",'+
        '        \"County_Name\": \"test\",'+
        '        \"Country_Abbreviation\":\"India\",'+
        '        \"Phone_Number_1\": \"0555856071\",'+
        '        \"Federal_Tax_ID\": \"\",'+
        '        \"Buyer_Type_Code\": \"B   \",'+
        '        \"Mail_Address_Line_1\": \"IND AREA 2 BEHIND THE FIRST INDUSTRIAL .\",'+
        '        \"Mail_City_Name\": \"Sharjah\",'+
        '        \"Mail_Zip_Code\": \"81566\",'+
        '        \"Mail_State_Abbreviation\": \"XX \",'+
        '        \"Mail_Country_Abbreviation\": \"AE\",'+
        '        \"Home_Branch_Number\": \"999\",'+
        '        \"Status_Code\": \"ACT\",'+
        '        \"Primary_Contact_ID\": \"694472\",'+
        '        \"IsBrokerParent\": \"False\",'+
        '        \"BrokerId\": \"380808\",'+
        '        \"AuthUserKey\": \"test\"'+
        '      },'+
        '      \"Employees\": null'+
        '    }'+
        '  ],'+
        '  \"TransactionID\": \"4c574fc6-c091-4405-aeb0-bb923b9b6bd9\",'+
        '  \"CreatedTime\": \"2020-07-15T00:02:13.9594327-05:00\",'+
        '  \"SentFrom\": \"IAAI\",'+
        '  \"SentTo\": \"SCRM\",'+
        '  \"TransactionType\": \"IAAI_BUYER_UPDATE\",'+
        '  \"Version\": \"V1.0\"'+
        '}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();   
        brokerservice.SalesforceError objne = new  brokerservice.SalesforceError('123','tes');      
        System.Test.stopTest(); 
        
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);  
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assertEquals(0, successAndErrorLogs.get('Success').size(), 'Success Log count is not zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assert(successAndErrorLogs.get('Error').size() > 0, 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat);  
     }      
    @isTest
    private static void BranchNotFoundNegative(){
        
        Account obje = new Account();
        obje.BI_ID__c = '3359';
        obje.Name='test';        
        insert obje;
     
        String myJSON =  '{'+
            '  \"Updates\": ['+
            '    {'+
            '      \"Buyer\": {'+
            '        \"Buyer_ID\": \"\",'+
            '        \"Buyer_Name\": \"Linder\'s, Inc._aa\",'+
            '        \"Address_Line_1\": \"211 Granite St\",'+
            '        \"City_Name\": \"Worcester\",'+
            '        \"Zip_Code\": \"01607\",'+
            '        \"State_Abbreviation\": \"IL \",'+
            '        \"County_Name\": \"Worcester\",'+
            '        \"Phone_Number_1\": \"9287635473\",'+
            '        \"Federal_Tax_ID\": \"667596566\",'+
            '        \"Buyer_Type_Code\": \"B \",'+
            '        \"Mail_Address_Line_1\": \"1345 test\",'+
            '        \"Mail_City_Name\": \"Aurora\",'+
            '        \"Mail_Zip_Code\": \"60506\",'+
            '        \"Mail_State_Abbreviation\": \"IL \",'+
            '        \"Mail_Country_Abbreviation\": \"US\",'+
            '        \"Home_Branch_Number\": \"713\",'+
            '        \"Status_Code\": \"ACT\",'+
            '        \"Primary_Contact_ID\": \"7157\",'+
            '        \"IsBrokerParent\": \"False\",'+
            '        \"BrokerId\": \"\",'+
            '        \"AuthUserKey\": \"test\"'+
            '      },'+
            '      \"Employees\": null'+
            '    }'+
            '  ],'+
            '   \"TRAN_ID\": \"1a930cc0-56f6-4554-80c2-a75f373d0c8c\",'+
            '   \"CREATE_DATETIME\": \"6/12/2020 10:32:49 AM\",'+
            '   \"SENT_FROM\": \"IAAI\",'+
            '   \"SENT_TO\": \"SCRM\",'+
            '   \"TRANSACTION_TYPE\": \"IAAI_BUYER_UPDATE\",'+
            '   \"VERSION\": \"V1.0\"'+
            '   }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest();  
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody); 
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assertEquals(0, successAndErrorLogs.get('Success').size(), 'Success Log count is not zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assert(successAndErrorLogs.get('Error').size() > 0, 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
         
    }
    @isTest
    private static void BrokerParentNewPositive(){
       
        Account obje = new Account();
        obje.BI_ID__c = '3359';
        obje.Name='test';        
        insert obje;
     
        String myJSON =  '{'+
            '  \"Updates\": ['+
            '    {'+
            '      \"Buyer\": {'+
            '        \"Buyer_ID\": \"3359\",'+
            '        \"Buyer_Name\": \"Linder\'s, Inc._aa\",'+
            '        \"Address_Line_1\": \"211 Granite St\",'+
            '        \"City_Name\": \"Worcester\",'+
            '        \"Zip_Code\": \"01607\",'+
            '        \"State_Abbreviation\": \"IL \",'+
            '        \"County_Name\": \"Worcester\",'+
            '        \"Phone_Number_1\": \"9287635473\",'+
            '        \"Federal_Tax_ID\": \"667596566\",'+
            '        \"Buyer_Type_Code\": \"B \",'+
            '        \"Mail_Address_Line_1\": \"1345 test\",'+
            '        \"Mail_City_Name\": \"Aurora\",'+
            '        \"Mail_Zip_Code\": \"60506\",'+
            '        \"Mail_State_Abbreviation\": \"IL \",'+
            '        \"Mail_Country_Abbreviation\": \"US\",'+
            '        \"Home_Branch_Number\": \"3359\",'+
            '        \"Status_Code\": \"ACT\",'+
            '        \"Primary_Contact_ID\": \"7157\",'+
            '        \"IsBrokerParent\": \"true\",'+
            '        \"BrokerId\": \"\",'+
            '        \"AuthUserKey\": \"test\"'+
            '      },'+
            '      \"Employees\": null'+
            '    }'+
            '  ],'+
            '   \"TRAN_ID\": \"1a930cc0-56f6-4554-80c2-a75f373d0c8c\",'+
            '   \"CREATE_DATETIME\": \"6/12/2020 10:32:49 AM\",'+
            '   \"SENT_FROM\": \"IAAI\",'+
            '   \"SENT_TO\": \"SCRM\",'+
            '   \"TRANSACTION_TYPE\": \"IAAI_BUYER_UPDATE\",'+
            '   \"VERSION\": \"V1.0\"'+
            '   }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest();     
         
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Account is blank' + sfId  + ' : ' + resp?.response);    
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
    }
    @isTest
    private static void BrokerParentExistingPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{''}           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Account acct =TestDataFactory.createAccounts(false,1, 'test')[0];
        acct.BI_ID__c = '3359';
        insert acct;
     
        String payload = '{"Updates":[{"Buyer":{"Buyer_ID":"3359","Buyer_Name":"Wreckerman","Address_Line_1":"8472 w misty lake cir","City_Name":"Sharjah","Zip_Code":"99629","State_Abbreviation":"SHJ ","County_Name":"United Arab Emirates","Country_Abbreviation":"UAE","Phone_Number_1":"9074143327","Federal_Tax_ID":"085595050","Buyer_Type_Code":"B   ","Mail_Address_Line_1":"8472 w misty lake cir","Mail_City_Name":"Sharjah","Mail_Zip_Code":"99629","Mail_State_Abbreviation":"SJH ","Mail_Country_Abbreviation":"UAE","Home_Branch_Number":"3359","Status_Code":"ACT","Primary_Contact_ID":"533312","IsBrokerParent":"true","BrokerId":"","AuthUserKey":"9d2aa47b-f439-41ab-9a2c-777fa55cbbf8","Purpose":"PUBLIC: I buy for personal use or private resale","AuctionAccess":{"CompanyId":"123","BuyerType":"0","CompanyName":"123","CompanyAddress1":"44 S. Arizona Ave.","CompanyCity":"Chandler","CompanyState":"AZ","CompanyZip":"85225","CompanyCountry":"123","PrimaryPhone":"1231231232"}},"Employees":null}],"TransactionID":"6e207346-b33d-4b37-a92f-a3ba459a7249","CreatedTime":"2021-01-05T08:17:13.5127249-06:00","SentFrom":"IAAI","SentTo":"SCRM","TransactionType":"IAAI_BUYER_UPDATE","Version":"V1.0"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(payload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest();     
         
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Account is blank' + sfId  + ' : ' + resp?.response);    
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is not greater than 0: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
    }
    @isTest
    private static void BadPayloadNegative(){

        Account obje = new Account();
        obje.BI_ID__c = '3359';
        obje.Name='test';        
        insert obje;
     
        String myJSON =  '{'+
            '  \"Updates\": '+
            '    {'+
            '      \"Buyer\": {'+
            '        \"Buyer_ID\": \"3359\",'+
            '        \"Buyer_Name\": \"Linder\'s, Inc._aa\",'+
            '        \"Address_Line_1\": \"211 Granite St\",'+
            '        \"City_Name\": \"Worcester\",'+
            '        \"Zip_Code\": \"01607\",'+
            '        \"State_Abbreviation\": \"IL \",'+
            '        \"County_Name\": \"Worcester\",'+
            '        \"Phone_Number_1\": \"9287635473\",'+
            '        \"Federal_Tax_ID\": \"667596566\",'+
            '        \"Buyer_Type_Code\": \"B \",'+
            '        \"Mail_Address_Line_1\": \"1345 test\",'+
            '        \"Mail_City_Name\": \"Aurora\",'+
            '        \"Mail_Zip_Code\": \"60506\",'+
            '        \"Mail_State_Abbreviation\": \"IL \",'+
            '        \"Mail_Country_Abbreviation\": \"US\",'+
            '        \"Home_Branch_Number\": \"713\",'+
            '        \"Status_Code\": \"ACT\",'+
            '        \"Primary_Contact_ID\": \"7157\",'+
            '        \"IsBrokerParent\": \"true\",'+
            '        \"BrokerId\": \"\",'+
            '        \"AuthUserKey\": \"test\"'+
            '      },'+
            '      \"Employees\": null'+
            '    }'+
            '  ],'+
            '   \"TRAN_ID\": \"1a930cc0-56f6-4554-80c2-a75f373d0c8c\",'+
            '   \"CREATE_DATETIME\": \"6/12/2020 10:32:49 AM\",'+
            '   \"SENT_FROM\": \"IAAI\",'+
            '   \"SENT_TO\": \"SCRM\",'+
            '   \"TRANSACTION_TYPE\": \"IAAI_BUYER_UPDATE\",'+
            '   \"VERSION\": \"V1.0\"'+
            '   }';//JSON.serialize(objBroSer);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com//services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest(); 
    }
    @isTest
    private static void NotBrokerParentNewPositive(){
       
        Account obje = new Account();
        obje.BI_ID__c = '33591';
        obje.Name='test';
        obje.recordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        system.debug('obje '+obje);
        insert obje;
     
        String myJSON =  '{'+
           '    \"Updates\": ['+
            '    {'+
            '      \"Buyer\": {'+
            '        \"Buyer_ID\": \"3359\",'+
            '        \"Buyer_Name\": \"Linder\'s, Inc._aa\",'+
            '        \"Address_Line_1\": \"211 Granite St\",'+
            '        \"City_Name\": \"Worcester\",'+
            '        \"Zip_Code\": \"01607\",'+
            '        \"State_Abbreviation\": \"IL \",'+
            '        \"County_Name\": \"Worcester\",'+
            '        \"Phone_Number_1\": \"9287635473\",'+
            '        \"Federal_Tax_ID\": \"667596566\",'+
            '        \"Buyer_Type_Code\": \"B \",'+
            '        \"Mail_Address_Line_1\": \"1345 test\",'+
            '        \"Mail_City_Name\": \"Aurora\",'+
            '        \"Mail_Zip_Code\": \"60506\",'+
            '        \"Mail_State_Abbreviation\": \"IL \",'+
            '        \"Mail_Country_Abbreviation\": \"US\",'+
            '        \"Home_Branch_Number\": \"3359\",'+
            '        \"Status_Code\": \"ACT\",'+
            '        \"Primary_Contact_ID\": \"7157\",'+
            '        \"IsBrokerParent\": \"false\",'+
            '        \"BrokerId\": \"33591\",'+
            '        \"AuthUserKey\": \"test\"'+
            '      },'+
            '      \"Employees\": null'+
            '    }'+
            '  ],'+
            '   \"TRAN_ID\": \"1a930cc0-56f6-4554-80c2-a75f373d0c8c\",'+
            '   \"CREATE_DATETIME\": \"6/12/2020 10:32:49 AM\",'+
            '   \"SENT_FROM\": \"IAAI\",'+
            '   \"SENT_TO\": \"SCRM\",'+
            '   \"TRANSACTION_TYPE\": \"IAAI_BUYER_UPDATE\",'+
            '   \"VERSION\": \"V1.0\"'+
            '   }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(myJSON);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest(); 
        
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Account is blank' + sfId  + ' : ' + resp?.response);    
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
    }
    @isTest
    private static void NotBrokerParentExistingPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{''}           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Account acct =TestDataFactory.createAccounts(false,1, 'test')[0];
        //acct.AuthUserKey__c = '9d2aa47b-f439-41ab-9a2c-777fa55cbbf8';    
        acct.API_Buyer_Id__c = '3359';
        insert acct;
     
        String payload = '{"Updates":[{"Buyer":{"Buyer_ID":"3359","Buyer_Name":"Wreckerman","Address_Line_1":"8472 w misty lake cir","City_Name":"Sharjah","Zip_Code":"99629","State_Abbreviation":"SHJ ","County_Name":"United Arab Emirates","Country_Abbreviation":"UAE","Phone_Number_1":"9074143327","Federal_Tax_ID":"085595050","Buyer_Type_Code":"B   ","Mail_Address_Line_1":"8472 w misty lake cir","Mail_City_Name":"Sharjah","Mail_Zip_Code":"99629","Mail_State_Abbreviation":"SJH ","Mail_Country_Abbreviation":"UAE","Home_Branch_Number":"3359","Status_Code":"ACT","Primary_Contact_ID":"533312","IsBrokerParent":"false","BrokerId":"","AuthUserKey":"9d2aa47b-f439-41ab-9a2c-777fa55cbbf8","Purpose":"PUBLIC: I buy for personal use or private resale","AuctionAccess":{"CompanyId":"123","BuyerType":"0","CompanyName":"123","CompanyAddress1":"44 S. Arizona Ave.","CompanyCity":"Chandler","CompanyState":"AZ","CompanyZip":"85225","CompanyCountry":"123","PrimaryPhone":"1231231232"}},"Employees":null}],"TransactionID":"6e207346-b33d-4b37-a92f-a3ba459a7249","CreatedTime":"2021-01-05T08:17:13.5127249-06:00","SentFrom":"IAAI","SentTo":"SCRM","TransactionType":"IAAI_BUYER_UPDATE","Version":"V1.0"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = 'https://iaaicsr--uat.my.salesforce.com/services/apexrest/updateBroker';
        req.requestBody = Blob.valueof(payload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();       
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker();       
        System.Test.stopTest();     
         
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Account is blank' + sfId  + ' : ' + resp?.response);    
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is not greater than 0: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
    }
    @IsTest
    static void AuctionAccessPositive(){

        Account obje = new Account();
        obje.BI_ID__c = '33591';
        obje.Name='test';
        obje.recordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        system.debug('obje '+obje);
        insert obje;
        branch.Branch_Number__c = '999';
        update branch;
        String payload = '{"Updates":[{"Buyer":{"Buyer_ID":"434354","Buyer_Name":"Wreckerman","Address_Line_1":"8472 w misty lake cir","City_Name":"Sharjah","Zip_Code":"99629","State_Abbreviation":"SHJ ","County_Name":"United Arab Emirates","Country_Abbreviation":"UAE","Phone_Number_1":"9074143327","Federal_Tax_ID":"085595050","Buyer_Type_Code":"B   ","Mail_Address_Line_1":"8472 w misty lake cir","Mail_City_Name":"Sharjah","Mail_Zip_Code":"99629","Mail_State_Abbreviation":"SJH ","Mail_Country_Abbreviation":"UAE","Home_Branch_Number":"999","Status_Code":"ACT","Primary_Contact_ID":"533312","IsBrokerParent":"true","BrokerId":"","AuthUserKey":"9d2aa47b-f439-41ab-9a2c-777fa55cbbf8","Purpose":"PUBLIC: I buy for personal use or private resale","AuctionAccess":{"CompanyId":"123","BuyerType":"0","CompanyName":"123","CompanyAddress1":"44 S. Arizona Ave.","CompanyCity":"Chandler","CompanyState":"AZ","CompanyZip":"85225","CompanyCountry":"123","PrimaryPhone":"1231231232"}},"Employees":null}],"TransactionID":"6e207346-b33d-4b37-a92f-a3ba459a7249","CreatedTime":"2021-01-05T08:17:13.5127249-06:00","SentFrom":"IAAI","SentTo":"SCRM","TransactionType":"IAAI_BUYER_UPDATE","Version":"V1.0"}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/updated/account/updateBroker';
        req.requestBody = Blob.valueof(payload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;        
        System.Test.startTest();
        brokerservice objBS = new brokerservice();
        brokerservice.updateBroker(); 
        System.Test.stopTest();
        String respBody = res?.responseBody?.toString();   
        System.debug('*Response Message: ' + respBody);        
        BrokerResp resp =  (BrokerResp)JSON.deserializeStrict(respBody, BrokerResp.class);
        System.debug('*resp sfId: ' + resp?.response?.sfId);
        String sfId = resp?.response?.sfId;
        System.assert(String.isNotBlank(sfId), 'Salesforce ID for Account is blank' + sfId  + ' : ' + resp?.response);
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c,Status__c FROM Integration_logs__c LIMIT 5];
        Map<String,List<Integration_logs__c>> successAndErrorLogs = new Map<String,List<Integration_logs__c>>{'Success' =>new List<Integration_logs__c>(),'Error' =>new List<Integration_logs__c>()};
        String logsConcat =TestDatafactory.AddSuccessAndErrorLogs(successAndErrorLogs,logs);
        System.assert(successAndErrorLogs.get('Success').size() > 0, 'Success Log count is  greater than zero: ' + logs.size() + ' : ' + logsConcat);
        System.assertEquals(0, successAndErrorLogs.get('Error').size(), 'Error Log count is greater than zero: ' + successAndErrorLogs.get('Error').size() + ' : ' + logsConcat); 
    }
    public class BrokerResp {
        public Response response;
    }
    public class Response {
		public String status;
		public String message;
		public String sfId;
	}
    
}