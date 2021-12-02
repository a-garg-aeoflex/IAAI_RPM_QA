global class IAAI_VPEListingBatchTradeRevScheduler implements Schedulable {
    global void execute( SchedulableContext sc ) {
        VPE_Listing_Partner__c partnerDetail = [SELECT Id, Name, Cron_Id__c ,Last_Batch_Ran_At__c, Call_Frequency_Min__c, Call_Start_Time__c, Call_End_Time__c FROM VPE_Listing_Partner__c WHERE Name = 'TRADEREV' LIMIT 1];        
        Integer addTime = Integer.valueOf(partnerDetail.Call_Frequency_Min__c);
        Datetime cronTime = System.now().addMinutes(addTime);
        String day = string.valueOf(cronTime.day());
        String month = string.valueOf(cronTime.month());
        String hour = string.valueOf(cronTime.hour());
        String second = string.valueOf(cronTime.second());
        String year = string.valueOf(cronTime.year());
        String minute = string.valueOf(cronTime.minute());
        
        // if( System.now().format('E') != 'Sat' && System.now().format('E') != 'Sun' ) {
        if( System.now().time() >= partnerDetail.Call_Start_Time__c && System.now().time() <= partnerDetail.Call_End_Time__c ) {
            if( !Test.isRunningTest() ) {
                IAAI_VPEListing_Batch_Traderev p = new IAAI_VPEListing_Batch_Traderev();
                Database.executeBatch(p);
            }
        } 
        // }  
        if( partnerDetail.Cron_Id__c != '' && partnerDetail.Cron_Id__c != null ) {
            List<CronTrigger> ctList = new List<CronTrigger>();
            ctList = [SELECT Id, CronJobDetailId FROM CronTrigger WHERE Id =: partnerDetail.Cron_Id__c];
            if( ctList.size() > 0 ) {
                System.abortJob(partnerDetail.Cron_Id__c);
                String strSchedule = '0 ' + minute + ' ' + hour + ' ' +day+ ' ' + month + ' ? ' + year;
                String JobId = System.schedule('TRADEREv_Get_Listing_Scheduled_At_'+System.now(), strSchedule, new IAAI_VPEListingBatchTradeRevScheduler());             
                partnerDetail.Cron_Id__c = JobId;
                update partnerDetail;
            }
        }
    }
}