public class RelatedListController { 
    @AuraEnabled
    public static List<Contact> fetchRecords( String partnerId, String fields, String lastRecordId )  { 
        try {
            String accountId = [SELECT Id, Account__c FROM VPE_Listing_Partner__c WHERE Id =:partnerId]?.Account__c;
            if(String.isNotBlank(accountId)) {
                String query;
                if(String.isNotBlank(lastRecordId)) {
                    Contact c = [SELECT Id, CreatedDate FROM Contact WHERE Id =:lastRecordId];
                    Datetime y = c.CreatedDate;
                    query = 'SELECT Id, '+fields+' FROM Contact WHERE VPE_Partner_Contact__c = true AND AccountId =:accountId AND CreatedDate >:y ORDER BY CreatedDate DESC';
                } else {
                 	query = 'SELECT Id, '+fields+' FROM Contact WHERE VPE_Partner_Contact__c = true AND AccountId =:accountId ORDER BY CreatedDate DESC';
                }
                System.debug('query--'+query);
                return Database.query(query);
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
}