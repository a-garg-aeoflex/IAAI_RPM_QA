@isTest
global class Mockup_GoogleReCAPTCHAController_Test implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true, "challenge_ts": "2021-01-20T08:12:03Z", "hostname": "uat-help.iaai.com"}'); 
        response.setStatus('OK');
        response.setStatusCode(200);  
        return response; 
    }
    
}