public class IAAI_AutoBidQueueable implements Queueable, Database.AllowsCallouts {
    Set<Id> vpListIds = new Set<Id>();
    Boolean manualBidRequired = false;
    public IAAI_AutoBidQueueable(Set<Id> vpListIds, Boolean manualBidRequired){
        this.vpListIds = vpListIds;
        this.manualBidRequired = manualBidRequired;
    }
    public void execute(QueueableContext context) {
        try {
            if(manualBidRequired) {
                BuyerListingController.autoBidCheck(vpListIds, true);
            } else {
                BuyerListingController.autoBidCheck(vpListIds);
            }
        } catch(Exception e) {
            System.debug('exception--'+e.getMessage()+'--'+e.getStackTraceString());
        }
    }
}