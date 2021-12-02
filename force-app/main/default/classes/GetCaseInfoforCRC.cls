public class GetCaseInfoforCRC {
    @AuraEnabled(cacheable=true)
    public static Case getInfo( String recordId ){
        system.debug('==11='+recordId);
        Case caseList = [ Select Id, contact.Name, CRC_Storage_Location__r.Location_Id__c, CRC_Storage_Location__r.Type, CRC_Storage_Location__c, CRC_Storage_Location__r.ShippingAddress, Status, CRC_Storage_Location__r.Phone, CRC_Storage_Location__r.Fax, CRC_Storage_Location__r.Email__c, CRC_Storage_Location__r.Federal_Tax_Id__c,
                         CRC_Storage_Location__r.Sunday_Open_From__c, CRC_Storage_Location__r.Sunday_Closed_At__c, CRC_Storage_Location__r.Sunday_Unavailable_From__c, CRC_Storage_Location__r.Sunday_Unavailable_To__c, CRC_Storage_Location__r.Monday_Open_From__c,
                         CRC_Storage_Location__r.Monday_Closed_At__c, CRC_Storage_Location__r.Monday_Unavailable_From__c, CRC_Storage_Location__r.Monday_Unavailable_To__c, CRC_Storage_Location__r.Tuesday_Open_From__c, CRC_Storage_Location__r.Tuesday_Closed_At__c,
                         CRC_Storage_Location__r.Tuesday_Unavailable_From__c, CRC_Storage_Location__r.Tuesday_Unavailable_To__c, CRC_Storage_Location__r.Wednesday_Open_From__c, CRC_Storage_Location__r.Wednesday_Closed_At__c, CRC_Storage_Location__r.Wednesday_Unavailable_From__c,
                         CRC_Storage_Location__r.Wednesday_Unavailable_To__c, CRC_Storage_Location__r.Thursday_Open_From__c, CRC_Storage_Location__r.Thursday_Closed_At__c, CRC_Storage_Location__r.Thursday_Unavailable_From__c, CRC_Storage_Location__r.Thursday_Unavailable_To__c,
                         CRC_Storage_Location__r.Friday_Open_From__c, CRC_Storage_Location__r.Friday_Closed_At__c, CRC_Storage_Location__r.Friday_Unavailable_From__c, CRC_Storage_Location__r.Friday_Unavailable_To__c, CRC_Storage_Location__r.Saturday_Open_From__c, CRC_Storage_Location__r.Saturday_Closed_At__c,
                         CRC_Storage_Location__r.Saturday_Unavailable_From__c, CRC_Storage_Location__r.Saturday_Unavailable_To__c
                         from Case where Id=: recordId];
                         system.debug('==='+caseList);
    	return caseList;
    }
}