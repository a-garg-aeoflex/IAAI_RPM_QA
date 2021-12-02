/**
* @author LevDigital
* @date 2020
*
* @group Contact
* @group-content ../../ApexDocContent/Contact.htm
*
* @description ContactTriggerDispatcher on Contact which calls the ContactServices
*/
public with sharing class ContactTriggerDispatcher {
    @TestVisible
    public static Boolean ContactFirstRun = true;
    @TestVisible
    public static Id BUYER_ACCT_RECORDTYPE_ID =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Buyer_Account').getRecordTypeId();
    @TestVisible
    public static Id BUYER_EMP_CONTACT_RECORDTYPE_ID =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Buyer_Employees').getRecordTypeId();              
    @TestVisible
    public static Boolean byPassIntegration = false;
    /*******************************************************************************************************
    * @description Returns void
    * @param triggerNew List of Contacts that were inserted
    * @param triggerNew Map of Ids and List of Contacts that were inserted
    * @return Returns void
    */
	public static void afterInsert(List<Contact> triggerNew, Map<Id, Contact> newMap){
        Map<Id,Contact> filteredContacts = filterContactsInserted(triggerNew); 
        if(!filteredContacts.isEmpty()){
           ContactTriggerServices.processFilteredContacts(filteredContacts);
        }
    }
    /*******************************************************************************************************
    * @description Returns void
    * @param triggerNew List of Contact that were updated
    * @param newMap Map of ContactIds and Contact that were updated
    * @param triggerOld List of the old versions of the Contact records.
    * @param oldMap Map of ContactIds and old versions of the Contact records.
    * @return Returns void
    */
    public static void afterUpdate(List<Contact> triggerNew, List<Contact> triggerOld, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        if (ContactFirstRun) {
            System.debug('ContactFirstRun: ' +ContactFirstRun);
            ContactFirstRun = false;            
            Map<Id,Contact> filteredContacts = filterContactsAfterUpdate(triggerNew,oldMap); 
            if(!filteredContacts.isEmpty()){
                if(filteredContacts.size() ==1 ){
                    System.debug('filteredContacts:' + filteredContacts.size());
                    Contact con;
                    String contactId;
                    for(Id conId:filteredContacts.keySet()){
                        con = filteredContacts.get(conId);
                        contactId = conId;
                        break;
                    }
                    if(String.isNotBlank(contactId)){
                        ContactService conService = new ContactService();
                        conService.contactId = contactId;
                        conService.con = con;
                        conService.apiNames.add('UpdateBuyerEmployee');
                        System.enqueueJob(conService);
                    }
                }
            }
        }
    }
    
	/*******************************************************************************************************
    * @description filters Contacts Inserted
    * @param triggerNew List of Contacts that were updated
    * @param oldMap Map of Ids and old versions of the Contact records.
    * @return Returns Map<Id,Contact>
    */
    private static Map<Id,Contact> filterContactsInserted(List<Contact> triggerNew) {
        Map<Id,Contact> filteredContacts = new Map<Id,Contact>();
        for(Contact con:triggerNew){
            if(con.Is_Owner__c !=false){
                filteredContacts.put(con.Id,con);
            }
		}
        return filteredContacts;
    }
    /*******************************************************************************************************
    * @description filters Contacts Inserted After Update
    * @param triggerNew List of Contacts that were updated
    * @param oldMap Map of Ids and old versions of the Contact records.
    * @return Returns Map<Id,Contact>
    */
    private static Map<Id,Contact> filterContactsAfterUpdate(List<Contact> triggerNew, Map<Id, Contact> oldMap) {
        Map<Id,Contact> filteredContacts = new Map<Id,Contact>();
        User u = [SELECT Id,Username,Profile.Name,Profile.Id From User WHERE Id =: userinfo.getUserId()][0];
        if(u.Profile != null){
            if(String.isNotBlank(u.Profile.Name)){
                if(u.Profile.Name != 'Integration User' || (u.Profile.Name == 'Integration User' && byPassIntegration == true)){
                    //Limiting to trigger size is 1 for if a update have been made through UI on the contact detail page for bulkfication
                    if(triggerNew.size()==1 ){
                        System.debug('*running getBSOAPIs contactTrigger');  
                        Contact con = triggerNew[0];
                        //Check to see if contact RT is Buyer Employee AND the account RT is Buyer Account  
                        List<Contact> retrievedContact = [SELECT Id,RecordTypeId,Account.RecordTypeId FROM Contact WHERE Id =: con.Id
                                                                        And RecordTypeId =:BUYER_EMP_CONTACT_RECORDTYPE_ID  AND Account.RecordTypeId=:BUYER_ACCT_RECORDTYPE_ID ];
                        if(!retrievedContact.isEmpty()){
                            System.debug('*retrievedContact: ' + retrievedContact[0].Id);  
                            //Loop through the config for Update Buyer API and if any of the fields in the account have changed
                            // then fire off of the update buyer api
                            List<OutboundField__mdt> outboundFields = [SELECT Id,Label,Value__c,DataType__c,DefaultValue__c,Type__c,APIType__c,SFObject__c
                            FROM OutboundField__mdt WHERE Type__c ='UpdateBuyerEmployee' AND Value__c !=null];
                            for(OutboundField__mdt outboundField:outboundFields){
                                String sfFieldName = String.valueOf(outboundField.Value__c);
                                //System.debug('triggerHelper:sfFieldName: ' + sfFieldName);
                                if(con.get(sfFieldName)!=oldMap.get(con.Id).get(sfFieldName)){
                                    filteredContacts.put(con.Id,con);
                                    break;
                                }
                            }
                        }                                                
                    }
                }
            }
        }
        return filteredContacts;
    }
    
	
	
}