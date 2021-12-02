public class BrokerBidderReviewClass {
    public class ResponseCreateBrokerAPI {        
        public String CreatedTime {get;set;} 
        public String SentFrom {get;set;} 
        public String SentTo {get;set;} 
        public String TransactionID {get;set;} 
        public String TransactionType {get;set;} 
        public String Version {get;set;} 
        public Result Result {get;set;} 
    }
    public class Result {
        @AuraEnabled
        public String ErrorCode {get;set;} 
        @AuraEnabled
        public String ErrorDescription {get;set;} 
        @AuraEnabled
        public string NewBuyerID {get;set;} 
    }
    
    public class AccountContact{
        @AuraEnabled
        public Account objAccount{get;set;}
        @AuraEnabled
        public List<Contact> lstCon{get;set;}
        
        public AccountContact(Account Acc, List<Contact> lsCon){
            objAccount = new Account();
            lstCon = new List<Contact>();
            objAccount = Acc;            
            lsCon =lsCon;
        }
        public AccountContact(){
            objAccount = new Account();
            lstCon = new List<Contact>();
            
        }
    }
    @AuraEnabled
    public static AccountContact fetchAccountCon(String OppId) {
        List<Contact> lstContacts = new List<Contact>();
        Id AccId;
        Opportunity ObjOpp = [SELECT Id, AccountId 
                              FROM opportunity 
                              WHERE id =:OppId];
        AccId = ObjOpp.AccountId;
        Account objAcc = new Account();
        objAcc = [SELECT Id, Name, BI_Id__c, Is_Broker_Created__c, Buyer_Status__c 
                  FROM Account
                  WHERE Id =: AccId Limit 1];
        
        lstContacts = [SELECT Id, Name,AccountId, AC_User_ID__c,Buyer_Employee_ID__c,Buyer_ID__c,Status_Code__c, AccountBuyerStatus__c 
                       FROM Contact 
                       WHERE AccountId =: AccId]; 
        
        system.debug(objAcc);
        system.debug(objAcc.Id);
        AccountContact objAccountContact = new AccountContact();
        objAccountContact.objAccount = objAcc;
        objAccountContact.lstCon = lstContacts;
        system.debug(objAccountContact.objAccount);
        system.debug(objAccountContact.lstCon);
        return objAccountContact;
    }
    
    public class CreateBrokerWrapper {
        
        public String CreatedTime;
        public String SentFrom;
        public String SentTo;
        public String TransactionID;
        public String TransactionType;
        public String Version;
        public Boolean AddBrokerFee;
        public List<Integer> EmployeeIDs;
        public Integer LicenseBuyerID;
        public CreateBrokerWrapper(){
            EmployeeIDs = new List<Integer>();
        }
        
        
    }
    public static  String getTansactionId(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    
    
    @AuraEnabled
    public static Result  creakeBrokerService(Boolean AddBrokerFee, String LicenseBuyerID, List<Integer> EmployeeIDs, String OppId) {
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        
        DateTime dt = DateTime.now();
        String dateString = dt.format(dateFormat);
        System.debug(dateString); 
        CreateBrokerWrapper objCreateBroker = New CreateBrokerWrapper();
        objCreateBroker.CreatedTime = dateString;
        objCreateBroker.SentFrom = 'SCRM';
        objCreateBroker.SentTo = 'IAA';
        objCreateBroker.TransactionID = getTansactionId();
        objCreateBroker.TransactionType = 'BROKER_CREATE';
        objCreateBroker.Version = 'V1.0';
        objCreateBroker.AddBrokerFee = AddBrokerFee;
        objCreateBroker.LicenseBuyerID = integer.valueOf(LicenseBuyerID) ;
        //String BuyerId = 
        objCreateBroker.EmployeeIDs = EmployeeIDs;
        
        system.debug(JSON.serialize(objCreateBroker)) ;
        Integration_logs__c objIntLogs = new Integration_logs__c();
        
        system.debug('objCreateBroker '+objCreateBroker);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String sfdcBaseURLBr = URL.getSalesforceBaseUrl().toExternalForm();
        BrokerBidderReviewClass__mdt objBroBidREvCls = new BrokerBidderReviewClass__mdt();
        if(sfdcBaseURLBr.containsIgnoreCase('iaaicsr.my.salesforce.com')){
            objBroBidREvCls = [SELECT id, DeveloperName, AuthKey__c,EndPoint_URL__c from BrokerBidderReviewClass__mdt where DeveloperName = 'Production'];
        }else if(sfdcBaseURLBr.containsIgnoreCase('UAT')){
            objBroBidREvCls = [SELECT id, DeveloperName, AuthKey__c,EndPoint_URL__c from BrokerBidderReviewClass__mdt where DeveloperName = 'UAT'];
        }else if(sfdcBaseURLBr.containsIgnoreCase('QA')){
             objBroBidREvCls = [SELECT id, DeveloperName, AuthKey__c,EndPoint_URL__c from BrokerBidderReviewClass__mdt where DeveloperName = 'QA'];
        }
        string endPointUri = objBroBidREvCls.EndPoint_URL__c;
        system.debug('endPointUri : '+endPointUri);
        req.setEndpoint(endPointUri);
        map<String,BrokerBidderReviewClass__mdt> mapOfOrgAndUserSubscription = new map<String,BrokerBidderReviewClass__mdt>();
       
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');  
        String authkey = objBroBidREvCls.AuthKey__c;
        system.debug('Authorization '+objBroBidREvCls.AuthKey__c);
        req.setHeader('Authorization', authkey);
        req.setTimeout(60000);
        system.debug('--- --->');
        req.setCompressed(false);
        system.debug('--- -1->');
        req.setBody(JSON.serialize(objCreateBroker));
        objIntLogs.Request_Body__c = req.getBody();
        system.debug('--- -2->');
        try {
            system.debug('req '+req);
            res = http.send(req);
            System.debug('res.getBody()'+res.getBody());
            objIntLogs.Response_Body__c = res.getBody();           
            ResponseCreateBrokerAPI objRCB = (ResponseCreateBrokerAPI) JSON.deserializeStrict(res.getBody(), ResponseCreateBrokerAPI.class);
            objIntLogs.Status__c = 'Failed'; 
            objIntLogs.Transection_Id__c = objRCB.TransactionID;
            objIntLogs.Transaction_Type__c = objRCB.TransactionType;
            objIntLogs.Sent_To__c = objRCB.SentTo;
			objIntLogs.Sent_From__c =  objRCB.SentFrom;
            
            
            if( res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK' || res.getStatus() == '200'){
                
                system.debug(objRCB.Result); 
                Result objRes = objRCB.Result;
                
                if(objRes.ErrorCode <> null && objRes.ErrorCode == '000'){
                    objIntLogs.Status__c = 'Success';
                    system.debug(objRes.ErrorCode);
                    system.debug(objRes.ErrorDescription);
                    system.debug(objRes.NewBuyerID);
                    Opportunity objOpp = new Opportunity(Id=OppId);
                    if(objRes.NewBuyerID <> Null){
                        objOpp.Broker_Id__c = 'BRK-'+objRes.NewBuyerID ;
                        update objOpp;
                        String preFixBuyerId = 'BUY-'+LicenseBuyerID;
                        List<Account> lstAccount = [SELECT Id, Name, BI_Id__c, Is_Broker_Created__c 
                                                    FROM Account
                                                    WHERE BI_Id__c =: LicenseBuyerID OR BI_Id__c =: preFixBuyerId 
                                                    Limit 1];
                        system.debug('lstAccount');
                        if(!lstAccount.isEmpty()){
                            Account objA = lstAccount[0];
                            objA.Is_Broker_Created__c = true;
                            update objA;
                        }
                    }    
                }else if(objRes.ErrorCode == null || objRes.ErrorCode == '' ){
                   
                    Result objResError = new Result();
                    objResError.ErrorCode = '400';
                    objResError.ErrorDescription = 'Some Error Occured please contact system admin';
                    objResError.NewBuyerID = '';
                    system.debug(objRes.ErrorCode);
                    system.debug(objRes.ErrorDescription);
                    insert objIntLogs;
                    return objResError;
                    
                }
                system.debug('got it');
                insert objIntLogs;
                return objRes;
                
            }else{
               
                Result objResError = new Result();
                objResError.ErrorCode = '400';
                objResError.ErrorDescription = 'Some Error Occured please contact system admin';
                objResError.NewBuyerID = '';
                insert objIntLogs;
                return objResError;
            }
        } catch(System.CalloutException e) {
             objIntLogs.Status__c ='Failed';
            insert objIntLogs;
            System.debug('Callout error: '+ e);
        }catch(exception ex){
             objIntLogs.Status__c ='Failed';
            insert objIntLogs;
            system.debug('ex.getMessage() '+ex.getMessage());
        }
        BrokerBidderReviewClass.Result objRCB1 = new BrokerBidderReviewClass.Result();
        objRCB1.ErrorCode = '400';
        objRCB1.ErrorDescription = 'Some Error Occured please contact system admin';
        objRCB1.NewBuyerID = '';
         objIntLogs.Status__c ='Failed';
        insert objIntLogs;
        
        return objRCB1;
    }
    
}