public class ListingTriggerHandler {
    public static void setStartingBidToZero( List<VPE_Listings__c> newListings ) {
        for( VPE_Listings__c vpl : newListings ) {
            if( vpl.Starting_Bid__c == null ){
                vpl.Starting_Bid__c = 0;
            }
            if( vpl.Top_Bid__c == null ) {
                vpl.Top_Bid__c = 0;
            }
        }
    }
    public static void suggestBid( List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap ) {
        Map<Id, VPE_Listing_Partner__c> partnerMap = new Map<Id, VPE_Listing_Partner__c>([SELECT Id, Name, Reference_Value__c, of_Value__c FROM VPE_Listing_Partner__c]);
        for( VPE_Listings__c vpl : newListings ) {
            VPE_Listing_Partner__c partner = partnerMap.containsKey(vpl.VPE_Listing_Partner__c)?partnerMap.get(vpl.VPE_Listing_Partner__c):null;
            if( partner != null && partner.Reference_Value__c != null && partner.of_Value__c != null && vpl.Status_of_Listing__c != 'Won' && vpl.Original_Bid_Offer_Amount__c == oldListingMap.get(vpl.Id).Original_Bid_Offer_Amount__c ) {
                if( (vpl.get(partner.Reference_Value__c) != null) ) {
                    if( partner.Name == CustomConstants.TRADEREV ) {
                        vpl.Original_Bid_Offer_Amount__c = (Integer.valueOf(vpl.get(partner.Reference_Value__c))*Integer.valueOf(partner.of_Value__c))/100;
                        if( vpl.Status_of_Listing__c == CustomConstants.UPCOMING ) {
                            Decimal amountConsiderForUpcoming = (vpl.Starting_Bid__c<CustomConstants.INCREMENT_BASE)?(vpl.Starting_Bid__c+CustomConstants.INCREMENT_VALUE_LESS_THAN_1000):(vpl.Starting_Bid__c+CustomConstants.INCREMENT_VALUE_GREATER_THAN_1000);
                                if( vpl.Original_Bid_Offer_Amount__c < amountConsiderForUpcoming ) {
                                    vpl.Original_Bid_Offer_Amount__c = amountConsiderForUpcoming;
                                }
                        } 
                        else if ( vpl.Status_of_Listing__c == CustomConstants.ACTIVE ) {
                            Decimal amountConsiderForTradeRevBid = (vpl.Starting_Bid__c<vpl.Top_Bid__c)?vpl.Top_Bid__c:vpl.Starting_Bid__c;
                            Decimal amountConsiderForActive = (amountConsiderForTradeRevBid<CustomConstants.INCREMENT_BASE)?(amountConsiderForTradeRevBid+(CustomConstants.INCREMENT_VALUE_LESS_THAN_1000*CustomConstants.INCREMENT_MULTIPLY_FOR_ACTIVE)):(amountConsiderForTradeRevBid+(CustomConstants.INCREMENT_VALUE_GREATER_THAN_1000*CustomConstants.INCREMENT_MULTIPLY_FOR_ACTIVE));
                                if( vpl.Original_Bid_Offer_Amount__c < amountConsiderForActive ) {
                                    vpl.Original_Bid_Offer_Amount__c = amountConsiderForActive;
                                }
                        }
                    } 
                    else {
                        vpl.Original_Bid_Offer_Amount__c = (Integer.valueOf(vpl.get(partner.Reference_Value__c))*Integer.valueOf(partner.of_Value__c))/100;
                    }
                }
            }
        }
    }
    public static void afterInsert() {
        if( !System.isBatch() ) {
            Database.executeBatch(new IAAI_UpdateMarketValueBatch(Trigger.new), 100);
            Database.executeBatch(new IAAI_Blackbook_Batch(), 10);
        }
    }
    public static void handleBidOfferSubmittedFlag( List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap ) {
        for( VPE_Listings__c vpl : newListings ) {
            VPE_Listings__c oldListing = oldListingMap.get(vpl.Id);
            if( vpl.Status_of_Listing__c == CustomConstants.PENDING && ( vpl.Status_of_Listing__c != oldListing.Status_of_Listing__c ) ) {
                vpl.Bid_Offer_Submitted__c = true;
            } else {
                vpl.Bid_Offer_Submitted__c = false;
            }
        }
    }
    public static void makeAutoBid(List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap) {
        Set<Id> listingsForAutoBid = new Set<Id>();
        Set<Id> listingForAutoBidOff = new set<Id>();
        Set<Id> listingForAutoBidNotEligible = new set<Id>();
        Map<Id, VPE_Listing_Partner__c> partnerMap = new Map<Id, VPE_Listing_Partner__c>([SELECT Id, Name, Year_Limit__c, Price_Limit__c, Mileage_Limit__c,
                                                                                          Make_Value__c, Auto_Bid_Eligible__c, Vehicle_Condition_Grade__c,
                                                                                          Reference_Value__c,of_Value__c
                                                                                          FROM VPE_Listing_Partner__c ORDER BY CreatedDate DESC]);
        if(Label.IAAI_Global_Auto_Bid == 'ON') {
            for(VPE_Listings__c vpeListing : newListings) {
                Decimal calculatedPrice;
                VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
                if(vpeListing.VPE_Listing_Partner__c != null && vpeListing.Predicted_Price__c != null ){
                    partner = partnerMap.get(vpeListing.VPE_Listing_Partner__c);
                    calculatedPrice = calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
                }
                if(vpeListing.Predicted_Price__c != oldListingMap.get(vpeListing.Id).Predicted_Price__c) {
                    if(vpeListing.Model_Year__c >= string.valueof(partner.Year_Limit__c) &&
                       calculatedPrice <= partner.Price_Limit__c && calculatedPrice != null &&
                       vpeListing.Mileage__c >= partner.Mileage_Limit__c &&
                       partner.Auto_Bid_Eligible__c == true && 
                       partner.Vehicle_Condition_Grade__c != null &&
                       vpeListing.Vehicle_Condition_Grade__c >= partner.Vehicle_Condition_Grade__c
                      )
                    {
                        system.debug('Auto bid is submitted');
                        listingsForAutoBid.add(vpeListing.Id);
                    }
                    else
                    {
                        system.debug('Auto bid is not submitted.');
                        for(VPE_Listings__c vp : newListings) {
                            // if(vp.Original_Bid_Offer_Amount__c == oldListingMap.get(vpeListing.Id).Original_Bid_Offer_Amount__c) {
                             	vp.Status_of_Listing__c = 'Manual Bid Required';
                                if(vp.VPE_Listing_Partner__c != null && vp.Predicted_Price__c != null) {
                                    vp.Original_Bid_Offer_Amount__c = calculateBidAmount(vp, partnerMap.get(vp.VPE_Listing_Partner__c));
                                }
                                listingForAutoBidNotEligible.add(vp.Id);   
                            // }
                        }
                    }
                }
            }
            
            if(!listingsForAutoBid.isEmpty()) {
                System.enqueueJob(new IAAI_AutoBidQueueable(listingsForAutoBid, false));
            }
            if(!listingForAutoBidNotEligible.isEmpty()) {
                System.enqueueJob(new IAAI_AutoBidQueueable(listingForAutoBidNotEligible, true));
            }
        } 
        else {
            System.debug('Auto bid is turned off for the Organization.');
            for(VPE_Listings__c vp : newListings) {
                // if(vp.Original_Bid_Offer_Amount__c == oldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c) {
                    vp.Status_of_Listing__c = 'Manual Bid Required';
                    if( vp.VPE_Listing_Partner__c != null && vp.Predicted_Price__c != null ){
                        vp.Original_Bid_Offer_Amount__c = calculateBidAmount(vp, partnerMap.get(vp.VPE_Listing_Partner__c)); 
                    }
                    listingForAutoBidOff.add(vp.Id);
                // }
            }
            if(!listingForAutoBidOff.isEmpty()) {
                System.enqueueJob(new IAAI_AutoBidQueueable(listingForAutoBidOff, false));
            }
        }
        
    }
    public static void updatePredictivePriceOnInsert(List<VPE_Listings__c> newListings) {
        List<VPE_Listings__c> listingsNeedPredictivePrice = new List<VPE_Listings__c>();
        for(VPE_Listings__c vpl : newListings) {
            if(vpl.Status_of_Listing__c != 'Won') {
                listingsNeedPredictivePrice.add(vpl);
            }
        }
        if(!listingsNeedPredictivePrice.isEmpty()) {
            List<VPE_Listings__c> listingsToBeUpdate = [SELECT Id, VIN__c,Predicted_Price__c, Vehicle_Condition_Grade__c, Loss_Type_Code__c, Primary_Damage__c, 
                                                        Secondary_Damage__c, Engine_Status_Code__c, CreatedDate, Mileage__c 
                                                        FROM VPE_Listings__c WHERE Id IN :listingsNeedPredictivePrice];
            if(!Test.isRunningTest()){
                System.enqueueJob(new IAAI_PredictedPriceQueueable(listingsToBeUpdate));
            }
        }
    }
    public static void updatePredictivePriceOnUpdate(List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap) {
        List<VPE_Listings__c> listingsNeedPredictivePrice = new List<VPE_Listings__c>();
        for(VPE_Listings__c vpl : newListings) {
            if(vpl.Status_of_Listing__c != 'Won' && 
               (oldListingMap.get(vpl.Id).Vehicle_Condition_Grade__c != vpl.Vehicle_Condition_Grade__c ||
                oldListingMap.get(vpl.Id).Loss_Type_Code__c != vpl.Loss_Type_Code__c ||
                oldListingMap.get(vpl.Id).Primary_Damage__c != vpl.Primary_Damage__c ||
                oldListingMap.get(vpl.Id).Secondary_Damage__c != vpl.Secondary_Damage__c ||
                oldListingMap.get(vpl.Id).Engine_Status_Code__c != vpl.Engine_Status_Code__c ||
                oldListingMap.get(vpl.Id).Mileage__c != vpl.Mileage__c)) {
                    listingsNeedPredictivePrice.add(vpl);
            }
        }
        System.debug('listingsNeedPredictivePrice--'+listingsNeedPredictivePrice);
        if(!listingsNeedPredictivePrice.isEmpty()) {
            System.debug('inside Queueable--');
            System.enqueueJob(new IAAI_PredictedPriceQueueable(listingsNeedPredictivePrice));
        }
    }
    /*public static void makeAutoBidOnInsert(List<VPE_Listings__c> newListings) {
        Set<Id> listingsForAutoBid = new Set<Id>();
        Map<Id, VPE_Listing_Partner__c> partnerMap = new Map<Id, VPE_Listing_Partner__c>([SELECT Id, Name, Year_Limit__c, Price_Limit__c, Mileage_Limit__c,
                                                                                          Make_Value__c, Auto_Bid_Eligible__c, Vehicle_Condition_Grade__c,
                                                                                          Reference_Value__c,of_Value__c
                                                                                          FROM VPE_Listing_Partner__c ORDER BY CreatedDate DESC]);
        List<Auto_Bid_Eligibility_Check__mdt> autoBidEligibilityCheckMetadata = [SELECT id,MasterLabel FROM Auto_Bid_Eligibility_Check__mdt WHERE Active__c = true];
        if(Label.IAAI_Global_Auto_Bid == 'ON') {
            Set<String> eligiblePartners = new Set<String>();
            for(Auto_Bid_Eligibility_Check__mdt ab : autoBidEligibilityCheckMetadata) {
                eligiblePartners.add(ab.MasterLabel);
            }
            for(VPE_Listings__c vpeListing : newListings) {
                system.debug('vpeListing------>>>'+vpeListing);
                VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
                Decimal calculatedPrice;									
                if(vpeListing.VPE_Listing_Partner__c != null && vpeListing.Predicted_Price__c != null ){
                    partner = partnerMap.get(vpeListing.VPE_Listing_Partner__c);
                    calculatedPrice = calculateBidAmount(vpeListing, partnerMap.get(vpeListing.VPE_Listing_Partner__c));
                }
                
                if(vpeListing.Predicted_Price__c != null &&
                   vpeListing.Model_Year__c >= string.valueof(partner.Year_Limit__c) &&
                   calculatedPrice <= partner.Price_Limit__c && calculatedPrice != null &&
                   vpeListing.Mileage__c <= partner.Mileage_Limit__c &&
                   partner.Auto_Bid_Eligible__c == true && 
                   partner.Vehicle_Condition_Grade__c != null &&
                   vpeListing.Vehicle_Condition_Grade__c < partner.Vehicle_Condition_Grade__c
                  )
                {
                    system.debug('Auto bid is submitted');
                    listingsForAutoBid.add(vpeListing.Id);
                }
                else
                {
                    system.debug('Auto bid is not submitted.');
                    for(VPE_Listings__c vp : newListings) {
                        vp.Status_of_Listing__c = 'Manual Bid Required';
                        if(vp.VPE_Listing_Partner__c != null && vp.Predicted_Price__c != null) {
                            vp.Original_Bid_Offer_Amount__c = calculateBidAmount(vp, partnerMap.get(vp.VPE_Listing_Partner__c)); 
                        }
                    }
                }   
            }
            
            
            if(!listingsForAutoBid.isEmpty()) {
                System.enqueueJob(new IAAI_AutoBidQueueable(listingsForAutoBid));
            }
        } else {
            System.debug('Auto bid is turned off for the Organization.');
            for(VPE_Listings__c vp : newListings) {
                vp.Status_of_Listing__c = 'Manual Bid Required';
                vp.Original_Bid_Offer_Amount__c = calculateBidAmount(vp, partnerMap.get(vp.VPE_Listing_Partner__c));
            }
        }
    }*/
    public static Decimal calculateBidAmount(VPE_Listings__c vpl, VPE_Listing_Partner__c partner) {
        if(partner.Reference_Value__c != null && partner.of_Value__c != null) {
            return (Integer.valueOf(vpl.get(partner.Reference_Value__c))*Integer.valueOf(partner.of_Value__c))/100;
        }
        return 0;
    }
    
