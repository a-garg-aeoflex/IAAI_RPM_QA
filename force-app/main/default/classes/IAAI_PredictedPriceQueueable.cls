public class IAAI_PredictedPriceQueueable implements Queueable, Database.allowsCallouts{
    List<VPE_Listings__c> listings = new List<VPE_Listings__c>();
    public IAAI_PredictedPriceQueueable( List<VPE_Listings__c> newListings) {
        listings = newListings;
    }
    public void execute(QueueableContext qc) {
        if(!listings.isEmpty()) {
            for(VPE_Listings__C vpl : listings) {
                IAAI_PredictedPriceCalloutClass.getPredictedPrice(vpl,IAAI_PredictedPriceCalloutClass.getToken());
            }
            update listings;
        }
    }
}