public class IAAI_Blackbook_Value_Search {
    
    public List<IAAI_Jason_parser.Body> basicAuthCallout(Set<String> vinSet){
        HttpRequest req = new HttpRequest();
        
         IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'BLACKBOOK'] ; 

        req.setEndpoint(imdt.Endpoint__c);
        req.setMethod('POST');
        
       
        req.setHeader('Content-Length','');
        req.setTimeout(120000);
        req.setHeader('AuthenticationKey', imdt.UserName__c);
  		req.setHeader('ApplicationId', imdt.Password__c);
  		req.setHeader('Content-Type', 'application/json');
      
        String newbody;
        
        List<IAAI_Jason_parser.keyVin> keywinList = new List<IAAI_Jason_parser.keyVin>();
        Integer key = 1;
        for(String s : vinSet){
            IAAI_Jason_parser.keyVin kv = new IAAI_Jason_parser.keyVin();
            kv.key = key;
            kv.vin = s;
            keywinList.add(kv);
            key++;
        }
        newbody = JSON.serialize(keywinList);
        String body = '{'+
                        '"vehicles":';
                        body=body+newbody+
                       ','+
                        '"forceAPICheck":true'+
						'}';
        
        
        req.setBody(body);
        Http http = new Http();
         IAAI_Jason_parser a = new IAAI_Jason_parser();
        if(!Test.isRunningTest()){
        	HTTPResponse res = http.send(req);
        	a = IAAI_Jason_parser.parse(res.getBody());
        }else{
            IAAI_Jason_parser.Body bo = new IAAI_Jason_parser.Body(); 
            IAAI_Jason_parser.Request rq = new IAAI_Jason_parser.Request();
            rq.VIN = '1ZVFT80NX65140951';
            bo.Request = rq;
            bo.WholeACV = 0;
            bo.RetailACV = 0;
            list<IAAI_Jason_parser.Body> lbd = new list<IAAI_Jason_parser.Body>();
            lbd.add(bo);
			a.Body = lbd;
        }
        //System.debug('BlackBook APi Response >> '+res.getBody());
        
        List<IAAI_Jason_parser.Body> listBody = new List<IAAI_Jason_parser.Body>();
         System.debug('--- a.body----- '+a.Body);
        for(IAAI_Jason_parser.Body b : a.Body){
            IAAI_Jason_parser.Body ib = new IAAI_Jason_parser.Body();
            
            ib.V = b.Request.VIN;
            ib.WholeACV = b.WholeACV;
            ib.RetailACV = b.RetailACV;
         listBody.add(ib);   

        }
         
       return listBody;    
    }


}