/**
* @author LevDigital
* @date 2021
*
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
*
* @description MultiMockUtility class for testing callouts
*
*/

@IsTest
public class MultiMockUtility implements HttpCalloutMock {
    public List<List<String>> responseList = new List<List<String>>();
    public String responseContentType = 'application/json';
    public String responseStatus;
    Integer responseIdx = 0;
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', responseContentType);
        if (responseList.get(responseIdx) != null) {
            List<String> respList =  responseList.get(responseIdx);
            res.setBody(respList.get(0));
            if(respList.size() > 1){
                res.setStatusCode(Integer.valueOf(respList.get(1)));
                if(respList.size() ==2){
                    res.setStatus('OK');
                }else{
                    res.setStatus(respList.get(2));
                }                
            }else{
                res.setStatusCode(200);
                res.setStatus('OK');
            }            
            responseIdx++;
        }
        return res;
    }
}