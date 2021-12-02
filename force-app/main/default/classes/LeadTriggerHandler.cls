public class LeadTriggerHandler extends TriggerHandler {
    /**************************************************************************************************
     *  Class Variables
     **************************************************************************************************/
    private static String LEAD_OBJ ='lead' ;
    private static Map<Id,Lead> triggerOldMap;
    private static Map<Id,Lead> triggerNewMap;
    private static List<Lead> triggerNew;
    private static List<Lead> triggerOld;
    private static map<String, Id> mapOfProfileNameAndId = new map<String, Id>();
    private static String ErrorMessage = System.Label.ErrorMessageCloseCase;
    public static final List<EnvironmentSetting__mdt> ENVIRONMENT_SETTINGS = [select Id, DeveloperName,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName IN('LeadTriggerRecordType','LeadTriggerSource')];
    public static final EnvironmentSetting__mdt ENVIRONMENT_SETTING = [select Id,Label,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName ='LeadTriggerQueue' LIMIT 1][0];
    public static Boolean LeadFirstRun = true;
    
    protected override void setup(){
        triggerOldMap = (Trigger.oldMap != null ? (Map<Id,Lead>) Trigger.oldMap : null );
        triggerNewMap = (Trigger.newMap != null ? (Map<Id,Lead>) Trigger.newMap : null );
        triggerOld  = (Trigger.old != null ? (List<Lead>) Trigger.old : null );
        triggerNew = (Trigger.new != null ? (List<Lead>) Trigger.new : null );
    }
 /*******************************************************************************************************
* @description	: Call all method  "before Insert" and "Before update" tigger events
* @param		:  Void
* @CreatedDated : 
* @UpdatedDateds: 
* @return Type:Void
*********************************************************************************************************/    
    protected override void doBefore(){
        if (Trigger.isInsert) {
            preventBuyerCloning();
            filterLeadsInserted(triggerNew,triggerNewMap);
        }else if (Trigger.isUpdate) {
            filterLeadsInserted(triggerNew,triggerNewMap);
        }
    }
/*******************************************************************************************************
* @description	: Please call all method which is need to call in triger After insert and After update
*				  Trigger events.
* @param		:  Void
* @CreatedDated : 
* @UpdatedDateds: 
* @return Type: Void
*********************************************************************************************************/     
    protected override void doAfter(){
        if (Trigger.isInsert){
        }else if (Trigger.isUpdate){
        } 
    }
/*******************************************************************************************************
* @description	: This method is used to prevent lead from clonning if if buyer is already converted into
*				  Broker.
* @param		:  Void
* @CreatedDated : 
* @UpdatedDateds: 
* @return Returns Map<Id,Lead>
*********************************************************************************************************/    
    private void preventBuyerCloning(){
        system.debug('In preventBuyerCloning');
        for(Lead leadRecords : triggernew){
            if(leadRecords.Buyer_Id__c <> Null ){
                String buyer = leadRecords.Buyer_Id__c;
                String prefixBuyer= 'BUY-'+buyer;
                List<Account> lstAcc = [SELECT Id, BI_Id__c, Name, Is_Broker_Created__c
                                        FROM Account
                                        WHERE  BI_Id__c =: buyer OR BI_Id__c =: prefixBuyer Limit 1] ;
                
                if(!lstAcc.isEmpty() && lstAcc[0].Is_Broker_Created__c == true){
                    leadRecords.addError('This Buyer already converted as Broker');
                }                                    
            }
        }
    }
   
/*******************************************************************************************************
* @description filters Leads Inserted
* @param triggerNew List of Lead that were updated
* @param oldMap Map of Ids and old versions of the Lead records.
* @return Returns Map<Id,Lead>
*********************************************************************************************************/
    private static void filterLeadsInserted(List<Lead> triggerNew, Map<Id,Lead> triggerNewMap) {
        Map<String,String> settings = new Map<String,String>();
        for(EnvironmentSetting__mdt envSetting:ENVIRONMENT_SETTINGS){
            settings.put(envSetting.DeveloperName,envSetting.Value__c);
        }  
        Id bidderLeadSupportRTId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(settings.get('LeadTriggerRecordType')).getRecordTypeId();
        Map<Id,Lead> filteredLeads = new Map<Id,Lead>();
        set<Id> setAccountId;
        map<String, String> mapOfleadOwnerUser = new map<String, String>();
        Group queue = [select Id,DeveloperName from Group where DeveloperName=:ENVIRONMENT_SETTING.Value__c LIMIT 1][0];
        set<String> strSetOfLeadIds = new set<String>(); 
        for(lead objLead : triggerNew){
            strSetOfLeadIds.add(objLead.Related_Account__c);            
        }
        for(Account objAccount : [SELECT Id, Broker_Owner__c, Broker_Owner__r.Broker_Partner_User__c FROM Account where Broker_Owner__r.Broker_Partner_User__c != null AND Id IN:strSetOfLeadIds]){
            if(objAccount.Broker_Owner__c <> null && objAccount.Broker_Owner__r.Broker_Partner_User__c <> null){ 
                mapOfleadOwnerUser.put(objAccount.Id,objAccount.Broker_Owner__r.Broker_Partner_User__c);                  
            }                     
            
        }
        for(Lead ld:triggerNew){
            if(ld.leadsource == settings.get('LeadTriggerSource') && ld.RecordTypeId == bidderLeadSupportRTId){
                if(mapOfleadOwnerUser.containsKey(ld.Related_Account__c)){
                    ld.OwnerId = mapOfleadOwnerUser.get(ld.Related_Account__c);
                }else{
                    ld.OwnerId = queue.id;
                }
            }
        } 
    }
}