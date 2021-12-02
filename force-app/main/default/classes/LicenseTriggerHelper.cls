public class LicenseTriggerHelper extends TriggerHandler {
    // 
    //private static String BUYER_FEEDBACK_RT ='Buyer Feedback' ;
    @TestVisible
    public static Boolean licenseFirstRun = true;
    private static String Lincese_OBJ ='License__c' ;
    private static Map<Id,License__c> triggerOldMap;
    private static Map<Id,License__c> triggerNewMap;
    private static List<License__c> triggerNew;
    private static List<License__c> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;
    private static final TriggerKillSwitch__mdt TRIGGER_KILL_SWITCH = TriggerKillSwitch__mdt.getInstance('License');

    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,License__c>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,License__c>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<License__c>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<License__c>) Trigger.new : null );
    }
    
    protected override void doBefore(){
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){ 
            if (Trigger.isInsert) {
                populateAccountOnLicenseRecds(triggerNew);
            
            }else if (Trigger.isUpdate) {
                populateAccountOnLicenseRecds(triggerNew);
            }
        }
    }
    
    protected override void doAfter(){
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){ 
            if (Trigger.isInsert){
                uploadOrUpdateNewLicense();
            }else if (Trigger.isUpdate) 
            {
                uploadOrUpdateNewLicense();
                
            } 
        }       
    }

    //Added by Lev
    public static void uploadOrUpdateNewLicense(){
        //only process one from the ui and don't do multiple callouts for bulkification
        System.debug('triggerNew.size: ' + triggerNew.size());
        if(triggerNew.size()==1 && licenseFirstRun == true){
            System.debug('licenseFirstRun: ' + licenseFirstRun);
            
            licenseFirstRun= false;      
            Id buyerAccountRecordTypeId=  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
            License__c lic = triggerNew[0];
            System.debug('acct: ' + lic.Account__c);
            //Process only if related account is buyer account record type
            if(String.isNotBlank(String.valueOf(lic.Account__c)) && buyerAccountRecordTypeId !=null){
                List<Account> accts = [SELECT Id,RecordTypeID FROM Account WHERE Id =: lic.Account__c AND RecordTypeID =: buyerAccountRecordTypeId LIMIT 1];
                if(!accts.isEmpty()){ 
                    System.debug('Trigger.isInsert: ' + Trigger.isInsert);
                    //If is insert and is not being inserted by the api, do callout to send the upload license api
                    if (Trigger.isInsert){
                        System.debug('lic.By_API__c: ' + lic.By_API__c);
                        if(lic.By_API__c == false){
                            LicenseService licService = new LicenseService();
                            licService.licenseId = String.valueOf(lic.Id); 
                            licService.acctId =  String.valueOf(lic.Account__c);              
                            licService.apiName ='UploadLicense';
                            System.debug('licenseTriggerHeleper:licService.apiName: '  + licService.apiName);
                            System.enqueueJob(licService);
                        }
                    }//else If is update, do callout to send the upload license
                    else if (Trigger.isUpdate){
                        System.debug('old asap:' + String.Valueof(triggerOldMap.get(lic.Id).ASAP_License_Id__c));
                        if(String.IsNotBlank(String.Valueof(triggerOldMap.get(lic.Id).ASAP_License_Id__c))){
                           
                        //if( String.IsNotBlank(String.Valueof(trigger.oldMap.get(lic.Id)].ASAP_License_Id__c)){
                            LicenseService licService = new LicenseService();
                            licService.licenseId = String.valueOf(lic.Id);    
                            licService.acctId =  String.valueOf(lic.Account__c);               
                            licService.apiName ='UpdateLicense';
                            System.debug('licenseTriggerHeleper:licService.apiName: '  + licService.apiName);
                            licService.actionType = 'Update';
                            System.enqueueJob(licService);
                        }
                    }
                }                
            }
        }
    }
    public static List<License__c> populateAccountOnLicenseRecdsBatch(List<License__c> lstLicenses){
        Map<String, Account> mapOfBuyerIdToAccount = new Map<String, Account>();
        set<String> lstOFBuyerId = new set<String>();
        set<String> lstOFBuyerIdWithBuyPrefix = new set<String>();
        List<License__c> lstLicensesUpd = new List<License__c>();
       // List<>
        for(License__c objLic:lstLicenses){
            if(!String.isBlank(objLic.Buyer_ID__c) && !objLic.Buyer_ID__c.startsWithIgnoreCase('BUY-')){
                lstOFBuyerId.add(objLic.Buyer_ID__c);
                lstOFBuyerIdWithBuyPrefix.add('BUY-'+objLic.Buyer_ID__c);
            }else if(!String.isBlank(objLic.Buyer_ID__c)&& objLic.Buyer_ID__c.startsWithIgnoreCase('BUY-')){
                List<String> strBuy = objLic.Buyer_ID__c.split('BUY-');
                lstOFBuyerId.add(strBuy[1].trim());
            }
        }
		lstOFBuyerIdWithBuyPrefix.addAll(lstOFBuyerId);      
        for(Account objAcc:[SELECT Id, BI_Id__c, Name FROM Account WHERE BI_Id__c IN:lstOFBuyerIdWithBuyPrefix OR BI_Id__c IN:lstOFBuyerId]){
            
            mapOfBuyerIdToAccount.put(objAcc.BI_Id__c,objAcc);
            system.debug(mapOfBuyerIdToAccount);
        }
        for(License__c objLic:lstLicenses){
            if(String.IsNotBlank(String.valueOf(objLic.Buyer_ID__c))){
                if(objLic.Buyer_ID__c.startsWithIgnoreCase('BUY-')){
                    if(mapOfBuyerIdToAccount.get(objLic.Buyer_ID__c) <> null){
                        objLic.Account__c = mapOfBuyerIdToAccount.get(objLic.Buyer_ID__c).Id;
                    }else{
                        List<String> strBuy = objLic.Buyer_ID__c.split('BUY-');
                        string BuyerId =strBuy[1];
                        system.debug('strBuy '+strBuy[1]);
                        if(mapOfBuyerIdToAccount.get(BuyerId) <> null){
                            objLic.Account__c = mapOfBuyerIdToAccount.get(BuyerId).Id;
                        }
                        
                    }
                    
                }else if(mapOfBuyerIdToAccount.get('BUY-'+objLic.Buyer_ID__c) <> null){
                    objLic.Account__c = mapOfBuyerIdToAccount.get('BUY-'+objLic.Buyer_ID__c).Id;
                }else if(mapOfBuyerIdToAccount.get(objLic.Buyer_ID__c) <> null){
                    objLic.Account__c = mapOfBuyerIdToAccount.get(objLic.Buyer_ID__c).Id;
                }
            }
                  
        } system.debug('mapOfBuyerIdToAccount '+mapOfBuyerIdToAccount); return lstLicenses;     
    }
    public static void populateAccountOnLicenseRecds(List<License__c> lstLicenses){
        lstLicenses = populateAccountOnLicenseRecdsBatch(lstLicenses); 
    }
    
}