    /*public static void suggestOfferInLotBid ( List<VPE_Listings__c> listings ) {
        Set<Id> parentListingIds = new Set<Id>();
        List<VPE_Listings__c> parentListings = new List<VPE_Listings__c>();
        if( listings.size() > 0 ) {
            for( VPE_Listings__c vpl : listings ) {
                if( vpl.Parent_VPE_Listing__c != null ) {
                    parentListingIds.add(vpl.Parent_VPE_Listing__c);
                }
            }
            if( parentListingIds.size() > 0 ) {
                AggregateResult[] sumOfLot = [select Parent_VPE_Listing__c, count(Id)countOfLot, sum(Original_Bid_Offer_Amount__c) sumOfLotBids FROM VPE_Listings__c where Parent_VPE_Listing__c =: parentListingIds GROUP BY Parent_VPE_Listing__c];
                if( sumOfLot != null && sumOfLot.size() > 0 ) {
                    for( AggregateResult ar : sumOfLot ) {
                        parentListings.add(
                            new VPE_Listings__c(Id = String.valueOf(ar.get('Parent_VPE_Listing__c')),
                                                Number_Of_Listings__c = Integer.valueOf(ar.get('countOfLot')),
                                                Suggested_Offer__c = Integer.valueOf(ar.get('sumOfLotBids')))
                        );
                    }
                }
                if( parentListings != null && parentListings.size() > 0 ) {
                    update parentListings;
                }
            }
        }
    }*/
    
