public Without Sharing class IAAI_BoltOnController {
    public static VPE_Listing_Partner__c currentPartner;
    
    public static VPE_Listing_Partner__c getCurrentListingPartner() {
        if(currentPartner != null) {
            return currentPartner;
        }
        
        User u = [SELECT Id, ContactId, AccountId FROM User WHERE Id =:UserInfo.getUserId()]; 
        
        if(!Test.isRunningTest()){
            currentPartner = [SELECT Id, Name FROM VPE_Listing_Partner__c WHERE Account__c =:u.AccountId];
        }else{
           currentPartner = [SELECT Id, Name FROM VPE_Listing_Partner__c WHERE Name ='Carvio'];  
        }
        
        return currentPartner;
    }

    @AuraEnabled
    public static Map<String, Object> acceptTermsAndConditions(){
        try {
            String contactId = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1]?.ContactId;
            Contact c = [SELECT Id, Terms_and_Conditions__c FROM Contact WHERE Id =:contactId LIMIT 1];
            c.Terms_and_Conditions__c = true;
            update c;
            return new Map<String, Object>{'success' => true};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static Map<String, Object> fetchUser(){
        User u = [SELECT Id, Name, ContactId FROM User WHERE Id =:UserInfo.getUserId()];
        return new Map<String, Object> {
            'username' => u.Name,
            'contact' => [SELECT Id, Terms_and_Conditions__c FROM Contact WHERE Id =:u.ContactId LIMIT 1],
            'globalPartner' => [SELECT Id, Bolt_on_Consent__c FROM VPE_Listing_Partner__c WHERE Name = 'IAAI' LIMIT 1]
        };
    }
    
    @AuraEnabled    
    public static BuyerListingDataTableWrapper fetchVPEListing(String pageSize, String pageNumber,String userid) { 
        
        Integer psize = Integer.valueOf(pageSize);
        Integer pnumber = Integer.valueOf(pageNumber);
        //set<String> relatedContacts = new set<String>();
        //relatedContacts = getContactIds(userid);
        
         //Offset for SOQL
        Integer offset = (pnumber - 1) * psize;
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM VPE_Listings__c WHERE VPE_Listing_Partner__c =:getCurrentListingPartner().Id];
        Integer recordEnd = pSize * pNumber;
        
        //Instance of Contact DataTable Wrapper Class
        BuyerListingDataTableWrapper objDT =  new BuyerListingDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords; 
        objDT.totalRecords = totalRecords;
        objDT.buyerListingList = [SELECT Id,Name,VIN__c,Decline_Reason__c,Status_of_Listing__c,Make__c,Model__c,Model_Year__c,Accept_Offer__c,Bid_Offer_Submitted__c,CreatedDate,CreatedBy.Name,contact__r.name, Original_Bid_Offer_Amount__c FROM VPE_Listings__c WHERE VPE_Listing_Partner__c =:getCurrentListingPartner().Id ORDER BY CreatedDate DESC LIMIT :pSize OFFSET :offset];    
        
        return objDT;
    }
    
    @AuraEnabled    
    public static boolean updateVPEListingRec(String updatedVPEList) {    
        try {  
              VPE_Listings__c v= new VPE_Listings__c();
                v.id = updatedVPEList;
                v.Accept_Offer__c = true;
                v.Status_of_Listing__c = 'Won';
                update v;  
              return true;  
        } catch(Exception e) {  
            return false;  
        }   
    } 
    
     //Wrapper Class For BuyerListing DataTable  
    public class BuyerListingDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<VPE_Listings__c> buyerListingList {get;set;}
    }
   
    
}