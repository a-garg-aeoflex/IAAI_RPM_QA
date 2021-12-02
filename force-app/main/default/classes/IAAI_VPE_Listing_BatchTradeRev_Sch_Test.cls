@isTest
public class IAAI_VPE_Listing_BatchTradeRev_Sch_Test {
    @isTest
    public static void TradeRevSch_Test()
    {
        Test.StartTest();
        VPE_Listing_Partner__c vp = new VPE_Listing_Partner__c();
        vp.Name = 'TRADEREV';
        vp.Call_Frequency_Min__c = 30;
        vp.Listing_Partner_Type__c = 'Auction';
        vp.Cron_Id__c = 'sfafaf676';
        insert vp;           
        String strSchedule = '0 0 13 * * ?';
        String JobId = System.schedule('TRADEREv_Get_Listing_Scheduled_At_'+System.now(), strSchedule, new IAAI_VPEListingBatchTradeRevScheduler());  
        vp.Cron_Id__c = jobId;
        update vp;
        Test.stopTest();
    }
}