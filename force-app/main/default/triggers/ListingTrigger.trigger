trigger ListingTrigger on VPE_Listings__c (after insert, before insert, before update, after update) {
    if( Trigger.operationType == TriggerOperation.AFTER_INSERT ) {
        ListingTriggerHandler.afterInsert();
        ListingTriggerHandler.updatePredictivePriceOnInsert(Trigger.new);
    } if( Trigger.operationType == TriggerOperation.BEFORE_INSERT ) {
        ListingTriggerHandler.setStartingBidToZero(Trigger.new);
    } if( Trigger.operationType == TriggerOperation.BEFORE_UPDATE ) {
        ListingTriggerHandler.updatePredictivePriceOnUpdate(Trigger.new, Trigger.oldMap);
        ListingTriggerHandler.bidOfferChange(Trigger.new, Trigger.oldMap);
        ListingTriggerHandler.setStartingBidToZero(Trigger.new);
        ListingTriggerHandler.suggestBid(Trigger.new, Trigger.oldMap);
        ListingTriggerHandler.makeAutoBid(Trigger.new, Trigger.oldMap);
        ListingTriggerHandler.bidOfferChangeisGreater(Trigger.new, Trigger.oldMap);
    }
   
}