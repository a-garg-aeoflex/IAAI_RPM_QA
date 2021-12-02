@isTest
private class BrokerBidderReviewClass_Test {
    
    private static testmethod void method1(){
        Account objTestAccount = new Account();
        objTestAccount.Name = 'Test 123';
        objTestAccount.Is_Broker_Created__c = false;
        objTestAccount.BI_ID__c = 'BUY-199123';
        
        insert objTestAccount;
        
        Opportunity objOppty = new Opportunity();
        objOppty.Name = 'Test opp';
        objOppty.AccountId = objTestAccount.Id;
        objOppty.StageName = 'Broker bidder Review';
        objOppty.CloseDate = date.parse('11/11/2020');
        Insert objOppty;
        List<contact> objLstCon = new List<contact> ();
        BrokerBidderReviewClass objBrBiddRev = new BrokerBidderReviewClass();
        BrokerBidderReviewClass.AccountContact obj = new BrokerBidderReviewClass.AccountContact(objTestAccount, objLstCon);
        //BrokerBidderReviewClass.CreateBrokerWrapper obj1 = new BrokerBidderReviewClass.CreateBrokerWrapper();
        
        BrokerBidderReviewClass.ResponseCreateBrokerAPI obj2 = new BrokerBidderReviewClass.ResponseCreateBrokerAPI();
        obj2.CreatedTime = 'test';
        obj2.SentFrom = 'Test';
        obj2.TransactionID = 'Test12';
        obj2.TransactionType = 'test12';
        obj2.Version = 'test13';
        obj2.SentTo = 'test';
        
        BrokerBidderReviewClass.Result obj3 = new BrokerBidderReviewClass.Result();
        BrokerBidderReviewClass.fetchAccountCon(objOppty.Id);
        
    }
    static testMethod void testPostCallout() {
        Account objTestAccount1 = new Account();
        objTestAccount1.Name = 'Test 1231';
        objTestAccount1.Is_Broker_Created__c = false;
        objTestAccount1.BI_ID__c = 'BUY-1991231';
        
        insert objTestAccount1;
        
        Opportunity objOppty1 = new Opportunity();
        objOppty1.Name = 'Test opp1';
        objOppty1.AccountId = objTestAccount1.Id;
        objOppty1.StageName = 'Broker bidder Review';
        objOppty1.CloseDate = date.parse('11/11/2020');
        Insert objOppty1;
        
        list<integer> lstStr = new list<integer>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BrokerBidderReviewClass_mockupTest());  
        BrokerBidderReviewClass.Result obj1 = BrokerBidderReviewClass.creakeBrokerService(true, '1991231', lstStr, objOppty1.Id);
        Test.stopTest();
    }
    
}