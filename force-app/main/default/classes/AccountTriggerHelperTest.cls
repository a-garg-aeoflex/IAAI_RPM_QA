@IsTest
private with sharing class AccountTriggerHelperTest {
    static Account buyerAcct;
    static Contact buyerCon;
    static Account brokerAcct;
    static Contact brokerCon;
    static Document__c buyDoc;
    static License__c buyLic;
    static User buyerUser;
    static User integrationUser;
    static final Id BUYER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    static final Id ASAP_INT_LOG_RECORD_TYPE_ID =  Schema.SObjectType.Integration_logs__c.getRecordTypeInfosByDeveloperName().get('ASAP_Outbound').getRecordTypeId(); 
    static {     
        integrationUser = TestDataFactory.createUser(true, 'testIntegration2323','Integration User');
        System.runAs(integrationUser){
            buyerAcct = TestDataFactory.createAccounts(false,1, 'John Buyer', BUYER_ACCOUNT_RECORD_TYPE_ID)[0];  
            brokerAcct = TestDataFactory.createAccounts(false,1, 'Elliot Broker')[0];  
            buyerAcct.API_Buyer_Id__c = '12345';
            brokerAcct.API_Buyer_Id__c = '12346';
            List<Account> accts =new List<Account>{ buyerAcct,brokerAcct};
            insert accts;        
            buyerCon = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerCon.Buyer_Employee_ID__c = '98765';
            insert buyerCon;
            brokerCon = TestDataFactory.createContact(true,1, new List<Account>{ brokerAcct})[0];
            buyLic =  TestDataFactory.createLicenses(false,1, new List<List<String>>{new List<String>{buyerAcct.Id,'55511123'}},'')[0];
            buyDoc =  TestDataFactory.createDocuments(false,1, new List<List<String>>{new List<String>{buyerAcct.Id}},'')[0];
            buyerUser = TestDataFactory.createUser(true, 'buyerUser1','IAA Buyer Services');
        }
    }
    @IsTest
    static void GetLicsPositive(){       
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{
                '[{"buyerDocumentId":1231,"buyerId":12345,"buyerLicenseId":123,"licenseNumber":"111","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2021-03-11T00:00:00","expirationDate":"2021-03-19T00:00:00","stateAbbreaviation":"NE ","countryAbbreviation":"US","imageId":456,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1232,"buyerId":12345,"buyerLicenseId":124,"licenseNumber":"112","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"UT ","countryAbbreviation":"US","imageId":457,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1233,"buyerId":12345,"buyerLicenseId":125,"licenseNumber":"113","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2044-02-02T00:00:00","stateAbbreaviation":"NV ","countryAbbreviation":"US","imageId":458,"docuwareLink":null},{"buyerDocumentId":1234,"buyerId":12345,"buyerLicenseId":126,"licenseNumber":"114","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":459,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1235,"buyerId":12345,"buyerLicenseId":127,"licenseNumber":"115","licenseTypeCode":"CTC   ","licenseType":"Tax License","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":460,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1236,"buyerId":12345,"buyerLicenseId":128,"licenseNumber":"116","licenseTypeCode":"IOB   ","licenseType":"Illinois Out of State Business","effectiveDate":"2016-04-26T14:24:47.507","expirationDate":"2016-09-30T00:00:00","stateAbbreaviation":"IL ","countryAbbreviation":"US","imageId":461,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1237,"buyerId":12345,"buyerLicenseId":129,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":462,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1238,"buyerId":12345,"buyerLicenseId":130,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":463,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"}]'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_License_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        System.assertEquals(8, [SELECT COUNT() FROM License__c LIMIT 50000],'License count is not correct');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c,Account__c,License__c,Transaction_Type__c FROM Integration_logs__c 
                WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c
             LIMIT 50000];       
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }

    @IsTest
    static void GetDocsOneConOneLicOneNotPositive(){
        //Run as buyerUser to make sure profileName check works
        System.runAs(buyerUser){
            List<List<String>> respList = new List<List<String>>{              
                new List<String>{                
                    '[{"buyerDocumentId":1231,"buyerid":12345,"buyerEmployeeId":98765,"buyerLicenseId":55511123,"buyerBankId":null,"tagFormName":"REGN","documentReferenceName":"Buyer Registration","imageId":456790,"docuwareLink":null,"createDate":"2014-01-23T19:13:05.507","documentFileName":null},{"buyerDocumentId":1232,"buyerid":12345,"buyerEmployeeId":null,"buyerLicenseId":null,"buyerBankId":null,"tagFormName":"ADDBUY","documentReferenceName":"Additional Buyer","imageId":123355467,"docuwareLink":null,"createDate":"2014-01-23T19:13:10.393","documentFileName":null}]'
                }
            };
            LicenseTriggerHelper.licenseFirstRun= false; 
            insert buyLic;
            System.AssertEquals(1,[SELECT COUNT() FROM License__c WHERE Id=:buyLic.Id],'License do not get created.');
            MultiMockUtility mck = new MultiMockUtility();
            mck.responseList = respList;
            System.Test.setMock(HttpCalloutMock.class, mck);
            System.debug('* buyLic: ' + JSON.serializePretty(buyLic));           
            
            System.Test.startTest();
            AccountTriggerHelper.accountFirstRun = true;
            buyerAcct.Get_Document_Status__c = 'Request';
            update buyerAcct;
            System.Test.stopTest();
            System.assertEquals(2, [SELECT COUNT() FROM Document__c WHERE Account__c =: buyerAcct.Id],'Document count is not correct.');
            List<Document__c> docs = [SELECT Id,Account__c,Contact__c,License__c,Ext_Created_Date__c FROM Document__c  WHERE Account__c =: buyerAcct.Id AND License__c =:buyLic.Id AND Contact__c=:buyerCon.Id];
            System.debug('docs: ' + docs[0].Ext_Created_Date__c.format());
            System.assertEquals(1, docs.size() ,'Document count is not correct for license and contact. ' + docs.size());
            //Asserting change for IIA-133 for changing timezone 
            System.assertEquals('23/01/2014 19:13',docs[0].Ext_Created_Date__c.format());
            List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
                AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
                AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Documents_Api').Value__c LIMIT 50000];
            System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
            System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
        }
    }
    @IsTest
    static void GetLicsFourHundredNegative(){
        
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            },
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_License_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM License__c LIMIT 50000],'License count is not correct');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
            AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());
    }
    @IsTest
    static void GetLicsBadRecTypeNegative(){
        
        List<List<String>> respList = new List<List<String>>{                       
            new List<String>{
                '[{"buyerDocumentId":1231,"buyerId":12346,"buyerLicenseId":123,"licenseNumber":"111","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2021-03-11T00:00:00","expirationDate":"2021-03-19T00:00:00","stateAbbreaviation":"NE ","countryAbbreviation":"US","imageId":456,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"}]'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        brokerAcct.Get_License_Status__c = 'Request';
        brokerAcct.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Account').getRecordTypeId();
        update brokerAcct;
        
        System.Test.stopTest();
        List<Integration_logs__c> loggs = [SELECT Id,Response_Body__c FROM Integration_logs__c];
        System.debug('logCount: ' + loggs.size());
        //assert 0 log count because BSO apis do not urn on Broker accounts        
        System.assertEquals(0, [SELECT COUNT() FROM License__c LIMIT 50000],'License count do not equal 0');
      
    }
    @IsTest
    static void GetLexusNexusBGPositive(){
        List<List<String>> respList = new List<List<String>>{       
            new List<String>{''},         
            new List<String>{               
                '[{"validatorType":"Background","validatorResponse":{"responseCode":"Review","responseDescription":{"alertID":"6504436508","reasons":[{"entityScore":"100","name":"Compliance","reasonListed":"Compliance Reason1"},{"entityScore":"100","name":"Compliance2","reasonListed":"Compliance Reason2"}],"errorMessage":""}}},{"validatorType":"Business","validatorResponse":{"responseCode":"Success","responseDescription":{"alertID":null,"reasons":null,"errorMessage":null}}}]'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.FEIN__c = '122342343';
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,Get_LexisNexis_Result__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        System.debug('Buyer Account: ' + acct);
        System.assert(acct.Business_Date_Ran__c != null);
        Contact con =[SELECT Id,Individual_Response_Code__c,Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerCon.Id];
        System.assert(String.isNotBlank(con.Individual_Response_Code__c));
        System.assert(String.isNotBlank(con.Individual_Response_Description__c));
        System.assert(String.isBlank(con.Individual_Response_Error__c));
        System.assert(con.Individual_Date_Ran__c !=null);
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c IN : new List<String>{EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c,EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c} LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(logs?.get(0)?.Response_Body__c ,EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,'Integration logs do not equal 0');
        
    }
    @IsTest
    static void GetLexusNexusBGErrConsPositive(){
        Contact buyerConOwner;
        System.runAs(integrationUser){            
            buyerConOwner = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConOwner.Title = 'OWNR';
            insert buyerConOwner;
        }
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{               
                '[{"validatorType":"Background","validatorResponse":{"responseCode":"Technical","responseDescription":{"alertID":null,"reasons":null,"errorMessage":"Error while running IndividualComplianceScreening. Error: Input IndividualIdentityValidatorQuery.IdentityModel is null."}}},{"validatorType":"Business","validatorResponse":{"responseCode":"Success","responseDescription":{"alertID":null,"reasons":null,"errorMessage":null}}}]'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();      
        Contact conOwner =[SELECT Id,LastName,Title,Individual_Response_Code__c,Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerConOwner.Id];
        System.assert(String.isNotBlank(conOwner.Individual_Response_Code__c));
        System.assert(String.isBlank(conOwner.Individual_Response_Description__c));
        System.assert(String.isNotBlank(conOwner.Individual_Response_Error__c));
        System.assert(conOwner.Individual_Date_Ran__c!=null);        
        Contact con =[SELECT Id,LastName,Title,Individual_Response_Code__c,	Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerCon.Id];
        System.assertEquals(null,con.Individual_Date_Ran__c);
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(logs?.get(0)?.Response_Body__c ,EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,'Integration logs do not equal 0');
        
    }
    
    @IsTest
    static void GetLexusNexusBGNegative(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{''},                
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            },
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
            AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());
    }
    @IsTest
    static void GetLexusNexusBUSPositive(){
        Contact buyerConOwner;
        System.runAs(integrationUser){            
            buyerConOwner = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConOwner.Title = 'OWNR';
            insert buyerConOwner;
        }
        List<List<String>> respList = new List<List<String>>{           
            new List<String>{
                '[{"validatorType":"Background","validatorResponse":{"responseCode":"Success","responseDescription":{"alertID":null,"reasons":null,"errorMessage":null}}},{"validatorType":"Business","validatorResponse":{"responseCode":"Review","responseDescription":{"alertID":"6504436508","reasons":[{"entityScore":"100","name":"Compliance","reasonListed":"Compliance Reason1"},{"entityScore":"100","name":"Compliance2","reasonListed":"Compliance Reason2"}],"errorMessage":""}}}]'                
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,Get_LexisNexis_Result__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        System.assert(acct.Business_Date_Ran__c !=null);
        System.assert(String.isNotBlank(acct.Business_Response_Code__c));
        System.assert(String.isNotBlank(acct.Business_Response_Desc__c));
        System.assert(String.isBlank(acct.Business_Response_Error__c));
        Contact con =[SELECT Id,Individual_Response_Code__c,Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerConOwner.Id];
        
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assert(con.Individual_Date_Ran__c!=null);     
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    
    }
    @IsTest
    static void UpdateBuyerNegative(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.FEIN__c = '122342343';
        update buyerAcct;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
            AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());
    }
    @IsTest
    static void SendUpdateBuyerPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{''}           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.FEIN__c = '122342343';
        update buyerAcct;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(logs?.get(0)?.Response_Body__c ,EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,'Integration logs do not equal 0');
    }   
    @IsTest
    static void SendUpdateBuyerNegative(){
        List<List<String>> respList = new List<List<String>>{       
            new List<String>{
                '{"Error":"" }', '400','Bad Request'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.FEIN__c = '122342343';
        update buyerAcct;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
            AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Update_Buyer_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());
    }
    @IsTest
    static void GetBuyerNotesPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}],"buyerEmployeeNotes":[{"buyerId":12345,"noteText":"Buyer status changed to: ","categoryCode":"BUY","publicViewableInd":true,"createDateTime":"2018-04-18T10:51:08.917","userId":12911961,"buyerEmployeeId":98765},{"buyerId":12345,"noteText":"Buyer status changed to: ","categoryCode":"BUY","publicViewableInd":true,"createDateTime":"2020-04-22T11:36:55.97","userId":16183539,"buyerEmployeeId":98765}]}'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact buyerConTwo;      
        
        System.Test.startTest();
        System.runAs(integrationUser){
            buyerConTwo = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConTwo.Buyer_Employee_ID__c = '98765';
            insert buyerConTwo;
            System.debug('conTwo: '+ buyerConTwo.Id);
        }
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        
        System.assertEquals(4, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 4 related to the Account');
        //Verify that the second contact got related since we have more than one contact with the same buyerEmpleeId 
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c!=Null],'ASAP Notes count is not equal to 2 related to the Account and Contact');
    
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    
    }
    @IsTest
    static void GetBuyerNotesNegative(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '{"Error":"" }', '400','Bad Request'                
            },
            new List<String>{
                '{"Error":"" }', '400','Bad Request'                
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 0 related to the Account');
        System.assertEquals(0, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c=:buyerCon.Id],'ASAP Notes count is not equal to 0 related to the Account and Contact');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Failed' 
            AND API_Type__c = 'Outbound' AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty(),'Integration logs size is incorrect: ' +logs.size());

        
    }
    @IsTest
    static void GetBuyerNotesNoEmpPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}]}'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact buyerConTwo;       
        
        System.Test.startTest();
        System.runAs(integrationUser){
            buyerConTwo = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConTwo.Buyer_Employee_ID__c = '98765';
            insert buyerConTwo;
            System.debug('conTwo: '+ buyerConTwo.Id);
        }
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 2 related to the Account');
        //Verify that the second contact got related since we have more than one contact with the same buyerEmpleeId 
        System.assertEquals(0, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c!=null],'ASAP Notes count is not equal to 0 related to the Account and Contact is not blank');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c, logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @IsTest
    static void GetBuyerNotesOnlyEmpPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{
                '{"buyerEmployeeNotes":[{"buyerId":12345,"noteText":"Buyer status changed to: ","categoryCode":"BUY","publicViewableInd":true,"createDateTime":"2018-04-18T10:51:08.917","userId":12911961,"buyerEmployeeId":98765},{"buyerId":12345,"noteText":"Buyer status changed to: ","categoryCode":"BUY","publicViewableInd":true,"createDateTime":"2020-04-22T11:36:55.97","userId":16183539,"buyerEmployeeId":98765}]}'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact buyerConTwo;      
        
        System.Test.startTest();
        System.runAs(integrationUser){
            buyerConTwo = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConTwo.Buyer_Employee_ID__c = '98765';
            insert buyerConTwo;
            System.debug('conTwo: '+ buyerConTwo.Id);
        }
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c LIMIT 50000];
        System.debug('logs size: ' + logs?.size());
        for(Integration_logs__c log:logs){
            System.debug('log: ' + log);
        }
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());

        System.assertEquals(0, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c=Null],'ASAP Notes count is not equal to 0 related to the Account and Contact is  blank');
        //Verify that the second contact got related since we have more than one contact with the same buyerEmpleeId 
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c!= Null],'ASAP Notes count is not equal to 2 related to the Account and Contact');
        
        System.assertEquals(logs?.get(0)?.Response_Body__c ,EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,'Integration logs do not equal 0');
    }
    @IsTest
    static void SendBuyerGetLexusNexusBGGetNotesPositive(){
        
        List<List<String>> respList = new List<List<String>>{       
            new List<String>{''},         
            new List<String>{               
                '[{"validatorType":"Background","validatorResponse":{"responseCode":"Review","responseDescription":{"alertID":"6504436508","reasons":[{"entityScore":"100","name":"Compliance","reasonListed":"Compliance Reason1"},{"entityScore":"100","name":"Compliance2","reasonListed":"Compliance Reason2"}],"errorMessage":""}}},{"validatorType":"Business","validatorResponse":{"responseCode":"Success","responseDescription":{"alertID":null,"reasons":null,"errorMessage":null}}}]'
            },
            new List<String>{
                '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}]}'
            } 
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.FEIN__c = '122342343';
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,Get_LexisNexis_Result__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        System.assert(acct.Business_Date_Ran__c!=null );
        Contact con =[SELECT Id,Individual_Response_Code__c,Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerCon.Id];
        System.assert(String.isNotBlank(con.Individual_Response_Code__c));
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 2 related to the Account');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c IN : new List<String>{EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c} LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);

    }
    @IsTest
    static void GetLexusNexusBGGetNotesPositive(){
        List<List<String>> respList = new List<List<String>>{      
            new List<String>{               
                '[{"validatorType":"Background","validatorResponse":{"responseCode":"Review","responseDescription":{"alertID":"6504436508","reasons":[{"entityScore":"100","name":"Compliance","reasonListed":"Compliance Reason1"},{"entityScore":"100","name":"Compliance2","reasonListed":"Compliance Reason2"}],"errorMessage":""}}},{"validatorType":"Business","validatorResponse":{"responseCode":"Success","responseDescription":{"alertID":null,"reasons":null,"errorMessage":null}}}]'
            },
            new List<String>{
                '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}]}'
            } 
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_LexisNexis_Result__c = 'Request';
        buyerAcct.Get_Note_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,Get_LexisNexis_Result__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        System.assert(acct.Business_Date_Ran__c!= null );
        Contact con =[SELECT Id,Individual_Response_Code__c,Individual_Response_Description__c,Individual_Response_Error__c,Individual_Date_Ran__c FROM Contact WHERE Id =: buyerCon.Id];
        System.assert(String.isNotBlank(con.Individual_Response_Code__c));
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 2 related to the Account');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c IN : new List<String>{EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c,EnvironmentSetting__mdt.getInstance('BSO_Get_Lexis_Nexis_Check_Api').Value__c} LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(logs?.get(0)?.Response_Body__c ,EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,'Integration logs do not equal 0');
    }
    @IsTest
    static void SendBuyerGetBuyerNotesNoEmpPositive(){
        List<List<String>> respList = new List<List<String>>{ 
            new List<String>{''},    
            new List<String>{
                '{"buyerNotes":[{"buyerId":12345,"noteText":"Expired License","categoryCode":null,"publicViewableInd":false,"createDateTime":"2021-12-18T14:28:57.46","userId":56579},{"buyerId":12345,"noteText":"Buyer Status was changed to InActive as all the licenses (or) Registration has expired.","categoryCode":null,"publicViewableInd":false,"createDateTime":"2020-10-01T01:01:48.923","userId":1}]}'
            }           
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        Contact buyerConTwo;       
        
        System.Test.startTest();
        System.runAs(integrationUser){
            buyerConTwo = TestDataFactory.createContact(false,1, new List<Account>{ buyerAcct})[0];
            buyerConTwo.Buyer_Employee_ID__c = '98765';
            insert buyerConTwo;
            System.debug('conTwo: '+ buyerConTwo.Id);
        }
        AccountTriggerHelper.accountFirstRun = true;       
        buyerAcct.Get_Note_Status__c = 'Request';
        buyerAcct.FEIN__c = '122342343';
        update buyerAcct;
        System.Test.stopTest();
        
        System.assertEquals(2, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id ],'ASAP Notes count is not equal to 2 related to the Account');
        //Verify that the second contact got related since we have more than one contact with the same buyerEmpleeId 
        System.assertEquals(0, [SELECT COUNT() FROM ASAP_Note__c WHERE ASAP_Id__c!=Null AND Account__c=:buyerAcct.Id And Contact__c!=null],'ASAP Notes count is not equal to 0 related to the Account and Contact is not blank');
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Notes_Api').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }
    @IsTest
    static void BulkUpdateAccountsPositive(){
        
        Integer count = 200;
        List<Account> buyerAccounts;
        List<Contact> buyerContacts;
        System.runAs(integrationUser){           
            buyerAccounts = TestDataFactory.createAccounts(true,count,'Buyer Account',ContactTriggerDispatcher.BUYER_ACCT_RECORDTYPE_ID);        
            buyerContacts = TestDataFactory.createContact(true,count,buyerAccounts,ContactTriggerDispatcher.BUYER_EMP_CONTACT_RECORDTYPE_ID);
        }
        for(Integer i=0;i<count;i++){
            buyerAccounts.get(i).FEIN__c = '122342343';
        }
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{''}
        };
        MultiMockUtility mck = new MultiMockUtility(); 
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        AccountTriggerHelper.accountFirstRun = true;  
        ContactTriggerDispatcher.ContactFirstRun = true;
        System.Test.startTest();
        
        update buyerAccounts;
        System.Test.stopTest();
        System.assertEquals(count, [SELECT COUNT() FROM Account WHERE Id IN:buyerAccounts AND FEIN__c = '122342343' LIMIT 50000],'Accounts updated is not equal to: ' + count);
        //Don't assert any logs because BSO triggers won't run in bulk mode
        
    }
    
    @IsTest
    static void ShouldUnlinkBuyerAccountPositive(){
        
        UnlinkServiceMock mockService = new UnlinkServiceMock();
        mockService.success = true;
        System.Test.setMock(HttpCalloutMock.class, mockService);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.AuctionAccess_Company_Id__c = '123';
        buyerAcct.Unlink_AA_Membership__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,AuctionAccess_Unlink_Date__c, AuctionAccess_Unlink_Requested_By__c,Get_LexisNexis_Result__c,Unlink_AA_Membership__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c 
            WHERE Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('Unlink_Success_Message').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assert(acct.Unlink_AA_Membership__c == 'Available');
        System.assert(acct.AuctionAccess_Unlink_Date__c != null);
        System.assert(acct.AuctionAccess_Unlink_Requested_By__c != null);
        for(Integration_Logs__c log : logs){
            System.assert(log.Status__c == 'Success');
        }
    }

        
    @IsTest
    static void ShouldUnlinkBuyerAccountNegative(){
        
        UnlinkServiceMock mockService = new UnlinkServiceMock();
        mockService.success = false;
        System.Test.setMock(HttpCalloutMock.class, mockService);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.AuctionAccess_Company_Id__c = '123';
        buyerAcct.Unlink_AA_Membership__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        Account acct =[SELECT Id,AuctionAccess_Unlink_Date__c, AuctionAccess_Unlink_Requested_By__c, Get_LexisNexis_Result__c,Unlink_AA_Membership__c,Business_Response_Code__c,Business_Response_Desc__c,Business_Response_Error__c,Business_Date_Ran__c FROM Account WHERE Id =: buyerAcct.Id];
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c 
            WHERE Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('Unlink_Buyer_Account_API').Value__c LIMIT 50000];
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        
        System.assert(acct.Unlink_AA_Membership__c == 'Available');
        System.assert(acct.AuctionAccess_Unlink_Date__c == null);
        System.assert(acct.AuctionAccess_Unlink_Requested_By__c == null);
        
        for(Integration_Logs__c log : logs){
            System.assert(log.Status__c == 'Failed');
        }
    }

    @IsTest
    static void ShouldDeleteAndGetDocuments(){

        insert buyDoc;
        System.assertEquals(1, [SELECT COUNT() FROM Document__c LIMIT 50000],'Doc count is not correct');
        System.assert(buyDoc.Account__c == buyerAcct.Id);

        List<String> documentIds = new List<String>{'1231', '1232'}; //Ids of post test documents
        

        List<Document__c> beforeDocuments = [SELECT Id,Account__c,Contact__c,License__c,Ext_Created_Date__c, Document_Name__c, Document_Key__c FROM Document__c  WHERE Account__c =: buyerAcct.Id];
        System.assertEquals(1, [SELECT COUNT() FROM Document__c WHERE Account__c =: buyerAcct.Id],'Document count is not correct.');
        for(Document__c doc : beforeDocuments){
            System.assert(!documentIds.contains(doc.Document_Key__c));
        }
        
        //Run as buyerUser to make sure profileName check works
        System.runAs(buyerUser){
            List<List<String>> respList = new List<List<String>>{              
                new List<String>{                
                    '[{"buyerDocumentId":1231,"buyerid":12345,"buyerEmployeeId":98765,"buyerLicenseId":55511123,"buyerBankId":null,"tagFormName":"REGN","documentReferenceName":"Buyer Registration","imageId":456790,"docuwareLink":null,"createDate":"2014-01-23T19:13:05.507","documentFileName":null},{"buyerDocumentId":1232,"buyerid":12345,"buyerEmployeeId":null,"buyerLicenseId":null,"buyerBankId":null,"tagFormName":"ADDBUY","documentReferenceName":"Additional Buyer","imageId":123355467,"docuwareLink":null,"createDate":"2014-01-23T19:13:10.393","documentFileName":null}]'
                }
            };
            
            MultiMockUtility mck = new MultiMockUtility();
            mck.responseList = respList;
            System.Test.setMock(HttpCalloutMock.class, mck);
            
            System.Test.startTest();
            AccountTriggerHelper.accountFirstRun = true;
            buyerAcct.Get_Document_Status__c = 'Request';
            update buyerAcct;
            System.Test.stopTest();
            System.assertEquals(2, [SELECT COUNT() FROM Document__c WHERE Account__c =: buyerAcct.Id],'Document count is not correct.');
            List<Document__c> docs = [SELECT Id,Account__c,Contact__c,License__c,Ext_Created_Date__c, Document_Name__c, Document_Key__c FROM Document__c  WHERE Account__c =: buyerAcct.Id AND License__c =:buyLic.Id AND Contact__c=:buyerCon.Id];
            
            for(Document__c doc : docs){
                System.assert(documentIds.contains(doc.Document_Key__c));
            }
    
            List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c FROM Integration_logs__c WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
                AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
                AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Documents_Api').Value__c LIMIT 50000];
            System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
            System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
        }
    }

    @IsTest
    static void ShouldDeleteAndGetLicenses(){      
        List<String> asapLicensesIdValid = new List<String>{'123','124','125','126','127','128','129','130'};
        LicenseTriggerHelper.licenseFirstRun = false;
        insert buyLic;
        
        List<License__c> preLicensesInserted = [SELECT Id, ASAP_License_ID__c FROM License__c WHERE Account__c =: buyerAcct.Id];
        for(License__c lic : preLicensesInserted){
            System.assert(!asapLicensesIdValid.contains(lic.ASAP_License_ID__c));
        }
        System.assertEquals(1, [SELECT COUNT() FROM License__c LIMIT 50000],'License count is not correct');
        System.assert(buyLic.Account__c == buyerAcct.Id);
        List<List<String>> respList = new List<List<String>>{                            
            new List<String>{
                '[{"buyerDocumentId":1231,"buyerId":12345,"buyerLicenseId":123,"licenseNumber":"111","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2021-03-11T00:00:00","expirationDate":"2021-03-19T00:00:00","stateAbbreaviation":"NE ","countryAbbreviation":"US","imageId":456,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1232,"buyerId":12345,"buyerLicenseId":124,"licenseNumber":"112","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"UT ","countryAbbreviation":"US","imageId":457,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1233,"buyerId":12345,"buyerLicenseId":125,"licenseNumber":"113","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2044-02-02T00:00:00","stateAbbreaviation":"NV ","countryAbbreviation":"US","imageId":458,"docuwareLink":null},{"buyerDocumentId":1234,"buyerId":12345,"buyerLicenseId":126,"licenseNumber":"114","licenseTypeCode":"EXP   ","licenseType":"Exporter","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":459,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1235,"buyerId":12345,"buyerLicenseId":127,"licenseNumber":"115","licenseTypeCode":"CTC   ","licenseType":"Tax License","effectiveDate":"2014-02-02T00:00:00","expirationDate":"2029-02-02T00:00:00","stateAbbreaviation":"TX ","countryAbbreviation":"US","imageId":460,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1236,"buyerId":12345,"buyerLicenseId":128,"licenseNumber":"116","licenseTypeCode":"IOB   ","licenseType":"Illinois Out of State Business","effectiveDate":"2016-04-26T14:24:47.507","expirationDate":"2016-09-30T00:00:00","stateAbbreaviation":"IL ","countryAbbreviation":"US","imageId":461,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1237,"buyerId":12345,"buyerLicenseId":129,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":462,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"},{"buyerDocumentId":1238,"buyerId":12345,"buyerLicenseId":130,"licenseNumber":"SL-420","licenseTypeCode":"DIS   ","licenseType":"Dismantler","effectiveDate":"2012-10-01T00:00:00","expirationDate":"2018-09-30T00:00:00","stateAbbreaviation":"WI ","countryAbbreviation":"US","imageId":463,"docuwareLink":"http://saleforce.com/api/Document/GetDocument/"}]'
            }
        };
        MultiMockUtility mck = new MultiMockUtility();
        mck.responseList = respList;
        System.Test.setMock(HttpCalloutMock.class, mck);
        System.Test.startTest();
        AccountTriggerHelper.accountFirstRun = true;
        buyerAcct.Get_License_Status__c = 'Request';
        update buyerAcct;
        System.Test.stopTest();
        System.assertEquals(8, [SELECT COUNT() FROM License__c LIMIT 50000],'License count is not correct');

        List<License__c> licensesInserted = [SELECT Id, ASAP_License_ID__c FROM License__c WHERE Account__c =: buyerAcct.Id];
        for(License__c lic : licensesInserted){
            System.assert(asapLicensesIdValid.contains(lic.ASAP_License_ID__c));
        }
        List<Integration_logs__c> logs = [SELECT Id,Request_Body__c,Status__c,API_Type__c,RecordType.Name,Transection_Id__c,Response_Body__c,Account__c,License__c,Transaction_Type__c FROM Integration_logs__c 
                WHERE Status__c='Success' AND API_Type__c = 'Outbound' 
            AND RecordTypeId=:ASAP_INT_LOG_RECORD_TYPE_ID AND Transection_Id__c ='12345' 
            AND Account__c =: buyerAcct.Id AND Transaction_Type__c =: EnvironmentSetting__mdt.getInstance('BSO_Get_Buyer_Licenses_Api').Value__c
             LIMIT 50000];       
        System.assert(!logs.isEmpty() ,'Integration logs size is incorrect: ' +logs.size());
        System.assertEquals(EnvironmentSetting__mdt.getInstance('BSO_Buyer_Success_Message').Value__c,logs?.get(0)?.Response_Body__c ,'Response is incorrect: ' + logs?.get(0)?.Response_Body__c);
    }


}