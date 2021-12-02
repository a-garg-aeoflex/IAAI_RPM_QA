/**
* @Lev 
* @date 2020
*
* @group Lead
* @group-content ../../ApexDocContent/Lead.htm
*
* @description LeadTriggerDispatcher on Lead which calls the LeadServices
*/
public with sharing class LeadTriggerDispatcher {
    @TestVisible
    public static Boolean LeadFirstRun = true;
    @TestVisible
    public static final List<EnvironmentSetting__mdt> ENVIRONMENT_SETTINGS = [select Id, DeveloperName,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName IN('LeadTriggerRecordType','LeadTriggerSource')];
    /*******************************************************************************************************
    * @description Returns void
    * @param triggerNew List of Leads that were inserted
    * @return Returns void
    */
	public static void afterInsert(List<Lead> triggerNew, Map<Id, Lead> newMap){
             
        Map<Id,Lead> filteredLeads = filterLeadsInserted(triggerNew); 
        if(!filteredLeads.isEmpty()){
            LeadTriggerServices.processFilteredLeads(filteredLeads);
        }        
    }
    
	/*******************************************************************************************************
    * @description filters Leads Inserted
    * @param triggerNew List of Lead that were updated
    * @param oldMap Map of Ids and old versions of the Lead records.
    * @return Returns Map<Id,Lead>
    */
    private static Map<Id,Lead> filterLeadsInserted(List<Lead> triggerNew) {
        Map<String,String> settings = new Map<String,String>();
        for(EnvironmentSetting__mdt envSetting:ENVIRONMENT_SETTINGS){
            settings.put(envSetting.DeveloperName,envSetting.Value__c);
        }  
        Id bidderLeadSupportRTId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(settings.get('LeadTriggerRecordType')).getRecordTypeId();
        Map<Id,Lead> filteredLeads = new Map<Id,Lead>();
        for(Lead objLead:triggerNew){
            if(objLead.leadsource == settings.get('LeadTriggerSource') && objLead.RecordTypeId == bidderLeadSupportRTId){
                filteredLeads.put(objLead.Id,objLead);
            }
		}
        return filteredLeads;
    }
	
}