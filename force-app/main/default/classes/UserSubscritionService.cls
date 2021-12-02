public class UserSubscritionService {
    @AuraEnabled    
    Public static List<BuyerSubscrition__c> getBuyerSubcription(string AccountId){
        List<BuyerSubscrition__c> lstAllSubs = new List<BuyerSubscrition__c>();
        Account valAccRec = new Account();
        String strBuyerId;
        valAccRec = [SELECT Id, BI_ID__c FROM Account WHERE Id =:AccountId LIMIT 1];
        if(valAccRec <> null){
            if(valAccRec.BI_ID__c <> null && valAccRec.BI_ID__c.contains('-')){
                List<String> lstA= valAccRec.BI_ID__c.split('-');
                strBuyerId = lstA[1];
            }else{
                if(valAccRec.BI_ID__c <> null && valAccRec.BI_ID__c <> ''){
                    strBuyerId = valAccRec.BI_ID__c;
                }else{
                    return lstAllSubs;
                }
            }
            lstAllSubs = getUsersubcription(strBuyerId,valAccRec.Id );
        }else{
            
        }    
        return lstAllSubs;
    }
    public static list<User_Subcription__mdt> getSampleValue( ) {
        return  [Select Id, Accept__c,endPoint__c,Tenant__c,DeveloperName FROM User_Subcription__mdt  ];
    }
    public static List<BuyerSubscrition__c> getUsersubcription(string strBuyerId, String AccountId){
        List<BuyerSubscrition__c> BuyerSubscriptions = new List<BuyerSubscrition__c>();
        Http h = new Http();
        httpRequest request = new httpRequest();
        map<String,User_Subcription__mdt> mapOfOrgAndUserSubscription = new map<String,User_Subcription__mdt>();
        User_Subcription__mdt orgUserSubs = new User_Subcription__mdt();
        for(User_Subcription__mdt recUserSubsMeta:[Select Id, Accept__c,endPoint__c,Tenant__c,DeveloperName FROM User_Subcription__mdt]) {
            mapOfOrgAndUserSubscription.put(recUserSubsMeta.DeveloperName,recUserSubsMeta);
        }
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('sfdcBaseURL '+sfdcBaseURL);
        if(sfdcBaseURL.containsIgnoreCase('iaadev')) {
            orgUserSubs=mapOfOrgAndUserSubscription.get('DEV');
        }else if(sfdcBaseURL.containsIgnoreCase('qa')){
            orgUserSubs=mapOfOrgAndUserSubscription.get('DEV_QA');
        }else if(sfdcBaseURL.containsIgnoreCase('UAT')){
            orgUserSubs=mapOfOrgAndUserSubscription.get('UAT');
        }else if(sfdcBaseURL.containsIgnoreCase('iaaicsr.my.salesforce')){
            orgUserSubs=mapOfOrgAndUserSubscription.get('PROD');
        }
        Integration_logs__c recIntegrationLog = new Integration_logs__c();
        request.setMethod('GET');
        
        string endPoint = orgUserSubs.endPoint__c+strBuyerId;
        recIntegrationLog.IntegrationType__c = 'UserSubscription';
        recIntegrationLog.Endpoint_URL__c = endPoint;
        recIntegrationLog.Sent_From__c='SCRM';
        recIntegrationLog.Sent_To__c = 'BP';
        request.setEndpoint(endPoint);
        request.setHeader('Accept', orgUserSubs.Accept__c);
        request.setHeader('Tenant', orgUserSubs.Tenant__c);
        system.debug('req '+request.getHeader('Accept'));
        system.debug('req '+request.getHeader('Tenant'));
        system.debug('req '+request);
        HttpResponse res = h.send(request);
        system.debug('res '+res);
        system.debug('res '+res.getBody());
        if(res.getStatusCode() == 200){
            recIntegrationLog.Status__c = 'Success';
            string reponse = res.getBody();
            system.debug('reponse '+reponse);
            String result = (string)JSON.deserialize(res.getBody(), String.class);
            //system.debug('result '+result);
            recIntegrationLog.Response_Body__c = result;
            List<UserSubscritionWrapper>  lstUserSubcription;
            if(Test.isRunningTest()){
                system.debug('reponse == '+reponse);
                String reponse1 = (string)JSON.deserialize(res.getBody(), String.class);
                lstUserSubcription = (List<UserSubscritionWrapper>) System.JSON.deserialize(reponse, List<UserSubscritionWrapper>.class);
            }else{	
                lstUserSubcription = (List<UserSubscritionWrapper>) System.JSON.deserialize(result, List<UserSubscritionWrapper>.class);
            }
            system.debug('lstUserSubcription size '+lstUserSubcription.size());
            List<UserSubscritionWrapper> newLstUSW = new List<UserSubscritionWrapper>();
            if(!lstUserSubcription.isEmpty()){
                newLstUSW = checkBuyerSubscriptionExits(AccountId, lstUserSubcription);
                if(!newLstUSW.isEmpty()) {
                    createBuyerSubcription(newLstUSW,AccountId);
                }
                BuyerSubscriptions = getAllBuyerSubscription(AccountId);
                
            }else{
                
            }
        }else if(res.getStatusCode() == 400){
            recIntegrationLog.Status__c = 'Failed';
            
        }
        insert recIntegrationLog;
        return BuyerSubscriptions;
    }
    public static List<BuyerSubscrition__c> getAllBuyerSubscription(String AccountId){
        List<BuyerSubscrition__c> lstAllBuyerSubsc= new List<BuyerSubscrition__c> ();
        lstAllBuyerSubsc = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                            LastModifiedById, SystemModstamp, ccId__c, subscriptionId__c, SubscribedDate__c, 
                            UnSubscribedDate__c, ppId__c, PaymentMethods__c, Amount__c, paymentType__c, 
                            SubscriptionStatus__c, Page_Source__c, Device_Type__c, Fee_Type_Code__c, 
                            subscriptionCMSId__c, Buyer_Id__c, Account__c 
                            FROM BuyerSubscrition__c
                            WHERE Account__c =: AccountId];
        return lstAllBuyerSubsc; 
    }
    private static BuyerSubscrition__c createUpdateBuyerSubscrition(BuyerSubscrition__c tempBuyerSub, UserSubscritionWrapper resUserSub){
        tempBuyerSub.Name = resUserSub.subscriptionName;
        tempBuyerSub.SubscriptionStatus__c = resUserSub.subscriptionStatus;
        tempBuyerSub.subscriptionId__c = resUserSub.subscriptionId;
        tempBuyerSub.renewalDate__c = convertDate(resUserSub.renewalDate);
        tempBuyerSub.Amount__c = resUserSub.Payment.amount;
        tempBuyerSub.Buyer_Id__c = resUserSub.User.buyerId;
        tempBuyerSub.Device_Type__c = resUserSub.deviceType;
        tempBuyerSub.ccId__c = resUserSub.Payment.ccId;
        tempBuyerSub.Fee_Type_Code__c = resUserSub.fee_Type_Code;
        tempBuyerSub.Page_Source__c = resUserSub.pageSource;
        tempBuyerSub.PaymentMethods__c = resUserSub.Payment.paymentMethods;
        tempBuyerSub.paymentType__c = resUserSub.Payment.paymentType;
        tempBuyerSub.ppId__c = resUserSub.Payment.ppId;
        tempBuyerSub.SubscribedDate__c = convertDate(resUserSub.subscribedDate);
        tempBuyerSub.subscriptionCMSId__c = resUserSub.subscriptionCMSId;
        tempBuyerSub.UnSubscribedDate__c = convertDate(resUserSub.unSubscribedDate);
        
        
        
        return tempBuyerSub;
    }
    private static List<UserSubscritionWrapper> checkBuyerSubscriptionExits(String AccountId, List<UserSubscritionWrapper> lstUSW){
        List<UserSubscritionWrapper> newBuyerSuncriptionLst = new List<UserSubscritionWrapper>();
        List<BuyerSubscrition__c> lstBuySub = new List<BuyerSubscrition__c>();
        Map<String,BuyerSubscrition__c> mapsubscriptionIdBuyerSub = new Map<String,BuyerSubscrition__c>();
        lstBuySub = getAllBuyerSubscription(AccountId);
        List<BuyerSubscrition__c> updateBuyerSub = new List<BuyerSubscrition__c>(); 
        if(!lstBuySub.isEmpty()){
            for(BuyerSubscrition__c objBuSu:lstBuySub){
                mapsubscriptionIdBuyerSub.put(objBuSu.subscriptionId__c, objBuSu);
            }
            for(UserSubscritionWrapper objuswVal : lstUSW){
                if(mapsubscriptionIdBuyerSub.get(objuswVal.subscriptionId) <> null){
                    BuyerSubscrition__c objBSuVal = mapsubscriptionIdBuyerSub.get(objuswVal.subscriptionId);
                    objBSuVal = createUpdateBuyerSubscrition(objBSuVal,objuswVal);
                    updateBuyerSub.add(objBSuVal);
                }else{
                    newBuyerSuncriptionLst.add(objuswVal);
                } 
            }
            database.upsert(updateBuyerSub, true); 
        }else{
            newBuyerSuncriptionLst = lstUSW;
        }        
        return newBuyerSuncriptionLst;        
    }
    
    private static date convertDate(String dateTimeVal){
        
        if(String.isBlank(dateTimeVal) || String.isEmpty(dateTimeVal)){
            return null;
        }
        DateTime resultDateTime = DateTime.ValueofGmt(dateTimeVal.replace('T', ' '));
        system.debug(resultDateTime);
        date valDateTime =   resultDateTime.date();   
        
        return valDateTime;
    }
    public static void createBuyerSubcription(List<UserSubscritionWrapper> lstUSW, string AccountId ){
        try{
            List<BuyerSubscrition__c> lstBuyerSubscrition = new List<BuyerSubscrition__c>();
            for(UserSubscritionWrapper resUserSub:lstUSW){
                BuyerSubscrition__c tempBuyerSub = new BuyerSubscrition__c();
                tempBuyerSub = createUpdateBuyerSubscrition(tempBuyerSub,resUserSub);
                tempBuyerSub.Account__c = AccountId;
                lstBuyerSubscrition.add(tempBuyerSub);                
            }
            database.upsert(lstBuyerSubscrition, true); 
        }catch(exception ex){
            system.debug('Error Occured: '+ex.getMessage() +' Line no : '+ex.getLineNumber());            
        }        
    }
    
}