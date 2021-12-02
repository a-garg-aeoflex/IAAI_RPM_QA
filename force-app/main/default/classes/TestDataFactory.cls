/**
* Lev
* @date 2020
*
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
*
* @description TestDataFactory used to create test data
*/
public with sharing class TestDataFactory {
    public static final Id BROKER_ACCOUNT_RECORD_TYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Account').getRecordTypeId();
    public static final Id DEFAULT_LICENSE_RECORD_TYPE_ID = Schema.SObjectType.License__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
    public static List<Account> createAccounts(Boolean isInsert,Integer cnt, String acctName) {
        return createAccounts(isInsert,cnt, acctName,'');
    }
    public static List<Account> createAccounts(Boolean isInsert,Integer cnt, String acctName,String recordTypeId) {
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<cnt;i++) {
            Account acct = new Account(
                Name = acctName + String.valueOf(i),
                RecordTypeId = String.IsBlank(recordTypeId) ? BROKER_ACCOUNT_RECORD_TYPE_ID : recordTypeId
            );
            accts.add(acct);
        }
        if (isInsert) {
            insert accts;
        }
        return accts;
    }
    public static List<Contact> createContact(Boolean isInsert,Integer cnt, List<Account> accts) {
        return createContact(isInsert,cnt, accts,'');
    }
    public static List<Contact> createContact(Boolean isInsert,Integer cnt, List<Account> accts,String recordTypeId) {
        List<Contact> cons = new List<Contact>();
        for(Integer i=0;i<cnt;i++) {
            Contact c = new Contact(
                FirstName = 'first' + String.valueOf(i),
                LastName = 'Test' + String.valueOf(i),
                //AccountId = String.valueOf(accts[Integer.valueOf(Math.floor(Math.random() * accts.size()))].Id)
                AccountId = accts.get(i).Id
            );
            if(String.isNotBlank(recordTypeId)){
                c.RecordTypeId = recordTypeId;
            }
            cons.add(c);
        }
        if (isInsert) {
            insert  cons;
        }
        return  cons;
    }
    //User
    public static User createUser(Boolean isInsert, String userName, String profileType) {
        return createUser(isInsert, userName, profileType,null);
    }
    public static User createUser(Boolean isInsert, String userName, String profileType,String contactId) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileType LIMIT 1].Id;

        User u = new User();
        u.Username = userName.replaceAll(' ', '') + '@testmail.com';
        u.LastName = userName;
        u.Email = u.Username;
        u.Alias = u.Username.substring(0,7);
        u.TimeZoneSidKey = 'America/Chicago';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_GB';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = profileId;
        u.IsActive = true;
        if(contactId!= null){
            u.contactId = contactId;
        }
        if (isInsert) {
            insert u;
        }
        return u;
    }
    //Leads
    public static List<Lead> createLeads(Boolean isInsert,Integer cnt,String lastName,String emailAddress,String source,String recordTypeName){
        Id recordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<String> emlSplit =  emailAddress.split('@');
        List<Lead> lds = new List<Lead>();
        for(Integer i=0;i<cnt;i++) {
            String lstName =  lastName + ' ' + i;
            String emlAddress =  emlSplit[0] + string.valueOf(i) + '@' + emlSplit[1];
            String rand =String.Valueof(System.Math.Random()).Left(10);
            Lead ld = new Lead(
                            FirstName = 'John',
                            LastName = lstName,
                            Email = emlAddress,
                            Phone = rand ,
                            Street ='123 s. 1st St  #1',
                            City = 'Chandler',
                            State ='Arizona',
                            PostalCode ='85225',
                            Country = 'USA',
                            Company = 'test',
                            LeadSource = source,
                            recordTypeId = recordTypeId
                            );
            lds.add(ld);
        }
        if (isInsert) {
            insert lds;
        }
        return lds;
    }
    //Attachment
    public static ContentDocumentLink createAttachment(Boolean isInsert, String parentId){
        ContentVersion contentVer = new ContentVersion();
        contentVer.Title = 'Test';
        contentVer.PathOnClient = 'Test.jpg';
        contentVer.VersionData = Blob.valueOf('Testing');
        contentVer.IsMajorVersion = true;
        insert contentVer;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        if (isInsert == true) {
            insert cdl;
        }
        return cdl;
    }

    //Documents
    public static List<Document__c> createDocuments(Boolean isInsert,Integer cnt, List<List<String>> fieldsList,String recordTypeId) {
        List<Document__c> docs = new List<Document__c>();
        for(Integer i=0;i<cnt;i++) {
            List<String> fields =  fieldsList.get(i);
            Document__c doc = New Document__c(
                Account__c = fields.get(0)
            );
            docs.add(doc);
        }
        if (isInsert) {
            insert docs;
        }
        return docs;
    }

    //Licenses
    public static List<License__c> createLicenses(Boolean isInsert,Integer cnt, List<List<String>> fieldsList,String recordTypeId) {
        List<License__c> lics = new List<License__c>();
        for(Integer i=0;i<cnt;i++) {
            List<String> fields =  fieldsList.get(i);
            License__c lic = New License__c(
                RecordTypeId = String.IsBlank(recordTypeId) ? DEFAULT_LICENSE_RECORD_TYPE_ID : recordTypeId,
                Account__c = fields.get(0),
                Effective_Date__c = System.Today(),
                Expiration_Date__c =  System.Today().addDays(365),
                File_Identifier__c = String.valueof(System.Math.Random()),
                State__c = 'US-AZ',
                Country__c = 'US',
                License_Type__c = 'BID',
                ASAP_License_ID__c = fields.get(1)
            );
            lics.add(lic);
        }
        if (isInsert) {
            insert lics;
        }
        return lics;
    }
    //Service Events
    public static  List<Service_Event__c> createServiceEvents(Boolean isInsert,Integer cnt,String accountId,String eventType) {
        List<Service_Event__c> serviceEvents = new  List<Service_Event__c>();
        for(Integer i=0;i<cnt;i++) {
            Service_Event__c ServiceEvent = New Service_Event__c(               
                Event_Type__c = eventType,
                Account__c = accountId,
                Timestamp__c = System.Now()
            );
            serviceEvents.add(ServiceEvent);
        }
        if (isInsert) {
            insert serviceEvents;
        }
        return serviceEvents;
    }
    //Branches
    public static  List<Branch__c> createBranches(Boolean isInsert,Integer cnt,Integer branchId) {

        List<Branch__c> branches = new  List<Branch__c>();
        for(Integer i=0;i<cnt;i++) {
            Integer branchIdNum = i == 0 ? branchId : branchId + i;
            Branch__c branch = New Branch__c(               
                Branch_Name__c = 'test Branch ' + String.Valueof(branchIdNum),
                Branch_Number__c =  String.Valueof(branchIdNum),
                Phone__c = '01001010101'
            );
            branches.add(branch);
        }
        if (isInsert) {
            insert branches;
        }
        return branches;
    }

     //Integration Logs
     public static void createIntegrationLogs(Boolean isInsert,Integer cnt, String transactionType) {

        List<Integration_logs__c> logs = new  List<Integration_logs__c>();
        for(Integer i=0;i<cnt;i++) {
            Integration_logs__c log = New Integration_logs__c(               
                API_Type__c = 'Inbound',
                Endpoint_URL__c =  'www.test.com',
                IntegrationType__c = 'BrokerService',
                Transaction_Type__c = transactionType
            );
            logs.add(log);
        }
        if (isInsert) {
            insert logs;
        }
    }
    
    //Aggregates Success and Error logs and return logs concatenated.
    public static string AddSuccessAndErrorLogs(Map<String,List<Integration_logs__c>> successAndErrorLogs,List<Integration_logs__c> logs){
        String logsConcat = '';
        for(Integration_logs__c log:logs){
            string errMsg = 'Log: TransactionId:' + log.Transection_Id__c + ' Resp: ' + log.Response_Body__c + ' Type: ' + log.Transaction_Type__c + 
            ' SentTo: ' + log.Sent_To__c + ' Status: ' + log.Status__c +' Request: ' + log.Request_Body__c;
            logsConcat = String.isBlank(logsConcat) ? errMsg : logsConcat + errMsg;
            if(log.Status__c == 'Success'){
                List<Integration_logs__c> successLogs = successAndErrorLogs.get('Success');
                successLogs.add(log);
                successAndErrorLogs.put('Success',successLogs);
            }else{
                List<Integration_logs__c> errorLogs = successAndErrorLogs.get('Error');
                errorLogs.add(log);
                successAndErrorLogs.put('Error',errorLogs);
            }
        }
        System.debug('logsConcat: ' + logsConcat);
        return logsConcat;
    }
}