@isTest
global class UnlinkServiceMock implements HttpCalloutMock {
    public Boolean success = false;
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('in mock. Success: ' + success);
        HttpResponse res = new HttpResponse();
        if(success){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"buyerID": 519078, "isAuctionAccessUnlinked": true, "responseCode": "1", "responseDescription": "Buyer has been Unlinked from AuctionACCESS membership." }');
            res.setStatus('OK');
            res.setStatusCode(200);
        }
        else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"buyerID": 5, "isAuctionAccessUnlinked": false, "responseCode": "-1", "responseDescription": "Unlinking was not successful."}');
            res.setStatus('OK');
            res.setStatusCode(200);
        }
      
        return res;
    }
}