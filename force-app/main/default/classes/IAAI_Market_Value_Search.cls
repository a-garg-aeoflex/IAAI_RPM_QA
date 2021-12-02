public class IAAI_Market_Value_Search {
    
    public  wrapVPEValue basicAuthCallout(VPE_Listings__c vp){
        HttpRequest req = new HttpRequest();
        
        IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'MARKETVALUE'] ; 
        
        req.setEndpoint(imdt.Endpoint__c);
        req.setMethod('POST');
      
        XmlStreamWriter  w = new XmlStreamWriter();
        w.writeStartDocument('utf-8','1.0');
        w.writeStartElement(null, 'ASV',null );
            w.writeStartElement(null,'TRAN_ID',null);
            w.writeCharacters('1');
            w.writeEndElement();
            w.writeStartElement(null,'VIN',null);
            w.writeCharacters(vp.VIN__c);
        	if(vp.Model_Year__c != null){
                w.writeEndElement();
                w.writeStartElement(null,'Vehicle_Year',null);
                w.writeCharacters(vp.Model_Year__c);
            }
          if(vp.Make__c != null){
                w.writeEndElement();
                w.writeStartElement(null,'Vehicle_Make',null);
                w.writeCharacters(vp.Make__c);
          }
         if(vp.Model__c != null){
            w.writeEndElement();
            w.writeStartElement(null,'Vehicle_Model',null);
            w.writeCharacters(vp.Model__c);
         }
        if(vp.Claim__c != null){
            w.writeEndElement();
            w.writeStartElement(null,'CLAIM_NO',null);
            w.writeCharacters(vp.Claim__c);
         }
            w.writeEndElement();
            w.writeStartElement(null,'LOSS_TYPE',null);
            w.writeCharacters('ALL');
            w.writeEndElement();
                if(vp.Has_Keys__c != null && vp.Has_Keys__c == 'Yes'){
                    w.writeStartElement(null,'Keys_Present ',null);
                    w.writeCharacters('ALL');
                    w.writeEndElement();
                }else if(vp.Has_Keys__c != null && vp.Has_Keys__c == 'No'){
                    w.writeStartElement(null,'Keys_Present ',null);
                    w.writeCharacters('ALL');
                    w.writeEndElement();
                }
            w.writeStartElement(null,'DAMAGE_TYPE',null);
            w.writeCharacters('RP');
            w.writeEndElement();
            w.writeStartElement(null,'VERSION',null);
            w.writeCharacters('6.0');
            w.writeEndElement();
            w.writeStartElement(null,'STATE_CODE',null);
            w.writeCharacters('ALL');
            w.writeEndElement();
            w.writeStartElement(null,'TRANSACTION_TYPE',null);
            w.writeCharacters('IAAI_ASV_DETAILS');
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
        
            String xmlStringxmlRes = w.getXmlString();    
			w.close();
        
        Blob headerValue = Blob.valueOf(imdt.UserName__c + ':' + imdt.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Content-Length',String.valueOf(xmlStringxmlRes.length()));
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Authorization', authorizationHeader);
      
        req.setBody(xmlStringxmlRes);
    
        Http http = new Http();
 		DOM.Document document = new DOM.Document();
        if(!Test.isRunningTest()){
        		HTTPResponse res = http.send(req);
        		document.load(res.getBody());
        }else{
                document.load(xmlStringxmlRes);
        }
        

        String ASP = document.getRootElement()
            .getChildElement('AVERAGE_SALE_PRICE', null) !=null ? document.getRootElement()
            .getChildElement('AVERAGE_SALE_PRICE', null)
            .getText():'0';
        String HSP = document.getRootElement()
            .getChildElement('HIGHEST_SALE_PRICE', null) != null ? document.getRootElement()
            .getChildElement('HIGHEST_SALE_PRICE', null)
            .getText():'0';
        String LSP = document.getRootElement()
            .getChildElement('LOWEST_SALE_PRICE', null) !=null ? document.getRootElement()
            .getChildElement('LOWEST_SALE_PRICE', null)
            .getText():'0';
        
        String MRSD = document.getRootElement()
            .getChildElement('MOST_RECENT_SALE_DATE', null) !=null ? document.getRootElement()
            .getChildElement('MOST_RECENT_SALE_DATE', null)
            .getText(): null;
        System.debug('MRSD>>'+MRSD);
        
        date myDate = date.newInstance(date.today().year(), date.today().month(), date.today().day());
		date newDate = myDate.addMonths(-6);
                if(MRSD != null && MRSD != '0' && MRSD < newDate.format()){
                    ASP = '0';
                    HSP = '0';
                    LSP = '0';
                }else{
                    
                }
                
        wrapVPEValue wv = new wrapVPEValue(ASP,HSP,LSP,MRSD);
            return wv;
    }
    
    public class wrapVPEValue {
        public String Average_Sale_Price {get; set;}
        public String Highest_Sale_Price {get; set;}
        public String Lowest_Sale_Price  {get; set;}
        public Date MOST_RECENT_SALE_DATE  {get; set;}
 
        public wrapVPEValue(String asp, String hs, String ls,String rd) {
            Average_Sale_Price = asp;
            Highest_Sale_Price = hs;
            Lowest_Sale_Price = ls;
            if(rd != null){
                try{
                MOST_RECENT_SALE_DATE = Date.valueOf(rd);
                }catch(Exception e){
                   MOST_RECENT_SALE_DATE = null; 
                }
            }else{
                MOST_RECENT_SALE_DATE = null;
            }
            
            
        }
    }
    
}