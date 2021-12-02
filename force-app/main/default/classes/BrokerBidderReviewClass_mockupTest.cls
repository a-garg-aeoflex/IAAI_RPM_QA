@isTest
global class BrokerBidderReviewClass_mockupTest implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
            response.setBody(' {"TransactionID": "1a930cc0-56f6-4554-80c2-a75f373d0c8c","CreatedTime": "6/16/2020 10:33:49 AM","SentFrom": "IAAI","SentTo": "SCRM","TransactionType": "IAAI_BUYER_BROKER_CREATE", "Version": "V1.0","Result": {"ErrorCode": "000","ErrorDescription": "successful","NewBuyerID": "9879" }}');
        response.setStatusCode(200);
         response.setStatus('OK');
        return response; 
    }
  

}