/**
* @author Lev
* @date 2020
*
* @group Account
* @group-content ../../ApexDocContent/Event.htm
*
* @description EventWebServiceTest - apex coverage for EventWebService
*/
@IsTest
private without sharing class EventWebServiceTest {
    static User u;
    static User integrationUser;
    static String authUserKey = '1233524352';
    static String ocrStatus ='3';
    static Boolean variesFromAddr = false;
    static String companyName = '';
    static String buyerPromoCode = '';

    static{
       u= TestDataFactory.createUser(false, 'iiatester134345', 'System Administrator');
       integrationUser= TestDataFactory.createUser(false, 'iiatester1343456', 'Integration User');
    }
    static string setPayload(String eventName,String authUserKey,String buyerId,String callToAction){ 
        return setPayload(eventName,authUserKey,buyerId,callToAction,'','',ocrStatus,variesFromAddr,companyName,buyerPromoCode); 
    }
    static string setPayload(String eventName,String authUserKey,String buyerId,String callToAction,String lexusNexisBusinessResults,String lexusNexisIndividualResults){ 
        return setPayload(eventName,authUserKey,buyerId,callToAction, lexusNexisBusinessResults,lexusNexisIndividualResults,ocrStatus,variesFromAddr,companyName,buyerPromoCode); 
    }
    static string setPayload(String eventName,String authUserKey,String buyerId,String callToAction,String lexusNexisBusinessResults,String lexusNexisIndividualResults,String ocrStatus,Boolean variesFromAddr,String companyName,String buyerPromoCode  ){ 
        

        string licenseFileId1 = String.Valueof(System.Math.Random());
        string licenseFileId2 = String.Valueof(System.Math.Random());
        string lexusNexisBusResults = lexusNexisBusinessResults == 'default' ? '{"UserType":2,"ResponseCode":0,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}'
                                    : lexusNexisBusinessResults;
        System.debug('*lexusNexisBusResults: ' + lexusNexisBusResults);                           
        string lexusNexisIndResults = lexusNexisIndividualResults == 'default' ? '{"UserType":1,"ResponseCode":0,"ResponseDescription":{"AlertID":"IndividualAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"IndividualAlert","ReasonListed":"IndividualReason"}],"ErrorMessage":"IndividualErrorMessage"}}'
                                    : lexusNexisIndividualResults;
        System.debug('*lexusNexisIndResults: ' + lexusNexisIndResults);                               
        string lexusNexisResults = String.isBlank(lexusNexisBusResults) && String.isBlank(lexusNexisIndResults) ? '[]' : 
                                 String.isNotBlank(lexusNexisBusResults) && String.isBlank(lexusNexisIndResults) ? '[' + lexusNexisBusResults + ']' :
                                 String.isBlank(lexusNexisBusResults) && String.isNotBlank(lexusNexisIndResults) ? '[' + lexusNexisIndResults + ']' : 
                                 '[' + lexusNexisBusResults + ',' + lexusNexisIndResults + ']';
        System.debug('*lexusNexisResults: ' + lexusNexisResults);                           
        return '{"EventName":"'+ eventName+ '","AuthUserKey":"' + authUserKey + '","Timestamp__c":"2020-12-08T12:00:00","RegistrationModel":{"AuthUserKey":"' + authUserKey + '","Identifier":{"BuyerId":"' + buyerId + '","UserId":"string","EmployeeId":"EmpId1233","BuyerStatus":2},"Guest":{"Email":"test@test23423467.com","FirstName":"Bill","LastName":"Smith","TermsOfUse":{"Status":true,"IPAddress":"string","When":"string"}},"GuestInfo":{"Purpose":"","PreferredLanguage":1,"UserType":"NA","When":"2020-12-08T12:00:00","Country":"string","CountryCode":"string","State":"string","Mobile":"string","MobileCountryCode":"string","CallToAction":"' + callToAction + '"},"OCRPayload":{"DocumnetType":1,"IdentificationNumber":"string","StateIssued":"string","CountryIssued":"string","BirthDate":"1929-08-12T00:00:00Z","ExpirationDate":"2029-08-12T00:00:00Z","LicenseType":0,"Contact":{"Street":"string","Street2":"string","City":"string","State":"string","Zip":"string","Country":"string","Fax":"string","PhoneNumber1":"string","PhoneNumber2":"string","PhoneExtension1":"string","PhoneExtension2":"string"},"IsForeignBuyer":true},"IDPayload":{ "IsAddressVariesFromID":'+ variesFromAddr +',"DocumnetType":1,"IdentificationNumber":"45454","StateIssued":"Washington","CountryIssued":"Canada","BirthDate":"1929-08-12T00:00:00Z","ExpirationDate":"2029-08-12T00:00:00Z","LicenseType":"ContactLicenseType","Contact":{"Street":"67 w contact street","Street2":"#45","City":"ContanctCity","State":"AZ","Zip":"85001","Country":"US","Fax":"string","PhoneNumber1":"1231231234","PhoneNumber2":"1231231234","PhoneExtension1":"ext222","PhoneExtension2":"ext333","Phone2CountryCode":"44","Phone1CountryCode":"22"},"IsForeignBuyer":true},"IsPublic":true,"BusinessPayload":{"CompanyName":"' + companyName + '","FEIN":"123456789","Licenses":[{"Country":"US","State":"AZ","EffectiveDate":"2020-12-08","ExpirationDate":"2020-12-08","LicenseNumber":"1232137","LicenseType":"Dealer","FileIdentifier":"' + licenseFileId1 + '"},{"Country":"US","State":"CA","EffectiveDate":"2021-08-09","ExpirationDate":"2021-09-09","LicenseNumber":"1232131237","LicenseType":"Dealer","FileIdentifier":"' + licenseFileId2 + '"}],"ContactPayload":{"Street":"12 s. Account street","Street2":"#12","City":"TestAccountCity","State":"AZ","Zip":"85001","Country":"United States","Fax":"string","PhoneNumber1":"555223333","PhoneNumber2":"4451237654","PhoneExtension1":"1","PhoneExtension2":"445","Phone2CountryCode":"11","Phone1CountryCode":"44"}},"OCRStatus":"'+ ocrStatus + '","UserAcceptance":{"AcceptAuctionRules":true,"AcceptPrivacyPolicy":true,"AcceptAuctionRulesDateTime":"string","AcceptPrivacyPolicyDateTime":"string","IPAddress":"string"},"Files":[{"Name":"File2","Key":"1232132","Created":"2020-12-08T12:00:00","DocumentType":1,"IdentificationProof":1,"IdentificationType":1,"LicenseType":1,"DocusignType":2},{"Name":"File2","Key":"123213 ","Created":"2020-12-08T12:00:00","DocumentType":1,"IdentificationProof":1,"IdentificationType":1,"LicenseType":2,"DocusignType":1}],"PromoCode":{"' + buyerPromoCode +'":"TENPERCENT","promocode":"10% off","fee":"string","status":"string","message":"string","promocodeDetail":{"effective_Date":"string","expiration_Date":"string","discountAmount":"string","totalAmount":"string"}},"LexusNexisResults":' + lexusNexisResults + ',"Payment":{"PaymentMethod":1,"Amount":"100.00","AutoRenewalFalg":"string","IsPromoCodeApplied":"true","IsBuyerFromEU":"string","RegistrationTransactionId":"23442334","PageSource":"ProfileDesktop","DeviceSource":"Desktop","IPAddress":"string","CCPayment":{"CCId":"string","BillingAddress":{"Street":"string","Street2":"string","City":"string","State":"string","Zip":"string","Country":"string","Fax":"string","PhoneNumber1":"string","PhoneNumber2":"string","PhoneExtension1":"string","PhoneExtension2":"string"},"CardType":"string","CardNumber":"string","CardExpirationDate":"string"},"PPPayment":{"PPId":"string","CustomerAccountID":"string","PPPaymentCode":"string","PPPaymentMethod":"string","Transactionid":"string","TransactionDate":"string","PPStatus":0,"Message":"string","RegistrationType":"Guest","Notes":"string","TransactionType":"AUTH"},"When":"2021-05-13T12:00:00"},"CurrentStep": 4,"Created":"string"}}';
    }
    static EventWebService.EventResponse runPreviousPayload(String payload){
        EventWebService.EventResponse resp = new  EventWebService.EventResponse();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueof( payload);
        RestContext.request = req;
        RestContext.response = res;
        resp = EventWebService.acceptEvent();
        return resp;
    }

    @IsTest
    static void LeadCreatePositive(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        System.debug('*jsonPayload ' + jsonPayload);
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        System.Test.StartTest();
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody;      
        System.debug('*Response Message: ' + resp.message); 
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
        System.assertEquals(1,[SELECT Count() FROM Lead]);
    }   
    @IsTest
    static void LeadUpdatePositive(){
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','default','default' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        System.debug('*jsonPayload ' + jsonPayload);
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        System.Test.StartTest();
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody;      
        System.debug('*Response Message: ' + resp.message); 
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
        System.assertEquals(1,[SELECT Count() FROM Lead]);
    }
    @IsTest
    static void LeadEventNoRegModelNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = '{"EventName":"accountprofilecreate","AuthUserKey":"12345","Timestamp__c":"2020-12-08T12:00:00"}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        System.Test.StartTest();
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Error',resp.status,'Status should be Error');
        System.assertEquals(0,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey], 'Lead size is not 1');
    }
    @IsTest
    static void LeadBadJSONNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = 'test235235#@$4w.ew';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        System.Test.StartTest();
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);    
        System.assertEquals(400,res.statusCode,'Response is not 400');  
        System.assertEquals('Error',resp.status,'Status should be Error');
        System.assertEquals(0,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey], 'Lead size is not 0');
    }
    @IsTest
    static void AccountCreatePositive(){
       
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','default','default' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);

        System.Test.StartTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('accountprofilecomplete', authUserKey,'','2','default','default' );
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.debug('*Response Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        String logsConcat = '';
        List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c FROM Integration_logs__c LIMIT 5];
        for(Integration_logs__c log:logs){
            string errMsg = 'Log: TransactionId:' + log.Transection_Id__c + ' Resp: ' + log.Response_Body__c + ' Type: ' + log.Transaction_Type__c + 
            ' SentTo: ' + log.Sent_To__c + ' Request: ' + log.Request_Body__c;
            logsConcat = String.isBlank(logsConcat) ? errMsg : logsConcat + errMsg;
        }
        System.debug('logsConcat: ' + logsConcat);	       
        System.assertEquals(200,res.statusCode,'Response is not 200' + logs + ' Resp: ' + resp.message);  
        System.assertEquals('Success',resp.status,'Status should be Success' + logs + ' Resp: ' + resp.message);
        List<Account> accts =  [SELECT Id,Name,Business_Response_Code__c,Business_Response_Error__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        List<Contact> cons =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1, accts.size(), 'Account size is not 1' + logs + ' Resp: ' + resp.message);
        System.assertEquals(1,cons.size(), 'Contact size is not 1' + logs + ' Resp: ' + resp.message);
        Account acct = accts[0];
        Contact con = cons[0];       
        System.assert(String.isNotBlank(acct.Business_Response_Code__c),'Business Response Code is Blank: ' + logs + ' Resp: ' + resp.message );
        System.assert(String.isNotBlank(con.Individual_Response_Code__c),'Individual Response Code is Blank:  ' + logs + ' Resp: ' + resp.message );
        
    }
    @IsTest
    static void AccountCreateMinPayLoadPositive(){
       
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','default','default' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);

        System.Test.StartTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = '{"EventName":"accountprofilecomplete","AuthUserKey":"' + authUserKey + '","when":"2020-12-08T12:00:00","RegistrationModel":{"AuthUserKey":"' + authUserKey + '","Identifier":{"BuyerId":null,"UserId":"4691516","EmployeeId":null,"BuyerStatus":0},"Guest":{"Email":"testname@test.com","FirstName":"testname","LastName":"Testlastname","TermsOfUse":{"Status":true,"IPAddress":"147.243.23.147","When":"2021-03-11T11:55:06.5877321+00:00"}},"GuestInfo":{"Purpose":"","PreferredLanguage":1,"UserType":0,"When":"2021-03-11T11:55:06.5877321+00:00","Country":null,"CountryCode":null,"State":null,"Mobile":null,"MobileCountryCode":null,"CallToAction":2},"OCRPayload":null,"IDPayload":null,"OCRStatus":0,"BusinessPayload":null,"UserAcceptance":null,"Files":null,"PromoCode":null,"LexusNexisResults":null,"Payment":null,"CurrentStep":2,"Created":"2021-03-11T11:55:06.5877321+00:00"}}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.debug('*Response Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody;        
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
        List<Account> accts =  [SELECT Id,Name,Business_Response_Code__c,Business_Response_Error__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        List<Contact> cons =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1, accts.size(), 'Account size is not 1');
        System.assertEquals(1,cons.size(), 'Contact size is not 1');
        Account acct = accts[0];
        Contact con = cons[0];      
               
    }
    @IsTest
    static void AccountCreateNegative(){

        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);

        System.Test.StartTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('accountprofilecomplete', authUserKey,'','0' );
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();        
        System.Test.StopTest();
        Blob respBlob = res.responseBody;        
        System.debug('*Response Message: ' + resp.message);
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Error',resp.status,'Status should be Success');
        System.assertEquals(0,[SELECT Count() FROM Account WHERE AuthUserKey__c=:authUserKey], 'Account size is not 0');
        System.assertEquals(0,[SELECT Count() FROM Contact WHERE AuthUserKey__c=:authUserKey], 'Contact size is not 0');
    }
   
    @IsTest
    static void AccountBuyerIdNegative(){
       
        System.Test.StartTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('profilecomplete', '','345435','2' );
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody;   
        System.debug('*Response Message: ' + resp.message);     
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Error',resp.status,'Status should be Success');        
    }
    @IsTest
    static void BackGroundCheckFailPositive(){
        String bgCheck = '{"UserType":1,"ResponseCode":3,"ResponseDescription":{"AlertID":"IndividualAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"IndividualAlert","ReasonListed":"IndividualReason"}],"ErrorMessage":"IndividualErrorMessage"}}';
        String bizCheck = '{"UserType":2,"ResponseCode":0,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','',bizCheck );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2','',bizCheck );
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        System.assertEquals(1,[SELECT Count() FROM Contact WHERE AuthUserKey__c=:authUserKey], 'Contact size is not 1');
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('idbusinessbackgroundcheck', authUserKey,'','2',bizCheck,bgCheck,'2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        EventWebService.EventResponse resp = EventWebService.acceptEvent();       
        Blob respBlob = res.responseBody;    
        System.debug('*Response Message: ' + resp.message);    
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');      
        Account acct =  [SELECT Id,Name,Business_Response_Code__c,Business_Response_Error__c,Business_Response_Desc__c FROM Account WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];  
        Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c,Individual_Response_Description__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0]; 
        System.debug('*acct.Acount_Business_Response_Desc: ' + acct.Business_Response_Desc__c);
        System.debug('*con.Acount_Business_Response_Desc: ' + con.Individual_Response_Description__c);
        System.assert(String.isNotBlank(acct.Business_Response_Code__c));
        System.assert(String.isNotBlank(con.Individual_Response_Error__c));
        System.assert(String.isNotBlank(acct.Business_Response_Desc__c));
        System.assert(String.isNotBlank(con.Individual_Response_Description__c));

        List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('New Reg BG Check');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
           if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
           }
           else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
           }else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
           }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(5,tsks.size());

        //Update one more time and verify that new case doesn't get created but only new task
        bizCheck = '{"UserType":2,"ResponseCode":3,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        jsonPayload = setPayload('idbusinessbackgroundcheck', authUserKey,'','2',bizCheck,bgCheck,'2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        EventWebService.EventResponse updatedResp = EventWebService.acceptEvent();
        respBlob = res.responseBody;    
        System.debug('*Response Message Updated: ' + updatedResp.message);    
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');   
        System.Test.StopTest();
        List<Case> updateCases = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,updateCases.size(),'Cases size is not 1: ' + updateCases.size());
        List<Task> updateTsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(6, updateTsks.size(),'Updated tasks BackGroundCheckFailPositive is not 6: actual:' +updateTsks.size());

    }
    @IsTest
    static void BusinessCheckFailPositive(){
        String bgCheck = '{"UserType":1,"ResponseCode":1,"ResponseDescription":{"AlertID":"IndividualAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"IndividualAlert","ReasonListed":"IndividualReason"}],"ErrorMessage":"IndividualErrorMessage"}}';
        String bizCheck = '{"UserType":2,"ResponseCode":3,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','',bizCheck );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2','',bizCheck );
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        System.assertEquals(1,[SELECT Count() FROM Contact WHERE AuthUserKey__c=:authUserKey], 'Contact size is not 1');
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('idbusinessbackgroundcheck', authUserKey,'','2',bizCheck,bgCheck,'2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody;    
        System.debug('*Response Message: ' + resp.message);    
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');      
        Account acct =  [SELECT Id,Name,Business_Response_Code__c,Business_Response_Error__c FROM Account WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];  
        Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0]; 
        System.assert(String.isNotBlank(acct.Business_Response_Code__c));
        System.assert(String.isNotBlank(con.Individual_Response_Error__c));
        List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('New Reg Biz Check');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
           if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
           }
           else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
           }else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
           }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(6,tsks.size());
    }

    @IsTest
    static void BuyerCreateStatusInactivePositive(){
        String bgCheck = '{"UserType":1,"ResponseCode":0,"ResponseDescription":{"AlertID":"IndividualAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"IndividualAlert","ReasonListed":"IndividualReason"}],"ErrorMessage":"IndividualErrorMessage"}}';
        String bizCheck = '{"UserType":2,"ResponseCode":0,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
        System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,cons.size(), 'Contact size is not 1');
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';        
        string jsonPayload = setPayload('buyercreated', authUserKey,'','2',bizCheck,bgCheck,'2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        system.debug('*Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
		Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('New Reg Review');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
           if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
           }
           else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
           }else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
           }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(4,tsks.size());
        
    }

    @IsTest
    static void BuyerCreateAuctionAccessPositive(){
        System.runAs(integrationUser){
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
        System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,cons.size(), 'Contact size is not 1');        
        
        System.Test.StartTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';        
        string jsonPayload = '{"EventName":"buyercreated","AuthUserKey":'+ authUserKey+',"When":"2020-12-08T12:00:00","RegistrationModel":{"AuthUserKey":"'+ authUserKey+'","Identifier":{"BuyerId":null,"UserId":"123123","EmployeeId":null,"BuyerStatus":2},"Guest":{"Email":"test011@test.com","FirstName":"test","LastName":"test","LoggedInTenant":1,"TermsOfUse":{"Status":true,"IPAddress":"","When":"2021-08-24T17:26:21.6594152+00:00"}},"GuestInfo":{"Purpose":"","PreferredLanguage":1,"PreferredTenant":1,"UserType":2,"When":"2021-08-24T17:01:14.2430453+00:00","Country":"US","CountryCode":"US","State":"AL","Mobile":"2623738907","MobileCountryCode":"1","CallToAction":2,"IsAuctionAccessUser":false},"AuctionAccess":{"DealerRecordIdentifier":"test123","AuctionAccessRequest":{"AuctionAccessId":"2342345","Last4PhotoId":"1234","AuctionId":"1000000001","Source":2,"CompanyId":"5533TestCompanyId","Last4GovernmentId":"1234"},"AuctionAccessDealers":[{"CompanyId":123123,"CompanyName":"CompanyNameTest","IsActive":true}],"IsAdditionalBusiness":false,"AuctionAccessResponse":{"Status":true,"ErrorMessage":null}},"OCRPayload":null,"IDPayload":{"IdentificationNumber":"","IdentificationProof":0,"StateIssued":null,"CountryIssued":null,"BirthDate":"1969-05-07T00:00:00Z","ExpirationDate":null,"Contact":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"12 e. fake drive","Street2":null,"City":"NEW LONDON","State":"NH","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":"us","Phone1CountryCode":"1","PhoneNumber1":"1231231234","Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null},"IsAddressVariesFromID":false,"Licenses":null},"OCRStatus":0,"BusinessPayload":{"CompanyName":"AUTO ADVISORS INC","FEIN":"123456789","Licenses":null,"ContactPayload":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"12 e. fake drive","Street2":null,"City":"NEW LONDON","State":"NH","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":"us","Phone1CountryCode":"1","PhoneNumber1":"1231231236","Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null}},"UserAcceptance":{"AcceptAuctionRules":true,"AcceptAuctionRulesDateTime":"2021-08-24T05:26:21.65Z","AcceptPrivacyPolicy":true,"AcceptPrivacyPolicyDateTime":"2021-08-24T05:26:21.65Z","IPAddress":"147.243.154.43","DeviceSource":0},"Files":null,"PromoCode":null,"LexusNexisResults":null,"Payment":{"PaymentMethod":2,"Amount":10,"AutoRenewalFlag":false,"IsPromoCodeApplied":false,"IsBuyerFromEU":false,"RegistrationTransactionId":"123123","PageSource":2,"DeviceSource":0,"IPAddress":"","CCPayment":{"CCId":"5097348","BillingAddress":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"271 BURNT HILL ROAD","Street2":null,"City":"NEW LONDON","State":"NH","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":null,"Phone1CountryCode":null,"PhoneNumber1":null,"Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null},"CardType":"","CardNumber":"","CardExpirationDate":""},"PPPayment":null,"When":"2021-08-24T17:26:21.2212345+00:00","PSPayment":null,"MNPayment":null},"CurrentStep":25,"Created":"2021-08-24T17:26:23.596634+00:00"}}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        system.debug('*Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
		Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('New Reg Review');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
           if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
           }
           else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
           }else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
           }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(2,tsks.size());
    }
    }

    @IsTest
    static void UpgradeCompletePositive(){
        String bizCheck = '{"UserType":2,"ResponseCode":3,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','',bizCheck );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2','',bizCheck );
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        System.assertEquals(1,[SELECT Count() FROM Contact WHERE AuthUserKey__c=:authUserKey], 'Contact size is not 1');
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('Upgrade-upgradecomplete', authUserKey,'','2',bizCheck,'','2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        system.debug('*Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
		Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('Upgrade LBB Review');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
           if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
           }
           else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
           }else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
           }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
        System.AssertEquals(2,tsks.size());
        List<Service_Event__c> serviceEvents = [Select Id,Name FROM Service_Event__c WHERE Account__c =:accts[0].Id];
        System.Assert(serviceEvents.size() > 0,'Service Events Size is 0' + serviceEvents.size() + ': ' +resp.message); 
    }
    @IsTest
    static void UpgradeNoCasesPositive(){
        String bizCheck = '{"UserType":2,"ResponseCode":3,"ResponseDescription":{"AlertID":"BusinessAlertId","Reasons":[{"EntityScore":"Score0.0","Name":"BusinessAlert","ReasonListed":"BusinessReason"}],"ErrorMessage":"BusinessErrorMessage"}}';
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2','',bizCheck );
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2','',bizCheck );
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        System.assertEquals(1,[SELECT Count() FROM Contact WHERE AuthUserKey__c=:authUserKey], 'Contact size is not 1');
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload = setPayload('Upgrade-identificationreview', authUserKey,'','2',bizCheck,'','2',true,'bizCompanyName','10% off');
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        system.debug('*Message: ' + resp.message);
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');
		Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(0,cses.size(),'Cases size is not 0: ' + cses.size() + ': ' +resp.message);       
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhoId=:con.Id];
        System.AssertEquals(0,tsks.size(),'Task size is not 0' + tsks.size() + ': ' +resp.message); 
        List<Service_Event__c> serviceEvents = [Select Id,Name FROM Service_Event__c WHERE Account__c =:accts[0].Id];
        System.Assert(serviceEvents.size() > 0,'Service Events Size is 0' + serviceEvents.size() + ': ' +resp.message); 
    }
    @IsTest
    static void ProfileUpdateBuyerIdPositive(){
        System.runAs(u){
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        System.debug('jsonPrevPayload: ' + jsonPrevPayload);
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
        System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,cons.size(), 'Contact size is not 1');
        System.assertEquals(2,[SELECT COUNT() FROM License__c WHERE Account__c=:accts[0].Id]);
        System.assertEquals(2,[SELECT COUNT() FROM Document__c WHERE Account__c=:accts[0].Id]);
       
        accts[0].API_Buyer_Id__c = '345435';
        update accts[0];
        cons[0].Buyer_ID__c = 'BUY-345435';
        update cons[0];
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload ='{"EventName":"profileupdate - documentuploaded","BuyerId":"345435","When":"2020-12-08T12:00:00"}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');	
        Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('Profile Update');
        for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
            if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
               if(con != null){
                   System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
               }
            }
            else if(caseEvent.Field_API__c == 'RecordTypeId'){
               Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
               System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
            }else if(caseEvent.Field_API__c == 'Subject'){
                    System.AssertEquals(caseEvent.Value__c + ' profileupdate - documentuploaded',cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
            }
            else{
                System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
            }
        }
        List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task LIMIT 100];
        System.AssertEquals(0,tsks.size());
    }
        
    }
    @IsTest
    static void BuyerIdGetNewLiczDocsAndNotesPositive(){
        System.runAs(u){
            EventWebService.isMock = true;
            //run lead create first
            string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
            System.debug('jsonPrevPayload: ' + jsonPrevPayload);
            runPreviousPayload( jsonPrevPayload);       
            System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
            String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
            System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
            //run lead convert
            runPreviousPayload( jsonPrevPayload2);    
            List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
            System.assertEquals(1,accts.size(),'Account size is not 1');
            List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
            System.assertEquals(1,cons.size(), 'Contact size is not 1');
            System.assertEquals(2,[SELECT COUNT() FROM License__c WHERE Account__c=:accts[0].Id]);
            System.assertEquals(2,[SELECT COUNT() FROM Document__c WHERE Account__c=:accts[0].Id]);
        
            List<List<String>> respList = new List<List<String>>{                            
                new List<String>{
                    '[{"buyerDocumentId":1231,"buyerId":12345,"buyerLicenseId":123,"licenseNumber":"111","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2021-03-11T00:00:00","expirationDate":"2021-03-19T00:00:00","stateAbbreaviation":"NE ","countryAbbreviation":"US","imageId":456,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1232,"buyerId":12345,"buyerLicenseId":124,"licenseNumber":"112","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"UT ","countryAbbreviation":"US","imageId":457,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1233,"buyerId":12345,"buyerLicenseId":125,"licenseNumber":"113","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2044-02-02T00:00:00","stateAbbreaviation":"NV ","countryAbbreviation":"US","imageId":458,"docuwareLink":null},{"buyerDocumentId":1234,"buyerId":12345,"buyerLicenseId":126,"licenseNumber":"114","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":459,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1235,"buyerId":12345,"buyerLicenseId":127,"licenseNumber":"115","licenseTypeCode":"CTC   ","licenseType":"Tax License","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":460,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1236,"buyerId":12345,"buyerLicenseId":128,"licenseNumber":"116","licenseTypeCode":"IOB   ","licenseType":"Illinois Out of State Business","effectiveDate":"2016-04-26T14:24:47.507","expirationDate":"2016-09-30T00:00:00","stateAbbreaviation":"IL ","countryAbbreviation":"US","imageId":461,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1237,"buyerId":12345,"buyerLicenseId":129,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":462,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1238,"buyerId":12345,"buyerLicenseId":130,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":463,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"}]'
                },
                new List<String>{
                    '[{"buyerDocumentId":1231,"buyerid":345435,"buyerEmployeeId":98765,"buyerLicenseId":55511123,"buyerBankId":null,"tagFormName":"REGN","documentReferenceName":"Buyer Registration","imageId":456790,"docuwareLink":null,"createDate":"2021-01-23T19:13:05.507","documentFileName":null},{"buyerDocumentId":1232,"buyerid":null,"buyerEmployeeId":null,"buyerLicenseId":null,"buyerBankId":null,"tagFormName":"ADDBUY","documentReferenceName":"Additional Buyer","imageId":123355467,"docuwareLink":null,"createDate":"2021-01-23T19:13:10.393","documentFileName":null},{"buyerDocumentId":1233,"buyerid":null,"buyerEmployeeId":null,"buyerLicenseId":null,"buyerBankId":null,"tagFormName":"ADDBUY","documentReferenceName":"Additional Buyer","imageId":123355467,"docuwareLink":null,"createDate":"2021-04-23T19:13:10.393","documentFileName":null}]'
                },
                new List<String>{
                    '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}]}'
                }
            };
            MultiMockUtility mck = new MultiMockUtility();
            mck.responseList = respList;
            System.Test.setMock(HttpCalloutMock.class, mck);
            //Add mocks for getting related licences,documents and notes after buyer Id is created
            EventWebService.isMock = true;
            System.Test.StartTest();
            EventWebService.isMock = true;
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'apexrest/event/incoming/';
            req.httpMethod = 'PUT';
            string jsonPayload =setPayload('test', authUserKey,'345435','2' );
            System.debug('jsonPayload:' +jsonPayload );
            req.requestBody = Blob.valueof(jsonPayload);
            RestContext.request = req;
            RestContext.response = res;
            
            EventWebService.EventResponse resp = EventWebService.acceptEvent();
            System.Test.StopTest();
            Blob respBlob = res.responseBody; 
            System.debug('*Response Message: ' + resp.message);       
            System.assertEquals(200,res.statusCode,'Response is not 200');  
            System.assertEquals('Success',resp.status,'Status should be Success');
            String logsConcat = '';
            List<Integration_logs__c> logs =[SELECT Id,Request_Body__c,Response_Body__c,Transaction_Type__c,Transection_Id__c,Sent_To__c FROM Integration_logs__c LIMIT 5];
            for(Integration_logs__c log:logs){
                string errMsg = 'Log: TransactionId:' + log.Transection_Id__c + ' Resp: ' + log.Response_Body__c + ' Type: ' + log.Transaction_Type__c + 
                ' SentTo: ' + log.Sent_To__c + ' Request: ' + log.Request_Body__c;
                logsConcat = String.isBlank(logsConcat) ? errMsg : logsConcat + errMsg;
            }	
            System.assertEquals(8, [SELECT COUNT() FROM License__c WHERE Account__c =:accts[0].Id],'License count is not correct. ' + resp.message + 'logs: ' + logsConcat);
            System.assertEquals(3, [SELECT COUNT() FROM Document__c WHERE Account__c = :accts[0].Id],'Document count is not correct.' + resp.message + 'logs: ' + logsConcat);
            //System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:accts[0].Id ],'ASAP Notes count is not correct.' + resp.message + 'logs: ' + logsConcat);
           
            
        }
        
    }
   
    @IsTest
    static void ShouldCallProfileUpdateSegmentationPositive(){
        System.runAs(integrationUser){
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        System.debug('jsonPrevPayload: ' + jsonPrevPayload);
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
        System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,cons.size(), 'Contact size is not 1');
        System.assertEquals(2,[SELECT COUNT() FROM License__c WHERE Account__c=:accts[0].Id]);
        System.assertEquals(2,[SELECT COUNT() FROM Document__c WHERE Account__c=:accts[0].Id]);
       
        accts[0].API_Buyer_Id__c = '345435';
        update accts[0];
        cons[0].Buyer_ID__c = 'BUY-345435';
        update cons[0];
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload ='{"EventName":"profileupdate - segmentationupdated","SegmentationInfo":{"PrimaryActivity":4,"When":"2021-11-01T18:29:52.2502335+00:00","IPAddress":"147.243.170.243","DeviceSource":"0"},"BuyerId":"345435","When":"2020-12-08T12:00:00"}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Success',resp.status,'Status should be Success');	
        Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(0,cses.size(),'Cases size is not 0: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        
    }
}

    @IsTest
    static void ShouldCallProfileUpdateSegmentationNegative(){
        System.runAs(integrationUser){
        //run lead create first
        string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
        System.debug('jsonPrevPayload: ' + jsonPrevPayload);
        runPreviousPayload( jsonPrevPayload);       
        System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
        String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
        System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
        //run lead convert
        runPreviousPayload( jsonPrevPayload2);    
        List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,accts.size(),'Account size is not 1');
        List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
        System.assertEquals(1,cons.size(), 'Contact size is not 1');
        System.assertEquals(2,[SELECT COUNT() FROM License__c WHERE Account__c=:accts[0].Id]);
        System.assertEquals(2,[SELECT COUNT() FROM Document__c WHERE Account__c=:accts[0].Id]);
       
        accts[0].API_Buyer_Id__c = '345435';
        update accts[0];
        cons[0].Buyer_ID__c = 'BUY-345435';
        update cons[0];
        System.Test.StartTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'apexrest/event/incoming/';
        req.httpMethod = 'PUT';
        string jsonPayload ='{"EventName":"profileupdate - segmentationupdated","SegmentationInfo":{"PrimaryActivity":"InvalidEntry","When":"Today","IPAddress":"147.243.170.243","DeviceSource":"0"},"BuyerId":"345435","When":"2020-12-08T12:00:00"}';
        req.requestBody = Blob.valueof(jsonPayload);
        RestContext.request = req;
        RestContext.response = res;
        
        
        EventWebService.EventResponse resp = EventWebService.acceptEvent();
        System.Test.StopTest();
        Blob respBlob = res.responseBody; 
        System.debug('*Response Message: ' + resp.message);       
        System.assertEquals(200,res.statusCode,'Response is not 200');  
        System.assertEquals('Error',resp.status,'Status should be Success');	
        Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
		List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
        System.AssertEquals(0,cses.size(),'Cases size is not 0: ' + cses.size());
        EventIntegrationService evtIntService = new EventIntegrationService();
        
    }
        
    }
    @IsTest
    static void BuyerCreateAuctionAccessWIPositive(){
        System.runAs(integrationUser){
            //run lead create first
            string jsonPrevPayload = setPayload('accountprofilecreate', authUserKey,'','2' );
            runPreviousPayload( jsonPrevPayload);       
            System.assertEquals(1,[SELECT Count() FROM Lead WHERE AuthUserKey__c=:authUserKey]);        
            String jsonPrevPayload2 = setPayload('accountprofilecomplete', authUserKey,'','2' );
            System.debug('jsonPrevPayload2: ' + jsonPrevPayload2);
            //run lead convert
            runPreviousPayload( jsonPrevPayload2);    
            List<Account> accts = [SELECT Id,BI_ID__c,API_Buyer_Id__c FROM Account WHERE AuthUserKey__c=:authUserKey];
            System.assertEquals(1,accts.size(),'Account size is not 1');
            List<Contact> cons =[SELECT Id,Buyer_ID__c FROM Contact WHERE AuthUserKey__c=:authUserKey];
            System.assertEquals(1,cons.size(), 'Contact size is not 1');        
            
            System.Test.StartTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'apexrest/event/incoming/';
            req.httpMethod = 'PUT';        
            
            string jsonPayload = '{"EventName":"buyercreated","AuthUserKey":'+ authUserKey+',"When":"2020-12-08T12:00:00","RegistrationModel":{"AuthUserKey":"'+ authUserKey+'","Identifier":{"BuyerId":null,"UserId":"123123","EmployeeId":null,"BuyerStatus":1},"Guest":{"Email":"test011@test.com","FirstName":"test","LastName":"test","LoggedInTenant":1,"TermsOfUse":{"Status":true,"IPAddress":"","When":"2021-08-24T17:26:21.6594152+00:00"}},"GuestInfo":{"Purpose":"","PreferredLanguage":1,"PreferredTenant":1,"UserType":2,"When":"2021-08-24T17:01:14.2430453+00:00","Country":"US","CountryCode":"US","State":"AL","Mobile":"2623738907","MobileCountryCode":"1","CallToAction":2,"IsAuctionAccessUser":true},"AuctionAccess":{"DealerRecordIdentifier":"test123","AuctionAccessRequest":{"AuctionAccessId":"2342345","Last4PhotoId":"1234","AuctionId":"1000000001","Source":2,"CompanyId":"5533TestCompanyId","Last4GovernmentId":"1234"},"AuctionAccessDealers":[{"CompanyId":123123,"CompanyName":"CompanyNameTest","IsActive":true}],"IsAdditionalBusiness":false,"AuctionAccessResponse":{"Status":true,"ErrorMessage":null}},"OCRPayload":null,"IDPayload":{"IdentificationNumber":"","IdentificationProof":0,"StateIssued":null,"CountryIssued":null,"BirthDate":"1969-05-07T00:00:00Z","ExpirationDate":null,"Contact":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"12 e. fake drive","Street2":null,"City":"NEW LONDON","State":"NH","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":"us","Phone1CountryCode":"1","PhoneNumber1":"1231231234","Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null},"IsAddressVariesFromID":false,"Licenses":null},"OCRStatus":0,"BusinessPayload":{"CompanyName":"AUTO ADVISORS INC","FEIN":"123456789","Licenses":null,"ContactPayload":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"12 e. fake drive","Street2":null,"City":"NEW LONDON","State":"WI","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":"us","Phone1CountryCode":"1","PhoneNumber1":"1231231236","Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null}},"UserAcceptance":{"AcceptAuctionRules":true,"AcceptAuctionRulesDateTime":"2021-08-24T05:26:21.65Z","AcceptPrivacyPolicy":true,"AcceptPrivacyPolicyDateTime":"2021-08-24T05:26:21.65Z","IPAddress":"147.243.154.43","DeviceSource":0},"Files":null,"PromoCode":null,"LexusNexisResults":null,"Payment":{"PaymentMethod":2,"Amount":10,"AutoRenewalFlag":false,"IsPromoCodeApplied":false,"IsBuyerFromEU":false,"RegistrationTransactionId":"123123","PageSource":2,"DeviceSource":0,"IPAddress":"","CCPayment":{"CCId":"5097348","BillingAddress":{"LegalFirstName":"John","LegalLastName":"Doe","Street":"271 BURNT HILL ROAD","Street2":null,"City":"NEW LONDON","State":"NH","Zip":"03257","Country":"US","FaxCountry":null,"FaxCountryCode":null,"Fax":null,"Phone1Country":null,"Phone1CountryCode":null,"PhoneNumber1":null,"Phone2Country":null,"Phone2CountryCode":null,"PhoneNumber2":null,"PhoneExtension1":null,"PhoneExtension2":null},"CardType":"","CardNumber":"","CardExpirationDate":""},"PPPayment":null,"When":"2021-08-24T17:26:21.2212345+00:00","PSPayment":null,"MNPayment":null},"CurrentStep":25,"Created":"2021-08-24T17:26:23.596634+00:00"}}';
            req.requestBody = Blob.valueof(jsonPayload);
            RestContext.request = req;
            RestContext.response = res;
            
            EventWebService.EventResponse resp = EventWebService.acceptEvent();
            system.debug('*Message: ' + resp.message);
            System.Test.StopTest();
            Blob respBlob = res.responseBody; 
            System.debug('*Response Message: ' + resp.message);       
            System.assertEquals(200,res.statusCode,'Response is not 200 ' + resp.message);  
            System.assertEquals('Success',resp.status,'Status should be Success' + resp.message);
            Contact con =  [SELECT Id,FirstName,LastName,Individual_Response_Code__c,Individual_Response_Error__c FROM Contact WHERE AuthUserKey__c=:authUserKey LIMIT 1][0];
            List<Case> cses = [SELECT ContactId,Description,Origin,Priority,Reason_for_Case__c,RecordTypeId,Subject,Type FROM Case WHERE ContactId =: con.Id LIMIT 1];
            System.AssertEquals(1,cses.size(),'Cases size is not 1: ' + cses.size());
            EventIntegrationService evtIntService = new EventIntegrationService();
            List<BSO_Case_Service_Event__mdt> caseEvents =evtIntService.caseSettings.get('New Auction Access Review - Wisconsin');
            for(BSO_Case_Service_Event__mdt caseEvent:caseEvents){
                if(String.isNotBlank(String.Valueof(caseEvent.Lookup_Value__c))){
                    System.AssertEquals(cses[0].get(caseEvent.Field_API__c + 'Id'),con.Id);
                }
                else if(caseEvent.Field_API__c == 'RecordTypeId'){
                    Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseEvent.Value__c).getRecordTypeId();
                    System.AssertEquals(cses[0].get('RecordTypeId'),recordTypeId );
                }else{
                    System.AssertEquals(caseEvent.Value__c,cses[0].get(caseEvent.Field_API__c),'Field: ' + caseEvent.Field_API__c + ' Expected: ' + caseEvent.Value__c + ' Actual: ' + cses[0].get(caseEvent.Field_API__c));
                }
            }
            List<Task> tsks = [SELECT Id,OwnerId,Subject,WhatId,WhoId FROM Task Where WhatId =:cses[0].Id AND WhoId=:con.Id];
            System.AssertEquals(2,tsks.size());
        }
    }
}