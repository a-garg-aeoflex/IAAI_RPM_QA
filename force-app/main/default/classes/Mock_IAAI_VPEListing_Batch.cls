@IsTest
public class Mock_IAAI_VPEListing_Batch implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    
    public Mock_IAAI_VPEListing_Batch(Integer code, String status, String body,
                             Map<String, String> responseHeaders) {
                                 this.code = code;
                                 this.status = status;
                                 this.bodyAsString = body;
                                 this.responseHeaders = responseHeaders;
                             }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        resp.setBody(bodyAsString);
        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
            }
        }
        system.debug(' --- '+resp);
        return resp;
    }
}