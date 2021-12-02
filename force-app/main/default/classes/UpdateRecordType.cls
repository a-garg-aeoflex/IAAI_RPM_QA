public class UpdateRecordType {
    @InvocableMethod
    public static void updateRecordTypeByBuyerType(List<String> contactIds)
    {
        List<Contact> lstContact =[select id, RecordTypeId,Buyer_Type__c 
                      from Contact
                      where id in :contactIds ];
       
        for(Contact objCon:lstContact){
            if(objCon.Buyer_Type__c == 'Recycler'){
                 objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Recycler').getRecordTypeId();
            }else  if(objCon.Buyer_Type__c == 'Exporter'){
                 objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Exporter').getRecordTypeId();
            }else  if(objCon.Buyer_Type__c == 'Dealer'){
                 objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
            }else  if(objCon.Buyer_Type__c == 'Broker'){
                 objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
            }else  if(objCon.Buyer_Type__c == 'Public Buyer'){
                 objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Public').getRecordTypeId();
            }
           
        }
        upsert lstContact;
   }
}