public class UnlinkService implements Queueable, Database.AllowsCallouts {
    public String buyerId;
    public Account acct;
    
    public void unlinkCallout(){ 
        String apiName = 'unlinkAAMembership'; 
        HttpResponse resp = new  HttpResponse(); 
        String endpoint;
        String jsonstring = '{}';
        try{
            endpoint= 'callout:ASAPIntegration' + '/api/BuyerServices/UpdateAuctionAccessMembershipForBuyer/' + buyerId + '/true';
            Map<String, String> headers =  new Map<String, String> {'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + '{!$Credential.Password}'}; 
            resp = Utils.sendRequest('POST',  endpoint, jsonstring, false,headers, 0, apiName);
            //Blindly Retry Once
            if(!Utils.isResponseGood(resp)){
                System.debug('retry');
                resp = Utils.sendRequest('POST',  endpoint, jsonstring, false, headers, 0, apiName);
            }
            //If response is good
            Boolean setUnlinkDetails = false;
            if(Utils.isResponseGood(resp)){  
                String respBody =  resp.getBody();
                if(String.isNotBlank(respBody)){
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(respBody);
                    System.debug(m);
                    if(m.get('responseCode') == '1'){
                        setUnlinkDetails = true;
                        Utils.createOutboundLog(
                            new Integration_logs__c(Transaction_Type__c = EnvironmentSetting__mdt.getInstance('Unlink_Success_Message').Value__c,Sent_To__c=endpoint,Status__c='Success',
                        Response_Body__c=EnvironmentSetting__mdt.getInstance('Unlink_Success_Message')?.Value__c,Account__c = acct.Id ,Transection_Id__c = buyerId)
                        );

                DocumentService docService = new DocumentService();
                    docService.buyerId = String.valueOf(acct.API_Buyer_Id__c);
                    docService.acctId = acct.Id;
                    docService.apiName ='GetBuyerDocuments';
                    docService.enqueueGetLicenses = true;
                    docService.acct = acct;
                    if(!Test.isRunningTest()){
                        System.enqueueJob(docService);
                    }
                        
                        
                        
                    }
                    else{
                        Utils.createOutboundLog(new Integration_logs__c(Transaction_Type__c =EnvironmentSetting__mdt.getInstance('Unlink_Buyer_Account_API').Value__c,Sent_To__c=endpoint,Status__c='Failed',
                        Request_Body__c='{}',  Response_Body__c= resp.getStatusCode() + ' : ' +resp?.getBody(),Account__c = acct.Id,Transection_Id__c = buyerId));
                   
                    }
                    Account toUpdate = new account();
                    toUpdate.Id = acct.Id;
                    if(setUnlinkDetails){
                        toUpdate.AuctionAccess_Unlink_Date__c = Date.today();
                        toUpdate.AuctionAccess_Unlink_Requested_By__c = UserInfo.getUserId();
                        
                    }
                    
                    toUpdate.Unlink_AA_Membership__c = 'Available';
                    update toUpdate; 
            
                    
                }
                if(String.isBlank(respBody)){
                    throw new CustException('Error in UnlinkService.');
                }
            }else{

                throw new CustException('Error in UnlinkService.');
            } 
        }
        Catch(Exception e){
            System.debug('Caught error: ' + e.getLineNumber() + ', ' + e.getCause() + ', ' + e.getMessage());
        } 
    }
    
    public void execute(QueueableContext context) {
        AccountTriggerHelper.accountFirstRun = false;
        unlinkCallout();
    }

    private class CustException extends Exception{}
}