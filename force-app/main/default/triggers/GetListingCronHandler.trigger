trigger GetListingCronHandler on VPE_Listing_Partner__c (before update) {
    for( VPE_Listing_Partner__c partner : Trigger.new ) {
        VPE_Listing_Partner__c oldPartner = Trigger.oldMap.get(partner.Id);
        if( partner.Call_Frequency_Min__c != oldPartner.Call_Frequency_Min__c ) {
            if ( partner.Cron_Id__c != null && partner.Cron_Id__c != '' ) {
                List<CronTrigger> ctList = new List<CronTrigger>();
                ctList = [SELECT Id, CronJobDetailId FROM CronTrigger WHERE Id =: partner.Cron_Id__c];
                if( ctList.size() > 0 ) {
                    System.abortJob(partner.Cron_Id__c);
                }
                Datetime crontime = system.now().addMinutes(Integer.valueOf(partner.Call_Frequency_Min__c));
                String day = string.valueOf(crontime.day());
                String month = string.valueOf(crontime.month());
                String hour = string.valueOf(crontime.hour());
                String minute = string.valueOf(crontime.minute());
                String second = string.valueOf(crontime.second());
                String year = string.valueOf(crontime.year());
                String cronExp = '0 ' + minute + ' ' + hour + ' ' +day+ ' ' + month + ' ? ' + year;
                if(partner.name == 'CARVIO'){
                    Id cronId = System.schedule('Listing Batch Scheduler after Time change_'+System.now(), cronExp ,new IAAI_VPEListingBatchScheduler());
                    partner.Cron_Id__c = cronId;
                }else if (partner.name == 'TRADEREV'){
                    Id cronId = System.schedule('Listing Batch Scheduler after Time change_'+System.now(), cronExp ,new IAAI_VPEListingBatchTradeRevScheduler());
                    partner.Cron_Id__c = cronId; 
                }
            } 
        }
    }

    if(Trigger.isUpdate){
        for( VPE_Listing_Partner__c partner : Trigger.new ) {
            VPE_Listing_Partner__c partnerRec = trigger.oldMap.get(partner.Id);
            if( (partnerRec.Auto_Bid_Eligible__c != null && partnerRec.Auto_Bid_Eligible__c != partner.Auto_Bid_Eligible__c ) || (partnerRec.Price_Limit__c != null && partnerRec.Price_Limit__c != partner.Price_Limit__c ) || (partnerRec.Mileage_Limit__c != null && partnerRec.Mileage_Limit__c != partner.Mileage_Limit__c ) || (partnerRec.Year_Limit__c != null && partnerRec.Year_Limit__c != partner.Year_Limit__c ) || (partnerRec.Vehicle_Condition_Grade__c != null && partnerRec.Vehicle_Condition_Grade__c != partner.Vehicle_Condition_Grade__c ) || (partnerRec.Make_Value__c != null && partnerRec.Make_Value__c != partner.Make_Value__c ) || (partnerRec.of_Value__c != null && partnerRec.of_Value__c != partner.of_Value__c ) || (String.isNotBlank(partnerRec.Reference_Value__c) && partnerRec.Reference_Value__c != partner.Reference_Value__c ) &&  ( String.isBlank(partner.Status__c) ) && Label.UserToByPassListingPartnerApprovalProcess.Contains(userInfo.getUserName())) {
                   partner.VPE_Listing_Partner__c = json.serialize(partner);
                   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                   req1.setComments('Submitting request for approval.');
                   req1.setObjectId(partner.id);                 
                   req1.setSubmitterId(UserInfo.getUserId()); 
                   req1.setProcessDefinitionNameOrId('VPEListing_Partner_Approval_v1');
                   req1.setSkipEntryCriteria(true);
                   if(!test.isRunningTest()){
                     Approval.ProcessResult result = Approval.process(req1);  
                   }
                   
                   partner.Status__c = 'Submitted';
                   
                   partner.Auto_Bid_Eligible__c = partnerRec.Auto_Bid_Eligible__c;
                   partner.Price_Limit__c = partnerRec.Price_Limit__c;
                   partner.Mileage_Limit__c = partnerRec.Mileage_Limit__c;
                   partner.Year_Limit__c = partnerRec.Year_Limit__c;
                   partner.Vehicle_Condition_Grade__c = partnerRec.Vehicle_Condition_Grade__c;
                   partner.Make_Value__c = partnerRec.Make_Value__c;
                   partner.of_Value__c = partnerRec.of_Value__c;
                   partner.Reference_Value__c = partnerRec.Reference_Value__c; 
               }
            System.debug('partnerRec.Status__c--->>'+partnerRec.Status__c+ 'partner.Status__c---->>  '+partner.Status__c);
            if( partnerRec.Status__c == 'Submitted'  && partner.Status__c == 'Approved' ){
                
                String str = partner.VPE_Listing_Partner__c;
                Map<String, Object> partnerRecordData =   (Map<String, Object>) JSON.deserializeUntyped(str);
                system.debug('partnerRecordData----'+partnerRecordData);
                partner.Auto_Bid_Eligible__c = boolean.Valueof(partnerRecordData.get('Auto_Bid_Eligible__c'));
                partner.Price_Limit__c = (decimal) partnerRecordData.get('Price_Limit__c');
                partner.Mileage_Limit__c = (decimal) partnerRecordData.get('Mileage_Limit__c');
                partner.Year_Limit__c = String.ValueOf(partnerRecordData.get('Year_Limit__c'));
                partner.Vehicle_Condition_Grade__c = (decimal) partnerRecordData.get('Vehicle_Condition_Grade__c');
                partner.Make_Value__c = String.valueOf(partnerRecordData.get('Make_Value__c'));
                partner.of_Value__c = (decimal) partnerRecordData.get('of_Value__c');
                partner.Reference_Value__c = String.valueOf(partnerRecordData.get('Reference_Value__c')); 
                partner.VPE_Listing_Partner__c = '';
            }
        }
    }
}