    public static void bidOfferChange( List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap ){
        List<Offer_Change_Detail__c> OfferListing = new List<Offer_Change_Detail__c>();
        for( VPE_Listings__c vp : newListings ) {
            if(oldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c != vp.Original_Bid_Offer_Amount__c) {
                vp.Offer_Changed__c = true;
                Offer_Change_Detail__c ocd = new Offer_Change_Detail__c();
                ocd.User__c = vp.LastModifiedById;
                ocd.New_Offer_Value__c = vp.Original_Bid_Offer_Amount__c;
                ocd.Original_Offer_Value__c = OldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c;
                ocd.VPE_Listing__c = vp.Id;
                ocd.Value_Change_Time__c = System.now();
                offerListing.add(ocd);
            } 
        }
        if( offerListing.size() > 0 ){
            insert offerListing;
        }
    }

    public static void bidOfferChangeisGreater( List<VPE_Listings__c> newListings, Map<Id, VPE_Listings__c> oldListingMap ){
        try {
            for( VPE_Listings__c vp : newListings ) {
                if(oldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c != null && 
                    vp.Original_Bid_Offer_Amount__c > oldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c &&
                    oldListingMap.get(vp.Id).Status_of_Listing__c != 'Submitted' && 
                    (oldListingMap.get(vp.Id).Status_of_Listing__c != 'Pending' || (oldListingMap.get(vp.Id).Status_of_Listing__c == 'Pending' && vp.Status_of_Listing__c == 'Won')) ) {
                    vp.Copy_of_Original_Bid_Offer_Amount__c = vp.Original_Bid_Offer_Amount__c;
                    vp.Original_Bid_Offer_Amount__c = oldListingMap.get(vp.Id).Original_Bid_Offer_Amount__c;
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(vp.id);
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    req1.setProcessDefinitionNameOrId('VEListingOriginalBidAmountApproval_v1');
                    req1.setSkipEntryCriteria(true);
                    if(!Test.isRunningTest()){
                        Approval.ProcessResult result = Approval.process(req1);
                        vp.Status_of_Listing__c = 'Submitted';
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception--'+ex.getMessage());
        }
    }
}