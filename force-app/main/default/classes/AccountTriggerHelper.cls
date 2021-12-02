/*
* @author LevDigital
* @date 2021
*
* @group Account
* @group-content ../../ApexDocContent/Account__c.htm
*
* @description AccountTriggerHelper is called from AccountTrigger
*/
public with sharing class AccountTriggerHelper extends TriggerHandler {
    @TestVisible
    public static Boolean accountFirstRun = true;
    @TestVisible
    public static Boolean byPassIntegration = false;
    private static String Account_OBJ ='Account' ;
    private static Map<Id,Account> triggerOldMap;
    private static Map<Id,Account> triggerNewMap;
    private static List<Account> triggerNew;
    private static List<Account> triggerOld;
    private static final TriggerKillSwitch__mdt TRIGGER_KILL_SWITCH = TriggerKillSwitch__mdt.getInstance('Account');
    private static final String PENDING_API_STATUS = 'Pending - Refresh to view';

    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,Account>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,Account>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<Account>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<Account>) Trigger.new : null );
    }
    
    protected override void doBefore(){ 
       
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){     
            /*if (Trigger.isInsert) {}
            else
            */
            if (Trigger.isUpdate) {
                //Moved by Lev from Account Trigger to Helper class
                Map<Id, Account> rejectedStatements = new Map<Id, Account>{};

                for(Account objAccount: triggerNew){
            
                    /*      Get the old object record, and check if the approval status field has been updated to rejected. If so, put it in a map
                            so we only have to use 1 SOQL query to do all checks.
                    */
            
                    Account oldobjAccount = triggerOldMap.get(objAccount.Id);   
                    if (oldobjAccount.Approval_Status__c != 'Rejected' && objAccount.Approval_Status__c == 'Rejected'){
                        rejectedStatements.put(objAccount.Id, objAccount); 
                    }
            
                }
                system.debug('rejectedStatements '+rejectedStatements.size() );
                if (!rejectedStatements.isEmpty()) {
                
                    List<Id> processInstanceIds = new List<Id>{};
            
                    for (Account objAccount : [SELECT (SELECT ID
                                                FROM ProcessInstances
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1)
                                        FROM Account
                                        WHERE ID IN :rejectedStatements.keySet()])
                {
                    processInstanceIds.add(objAccount.ProcessInstances[0].Id);
            
                }
                system.debug('processInstanceIds '+processInstanceIds.size());
                for (ProcessInstance objPrIns : [SELECT TargetObjectId,
                                            (SELECT Id, StepStatus, Comments
                                                FROM Steps
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1 )
                                        FROM ProcessInstance
                                        WHERE Id IN :processInstanceIds
                                        ORDER BY CreatedDate DESC])  {      
                                        system.debug('objPrIns.Steps[0].Comments '+objPrIns.Steps[0].Comments );            
                    if ((objPrIns.Steps[0].Comments == null || objPrIns.Steps[0].Comments.trim().length() == 0)){
                        rejectedStatements.get(objPrIns.TargetObjectId).addError('Operation Cancelled: Please provide a rejection reason!');
                    }
                } 
            }
            }
        }
    }
    
    protected override void doAfter(){
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){ 
            if (Trigger.isInsert){
                
            }
            else if (Trigger.isUpdate){            
                //using static variable so that we don't get max depth trigger error and keep updating same account
                if (accountFirstRun) {
                    accountFirstRun = false;
                    getBSOAPIs();
                }                
            }
        }
    }
    /*******************************************************************************************************
    * @description checks to see if criteria is met for buyer account BSO API Callouts
    * @return void
    */
    public static void getBSOAPIs(){
        Id buyerAccountRecordTypeId=  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
        User u = [SELECT Id,Username,Profile.Name,Profile.Id From User WHERE Id =: userinfo.getUserId()][0];
        if(u.Profile != null){
            if(String.isNotBlank(u.Profile.Name)){
                if(u.Profile.Name != 'Integration User' || (u.Profile.Name == 'Integration User' && byPassIntegration == true)){
                    System.debug('*running getBSOAPIs trigger: ' + triggerNew.size());
                    //only process one from the ui and don't do multiple callouts for bulkification
                    if(triggerNew.size()==1 ){
                      
                        Account acct = triggerNew[0];
                        System.debug('*Starting BSO record TypeId: ' + acct.RecordTypeId + ' buyer account record typeId: ' + buyerAccountRecordTypeId);
                        Boolean licStatus = false;
                        Boolean docStatus = false;
                        Boolean lexisNexusStatus = false;
                        Boolean unlinkAAMembership = false;
                        Boolean notesStatus = false;
                        List<String> acctApiNames = new List<String>();

                        //Loop through the config for Update Buyer API and if any of the fields in the account have changed
                        // then fire off of the update buyer api
                        List<OutboundField__mdt> outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c,SFObject__c
                                                                                FROM OutboundField__mdt WHERE Type__c ='UpdateBuyer' AND Value__c !=null];
                        for(OutboundField__mdt outboundField:outboundFields){
                            String sfFieldName = String.valueOf(outboundField.Value__c);                           
                            if(acct.get(sfFieldName)!=triggerOldMap.get(acct.Id).get(sfFieldName)){
                                 System.debug('triggerHelper:UpdateBuyer:sfFieldName: ' + sfFieldName);
                                acctApiNames.add('UpdateBuyer');
                                break;
                            }
                        }
                        if(String.isNotBlank(String.valueOf(acct.API_Buyer_Id__c)) && acct.RecordTypeId == buyerAccountRecordTypeId
                            && acct.Get_License_Status__c == 'Request' && acct.Get_License_Status__c != triggerOldMap.get(acct.Id).Get_License_Status__c){
                            System.debug('*Account getBSOAPIs:getBuyerLicenses: ' + triggerNew.size());
                            licStatus = true;
                            getBuyerLicenses(acct);  
                        }
                        if(String.isNotBlank(String.valueOf(acct.API_Buyer_Id__c)) && acct.RecordTypeId == buyerAccountRecordTypeId
                            && acct.Get_Document_Status__c == 'Request' && acct.Get_Document_Status__c != triggerOldMap.get(acct.Id).Get_Document_Status__c){
                            System.debug('*Account getBSOAPIs:getBuyerDocuments ' + triggerNew.size());
                            docStatus = true;    
                            getBuyerDocuments(acct);                        
                        }
                        if(String.isNotBlank(String.valueOf(acct.API_Buyer_Id__c)) && acct.RecordTypeId == buyerAccountRecordTypeId
                            && acct.Get_LexisNexis_Result__c == 'Request' && acct.Get_LexisNexis_Result__c != triggerOldMap.get(acct.Id).Get_LexisNexis_Result__c){
                            System.debug('*Account getBSOAPIs:Get_LexisNexis_Result ' + triggerNew.size());
                            lexisNexusStatus = true; 
                            acctApiNames.add('GetLexisNexisCheck');                          
                        }             
                        System.debug('before check...');
                        if(String.isNotBlank(String.valueOf(acct.API_Buyer_Id__c)) && acct.RecordTypeId == buyerAccountRecordTypeId
                            && acct.Unlink_AA_Membership__c == 'Request' && acct.Unlink_AA_Membership__c != triggerOldMap.get(acct.Id).Unlink_AA_Membership__c){
                                System.debug('after check...');
                                System.debug('*Account getBSOAPIs:unlink aa membership ' + triggerNew.size());
                            unlinkAAMembership = true;    
                            unlinkAAMembership(acct);
                        }           
                        if(!acctApiNames.isEmpty()){
                            System.debug('acctApiNames: ' +acctApiNames);
                            getAccountAPIs(acct,acctApiNames);
                        }
                        if(String.isNotBlank(String.valueOf(acct.API_Buyer_Id__c)) && acct.RecordTypeId == buyerAccountRecordTypeId
                            && acct.Get_Note_Status__c == 'Request' && acct.Get_Note_Status__c != triggerOldMap.get(acct.Id).Get_Note_Status__c){
                            System.debug('*Account getBSOAPIs:Get_Note_Status ' + triggerNew.size());
                            notesStatus = true; 
                            //Lev 7.29.2021 - Moved Buyer Notes to ASAP Notes Service
                            getBuyerNotes(acct);
                        }
                        if(licStatus == true || docStatus == true || lexisNexusStatus == true|| notesStatus == true || unlinkAAMembership){
                            System.debug('Status:');
                            Account updateAcct = [SELECT Id,Get_License_Status__c,Get_Document_Status__c FROM Account WHERE Id=:acct.Id];
                            if(licStatus == true){
                                updateAcct.Get_License_Status__c = PENDING_API_STATUS;
                            }
                            if(docStatus == true){
                                updateAcct.Get_Document_Status__c = PENDING_API_STATUS;
                            }
                            if(lexisNexusStatus == true){
                                updateAcct.Get_LexisNexis_Result__c = PENDING_API_STATUS;
                            }
                            if(notesStatus == true){
                                updateAcct.Get_Note_Status__c = PENDING_API_STATUS;
                            }
                            if(unlinkAAMembership == true){
                                updateAcct.Unlink_AA_Membership__c = PENDING_API_STATUS;
                            }
                            update updateAcct;
                        }
                    }  
                }  
            }  
            else{
                System.debug('Could not get profile name so not running trigger');
            }
        }else{
            System.debug('Could not get profile so not running trigger');
        }  
    }
    /*******************************************************************************************************
    * @description - Invokes LicenseService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void getBuyerLicenses(Account acct){
        LicenseService licService = new LicenseService();
        licService.buyerId = String.valueOf(acct.API_Buyer_Id__c);
        licService.acct = acct;
        licService.apiName ='GetBuyerLicenses';
        System.enqueueJob(licService);
    }
    /*******************************************************************************************************
    * @description - Invokes DocumentService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void getBuyerDocuments(Account acct){
        DocumentService docService = new DocumentService();
        docService.buyerId = String.valueOf(acct.API_Buyer_Id__c);
        docService.acctId = acct.Id;
        docService.apiName ='GetBuyerDocuments';
        System.enqueueJob(docService);
        
    }
    /*******************************************************************************************************
    * @description - Invokes AccountService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void getAccountAPIs(Account acct,List<String> apiNames){
        AccountService acctService = new AccountService(apiNames);
        acctService.buyerId = String.valueOf(acct.API_Buyer_Id__c);
        acctService.acct = acct;
        System.enqueueJob(acctService);        
    }
    /*******************************************************************************************************
    * @description - Invokes ASAPNoteService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void getBuyerNotes(Account acct){
        ASAPNoteService asapService = new ASAPNoteService(new List<String>{'GetBuyerNotes'});
        asapService.buyerId = String.valueOf(acct.API_Buyer_Id__c);
        asapService.acct = acct;
        System.enqueueJob(asapService);
    }
    /*******************************************************************************************************
    * @description - Invokes DocumentService Queueable
    * @param acct - Triggger[0] 
    * @return void
    */
    public static void unlinkAAMembership(Account acct){
        UnlinkService service = new UnlinkService();
        service.buyerId = String.valueOf(acct.API_Buyer_Id__c);
        service.acct = acct;
        System.enqueueJob(service);
        
    }
}