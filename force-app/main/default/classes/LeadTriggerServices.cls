/**
* Lev
* @date 2020
*
* @group Lead
* @group-content ../../ApexDocContent/Lead.htm
*
* @description LeadServices on Lead
*/
public without sharing class LeadTriggerServices {
    
    public static final EnvironmentSetting__mdt ENVIRONMENT_SETTING = [select Id,Label,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName ='LeadTriggerQueue' LIMIT 1][0];
    /*******************************************************************************************************
    * @description 
    * if has lead.Related_Account__r.Broker_Owner__c , go to the user record with the contactId of the value of Broker_Owner__c and if user community user and is active 
    * then set the lead owner to that user
    * @param filteredLeads List of filtered Leads
    * @return Returns void
    */
   
    public static void processFilteredLeads(Map<Id,Lead> filteredLeads) {
        Group queue = [select Id,DeveloperName from Group where DeveloperName=:ENVIRONMENT_SETTING.Value__c LIMIT 1][0];
        List<Lead> lstLead = [Select Id,Related_Account__r.Broker_Owner__c,Related_Account__c FROM Lead WHERE Id IN: filteredLeads.keyset() ]; //AND Related_Account__r.Broker_Owner__c != NULL
        Map<Id,Lead> contactLeads = new Map<Id,Lead>();
        Map<Id,User> foundUsers = new Map<Id,User>();

        for(Lead objLead:lstLead){
            if(objLead.Related_Account__r.Broker_Owner__c != null){
                contactLeads.put(objLead.Related_Account__r.Broker_Owner__c, objLead);
            } 
        }
        List<User> lstUser = [SELECT Id,ContactId,Profile.Name,Name FROM User WHERE contactId IN: contactLeads.keySet() AND Usertype LIKE '%Partner%' AND IsActive = True];
        for(User objUser:lstUser){
            foundUsers.put(objUser.contactId, objUser);
        }
        for(Lead objLead:lstLead){
 
            if(foundUsers.containsKey(objLead.Related_Account__r.Broker_Owner__c)){
                objLead.OwnerId = foundUsers.get(objLead.Related_Account__r.Broker_Owner__c).Id;
            }else{
               
                objLead.OwnerId = queue.Id;
            }
        }
        update lstLead;
    }
}