/**
* @author LevDigital
* @date 2021
*
* @group Contact
* @group-content ../../ApexDocContent/ContentDocumentLink.htm
*
* @description ContentDocumentLinkTrigger is called from  ContentDocumentLinkHandler
*/
public with sharing class ContentDocumentLinkHandler extends TriggerHandler{

    private static final TriggerKillSwitch__mdt TRIGGER_KILL_SWITCH = TriggerKillSwitch__mdt.getInstance('ContentDocumentLink');
    private static Id BUYER_ACCT_RECORDTYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    private static Id BUYER_EMP_CONTACT_RECORDTYPE_ID =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Buyer_Employees').getRecordTypeId();              
    private static Map<Id,ContentDocumentLink> triggerOldMap;
    private static Map<Id,ContentDocumentLink> triggerNewMap;
    private static List<ContentDocumentLink> triggerNew;
    private static List<ContentDocumentLink> triggerOld;    

    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,ContentDocumentLink>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,ContentDocumentLink>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<ContentDocumentLink>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<ContentDocumentLink>) Trigger.new : null );
    }

    protected override void doBefore(){
        if(Trigger.IsInsert){
            if(TRIGGER_KILL_SWITCH.RunTrigger__c){
                //System.debug('before');
            }
        }
    }

    protected override void doAfter(){
        if(TRIGGER_KILL_SWITCH.RunTrigger__c){ 
            if(Trigger.IsInsert){
                uploadDocument();
            }
        }
    }   
    /*******************************************************************************************************
    * @description Filters out if License then send to LicenseService.updateLicense or
    *                       if Contact then send to Contact.UpdateEmployeeDocument,
    * If more than one license throw error
    * @return void
    */
    //Lev 7.29.2021 - change for success and failed outbound logging
    public static void uploadDocument(){
        Map<String,ContentDocumentLink> userLinks = new Map<String,ContentDocumentLink>();
        ContentDocumentLink licenseToUploadLink;
        ContentDocumentLink contactToUploadLink;
        ContentDocumentLink userLink;
        Integer docCount = 0; 
        String parentSObjectType;
        Map<Id,Contact> cons = new Map<Id,Contact>();
        try{
            System.debug('* ContentDocumentLinkHandler: ' + triggerNew.size() );
            Set<Id> linkedIds = new Set<Id>();
            Set<Id> allCDLIds = new Set<Id>();
            for(ContentDocumentLink docLink:triggerNew){
                Id parentId =  docLink.LinkedEntityId;
                String linkedId = String.valueOf(parentId);
                if(linkedId.left(3) !='005'){
                    linkedId = String.valueOf(parentId);
                    Schema.sObjectType parentType =parentId.getSObjectType();
                    if(String.Valueof(parentType) == 'Contact'){
                        parentSObjectType ='Contact';
                    }
                    if(linkedId!=null){
                        linkedIds.add(linkedId);
                    }
                }
            }
            if(!linkedIds.isEmpty() && parentSObjectType == 'Contact'){  
                //Check to see if contact RT is Buyer Employee AND the account RT is Buyer Account  
               cons = new Map<Id,Contact>([SELECT Id,RecordTypeId,Account.RecordTypeId,AccountId,Account.API_Buyer_Id__c FROM Contact WHERE Id IN:linkedIds
                                       And RecordTypeId =:BUYER_EMP_CONTACT_RECORDTYPE_ID  AND Account.RecordTypeId=:BUYER_ACCT_RECORDTYPE_ID ]);
                System.debug('Contact Size: ' + cons.size());
            }
                                    
            for(ContentDocumentLink cdl : [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN:linkedIds ] ){
                Id parentId = cdl.LinkedEntityId;
                String linkedId = String.valueOf(parentId);
                if(linkedId.left(3) !='005'){
                    allCDLIds.add(cdl.Id);
                }
            }  
            for(ContentDocumentLink docLink:triggerNew){
                Id parentId =  docLink.LinkedEntityId;
                String linkedId = String.valueOf(parentId);
                System.debug(' docLink: ' +  docLink);
                if(linkedId.left(3) !='005'){
                    Schema.sObjectType parentType =parentId.getSObjectType();
                    System.debug('ParentType :' + parentType);                                         
                    if(String.Valueof(parentType) == 'License__c' && licenseToUploadLink ==null){
                        licenseToUploadLink = docLink;
                    }else if(String.Valueof(parentType) == 'Contact' && contactToUploadLink ==null){ 
                        contactToUploadLink = docLink;
                    }                  
                }else if(linkedId.left(3) =='005'){
                    System.debug('user:'+ docLink);
                    userLinks.put(linkedId,docLink);
                }
            }  
 
            if(licenseToUploadLink !=null){    
                LicenseService licService = new LicenseService();
                licService.licenseId = String.valueOf(licenseToUploadLink.LinkedEntityId);
                if(allCDLIds.size() == 1){             
                    System.debug('Updating'); 
                    licService.licenseToUploadLink = licenseToUploadLink;
                    licService.userLink =userLinks.get(String.valueOf(licenseToUploadLink.LinkedEntityId));
                    System.debug('userLink: ' + licService.userLink);
                    licService.apiName ='UpdateLicense';
                    System.enqueueJob(licService);
                }else{
                    licService.apiName ='DeleteDoc';
                    licService.licenseLinkToDelete = licenseToUploadLink;
                    System.enqueueJob(licService);
                }
            }else if(contactToUploadLink !=null){  
                //Check to see if contact RT is Buyer Employee AND the account RT is Buyer Account                
                System.debug('Cons: ' + cons);
                String contactId = String.Valueof(contactToUploadLink.LinkedEntityId);
                System.debug('Contact: ' + contactId);
                if(cons.containsKey(contactId)){
                      
                    ContactService conService = new ContactService();
                    if(allCDLIds.size() == 1){            
                        System.debug('Updating');
                        conService.contactId = String.valueOf(contactToUploadLink.LinkedEntityId);
                        conService.contactToUploadLink = contactToUploadLink;
                        conService.userLink =userLinks.get(String.valueOf(contactToUploadLink.LinkedEntityId));
                        System.debug('userLink: ' + conService.userLink);
                        conService.apiName ='UpdateEmployeeDocument';
                        System.enqueueJob(conService);
                    }
                    else{
                        conService.apiName ='DeleteDoc';
                        conService.contactLinkToDelete = contactToUploadLink;
                        conService.contactRefContactLinkToDelete = cons.get(contactId);
                        System.enqueueJob( conService);
                    }
                }
            }
        }
        Catch(Exception e){
            String errorMessage = e.getlineNumber() + ' : ' + e.getMessage();
            System.debug('Error: ' +errorMessage);
			System.debug(errorMessage);
        }
    }
}