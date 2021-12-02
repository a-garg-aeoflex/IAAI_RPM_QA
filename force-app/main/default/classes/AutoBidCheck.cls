public class AutoBidCheck {
    
    public static void checkAutoEligibleListing(Id recordId)
    {
        Set<Id> vpListingIds = new Set<Id>();
        VPE_Listings__c  vpeListing =[SELECT Id, Model_Year__c,Mileage__c,Retail_ACV__c,Make__c,VPE_Listing_Partner__r.Name, VPE_Listing_Partner__r.Vehicle_Condition_Grade__c, Vehicle_Condition_Grade__c,
                                      VPE_Listing_Partner__r.Make_Value__c,VPE_Listing_Partner__r.Mileage_Limit__c,VPE_Listing_Partner__r.Price_Limit__c,VPE_Listing_Partner__r.Year_Limit__c,
                                      VPE_Listing_Partner__r.Auto_Bid_Eligible__c 
                                      FROM VPE_Listings__c WHERE ID =: recordId ];
        
        List<Auto_Bid_Eligibility_Check__mdt> autoBidEligibilityCheckMetadata = [SELECT id,MasterLabel FROM Auto_Bid_Eligibility_Check__mdt WHERE Active__c = true AND MasterLabel=:vpeListing.VPE_Listing_Partner__r.Name];
        
        if(Test.isRunningTest()){
            Auto_Bid_Eligibility_Check__mdt ab = new Auto_Bid_Eligibility_Check__mdt();
            ab.DeveloperName = 'test';
            autoBidEligibilityCheckMetadata.add(ab);
        }
        
        if(autoBidEligibilityCheckMetadata.size()>0)
        {
            if(vpeListing.Model_Year__c == string.valueof(vpeListing.VPE_Listing_Partner__r.Year_Limit__c) && vpeListing.Retail_ACV__c == vpeListing.VPE_Listing_Partner__r.Price_Limit__c && vpeListing.Mileage__c == vpeListing.VPE_Listing_Partner__r.Mileage_Limit__c && vpeListing.Make__c == vpeListing.VPE_Listing_Partner__r.Make_Value__c && vpeListing.VPE_Listing_Partner__r.Auto_Bid_Eligible__c == true && vpeListing.VPE_Listing_Partner__r.Vehicle_Condition_Grade__c != null && vpeListing.Vehicle_Condition_Grade__c > vpeListing.VPE_Listing_Partner__r.Vehicle_Condition_Grade__c
              )
            {
                system.debug('Auto bid is submitted');
                vpListingIds.add(vpeListing.Id);
                BuyerListingController.autoBidCheck(vpListingIds);
            }
            else
            {
                system.debug('Auto bid is not submitted.');
                vpeListing.Status_of_Listing__c = 'Manual Bid Required';
            }
        }
        else
        {
            System.debug('Auto bid is turned off for the Organization.');
            vpeListing.Status_of_Listing__c = 'Manual Bid Required';
            
        }
    }
}