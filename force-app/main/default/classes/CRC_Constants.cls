public with sharing class CRC_Constants {
   public static final String STORAGE_LOCATION_CONTACT_TYPE = 'Storage Location';
   public static final String STORAGE_LOCATION_MAILING_CONTACT_TYPE = 'Storage Location Mailing Contact';
   public static final String STORAGE_LOCATION_CONTACT_RECORD_TYPE_NAME = 'ASAP_RPM_Contact';
   public static final String STORAGE_LOCATION_CONTACT_ADJUSTER_TYPE = 'Adjuster';
   public static final String STORAGE_LOCATION_CONTACT_BRANCH_MANAGER_TYPE = 'Branch Manager';
   public static final String RPM_STATUS_CODE = 'STATUS_CODE';
   public static final String RPM_ACCEPT_STATUS_CODE = 'ACCEPT';
   public static final String RPM_REJECT_STATUS_CODE = 'REJECT';
   public static final String RPM_TRANSACTION_ID = String.valueOf(System.now().millisecond());
   public static final String RPM_CREATE_DATETIME = String.valueOfGMT(System.now()).replace(' ', 'T')+'Z';
   public static final CRC_RPM_Credential__mdt RPM_CREDENTIALS = CRC_RPM_Credential__mdt.getInstance('CRCC');
   public static Boolean REFRESH_AND_CHECKOUT = false;
   public static final String CRC_PRIORITY_ASSIGNMENTS = getQueueID();

   public static string getQueueID(){
      List<Group> listG = new list<Group>();
      listG =  [SELECT Id FROM Group  where DeveloperName =: 'CRC_Priority_Assignments'];
      return listG[0].Id;
   }

   @AuraEnabled
   public static string getStockNumber(String caseRecordId){
      return [Select CRC_Stock_Number__c FROM Case WHERE Id=:caseRecordId LIMIT 1].CRC_Stock_Number__c;
   }

}