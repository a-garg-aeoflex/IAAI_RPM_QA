@isTest
global class UserSubscriptionMockupCls implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        String json = '[{\"user\":{\"buyerId\":\"9327\"},\"subscriptionId\":\"101\",\"subscriptionName\":\"Tire Thread Depth\",\"subscribedDate\":\"2020-11-19T23:22:02.51825+00:00\",\"unSubscribedDate\":null,\"renewalDate\":\"2020-12-19T23:22:02.51825+00:00\",\"payment\":{\"ccId\":\"223492\",\"ppId\":\"\",\"paymentMethods\":\"CC\",\"amount\":2501.0,\"paymentType\":\"Regular\"},\"subscriptionStatus\":\"RenewalPending\",\"pageSource\":\"RenewalPPHandler\",\"deviceType\":\"MobileBrowser\",\"fee_Type_Code\":null,\"subscriptionCMSId\":\"123ljkupdate100\"},{\"user\":{\"buyerId\":\"9327\"},\"subscriptionId\":\"104\",\"subscriptionName\":\"Premium vehicle repor\",\"subscribedDate\":\"2020-11-19T23:22:02.51825+00:00\",\"unSubscribedDate\":null,\"renewalDate\":\"2020-12-19T23:22:02.51825+00:00\",\"payment\":{\"ccId\":\"223492\",\"ppId\":\"\",\"paymentMethods\":\"CC\",\"amount\":2501.0,\"paymentType\":\"Regular\"},\"subscriptionStatus\":\"RenewalPending\",\"pageSource\":\"RenewalPPHandler\",\"deviceType\":\"MobileBrowser\",\"fee_Type_Code\":null,\"subscriptionCMSId\":\"123ljkupdate100\"}]';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}