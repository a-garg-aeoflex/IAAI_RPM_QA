public class CallScriptCaseBuyerServiceClass {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String AccountID) {
        system.debug('ObjectName-->' + ObjectName);
        String BrorecordtypeId;
        String BuyrecordtypeId;
        if(ObjectName == 'Account'){
             BuyrecordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Buyer Account').getRecordTypeId();
             BrorecordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        }
        
        String searchKey = searchKeyWord + '%';
        system.debug('AccountID '+AccountID);
        List < sObject > returnList = new List < sObject > ();
        String sQuery;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(AccountID != null && AccountID <> ''){
            sQuery =  'select id, Name from ' +ObjectName + ' where AccountId =\''+AccountID+'\' AND  Name LIKE: searchKey order by createdDate DESC limit 5';
        }else if (ObjectName == 'Account'){
              sQuery =  'select id, Name from ' +ObjectName + ' where  ( RecordtypeId =\''+ BuyrecordtypeId+'\' OR RecordtypeId =\''+ BrorecordtypeId+'\') AND  Name LIKE: searchKey order by createdDate DESC limit 5';
        }else{
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        }
        system.debug('sQuery '+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    @AuraEnabled
    public static List<case>  getCaseList(String AccId, String ContactId){
        system.debug(AccId);
        List<Case> lstCases = new List<Case>();
        system.debug(ContactId);
        
        if(AccId <> Null && AccId <> ''){
            
             lstCases = [SELECT Id, CaseNumber,Subject, AccountId,Account.Name,ContactId, Contact.Name, Description 
                    FROM Case
                    WHERE AccountId =: AccId AND ContactId =:ContactId AND status != 'Closed'];
        }else{
            Contact objCon = new contact();
            objCon = [SELECT Id, AccountId From Contact where Id =: ContactId];
            system.debug('objCon'+objCon);
            AccId = objCon.AccountId;
            system.debug('objCon.AccountId '+objCon.AccountId);
            if(objCon.AccountId <> null){
                lstCases = [SELECT Id, CaseNumber,Subject, status, AccountId,Account.Name,ContactId, Contact.Name, Description 
                    FROM Case
                    WHERE AccountId =: AccId AND ContactId =:ContactId AND status != 'Closed' ];
            }
            
        }
       
        return lstCases;
    }
    @AuraEnabled
    public static string createLogaCall(string Subject, String Description, String Type, String CaseId) {
        Task objTaskRec = new Task();
        objTaskRec.status = 'completed';
        objTaskRec.type = Type;
        objTaskRec.WhatId = CaseId;
        objTaskRec.CallType = 'Outbound';
        objTaskRec.CallObject = 'shfusahfj-fdsbfh-fsdbhafb';
        objTaskRec.Priority = 'Normal';
        objTaskRec.Subject = Subject;
        objTaskRec.Description = Description;
        
        insert objTaskRec;

        return 'task is created';
    }
    @AuraEnabled
    public static List<String> getselectOptions(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        
        return lstPickvals;
    }
    @AuraEnabled
    public static List<String> getCaseRecordTypeId(){ 
       List<String> lstRdTyNameAndId = new List<String>() ; 
        for(RecordType obRdTy: [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'case' AND (DeveloperName = 'Buyer_Services' OR DeveloperName = 'Guest_Buyer')]){
            lstRdTyNameAndId.add(obRdTy.DeveloperName+','+obRdTy.Id);
        }
        system.debug(lstRdTyNameAndId);
        return lstRdTyNameAndId;
	}
}