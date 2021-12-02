public class IAAI_PredictedPriceCalloutClass {

    
    public static String getToken(){
           
            String tokenEndpoint = '';
            String clientId = '';
            String clientSecret = '';
            String scope = '';
            String grantType = 'Client_Credentials';
        	
        	for(Predicted_Price_Credentials__mdt ppcm : [SELECT clientID__c,ClientSecret__c,DeveloperName,Endpoint__c,Id,Scope__c FROM Predicted_Price_Credentials__mdt]){
              
                if(ppcm.DeveloperName  =='PPToken'){
                       tokenEndpoint =  ppcm.Endpoint__c;
                       clientId =  ppcm.clientID__c;
                       clientSecret =  ppcm.ClientSecret__c;
                       scope =  ppcm.Scope__c;
                }
            }
        
            http h1 = new http();
            HttpRequest httpRequest1 = new HttpRequest();
            httpRequest1.setEndpoint(tokenEndpoint);
            httpRequest1.setMethod('POST');
            httpRequest1.setBody('grant_type=' + grantType + 
                    '&client_id=' + clientId + 
                    '&client_secret=' + clientSecret + 
                    '&Scope=' + scope);        

          //sending the json to the request body
        if(!Test.isRunningTest()){  
             httpResponse response1 = h1.send(httpRequest1); 
            system.debug('## response:' + response1);
        
            if(response1.getStatusCode() == 200){ 
                String aToken = '';
                JsonParser resBody = Json.createParser(response1.getBody());
                while (resBody.nextToken() != null) {
                if ((resBody.getCurrentToken() == JSONToken.FIELD_NAME) &&  (resBody.getText() == 'access_token')) { resBody.nextToken(); aToken = resBody.getText(); }
                }
                return aToken ;
               }else{
                   return null; 
                }
        }else{
            return 'nothing';
        }
    }
    
    @auraEnabled
    public static VPE_Listings__c getPPrice(VPE_Listings__c objVPE){
       String token = getToken();
       system.debug('----009---'+token);
        if(token != null){
            return getPredictedPrice(objVPE, token);
        }else{
            return null;
        }
         
   }
    
    
    
    public static VPE_Listings__c getPredictedPrice(VPE_Listings__c objVpe ,String authToken){
      Decimal vehicleConditionGrade;
      DateTime assignmentDate; 
        if(objVpe.Vehicle_Condition_Grade__c != null){
            vehicleConditionGrade = objVpe.Vehicle_Condition_Grade__c;
        }else{
            vehicleConditionGrade = 3.5;
        }
        
        if(objVpe.createddate != null){
            assignmentDate = objVpe.createddate;
        }else{
            assignmentDate = system.now();
        }
        
     String bodyToSend = '{"sender": "SFDC","sellerType": "SDS","sellerGroupName": "VRD Titlemax","vin": "'+objVpe.VIN__c+'",'+
       +'"vehicleConditionGrade":'+vehicleConditionGrade+',"lossTypeCode": "'+objVpe.Loss_Type_Code__c+'","primaryDamage": "'+objVpe.Primary_Damage__c+'","secondaryDamage": "'+objVpe.Secondary_Damage__c+'",'+
       +'"engineStatusCode": "'+objVpe.Engine_Status_Code__c+'","assignmentDate": "'+assignmentDate+'","mileage": "'+Integer.valueof(objVpe.Mileage__c)+'",'+
	   +'"isMissingParts": 1,"isKeysPresent": 1,"is360Images": 1,"blackBookACV": 12000,"isBuyerViewed360Image": 1,"odometerType": "0","locationZip": 90210,"saleDocumentType": "Clear","saleDate": "2020-08-20T14:03:39.757Z"}';
           system.debug('---Body To Send :'+bodyToSend.substring(0, 245));
            system.debug(bodyToSend.substring(245, bodyToSend.length()));
             
        String PPAPIToken = '';
        for(Predicted_Price_Credentials__mdt ppcm : [SELECT clientID__c,ClientSecret__c,DeveloperName,Endpoint__c,Id,Scope__c FROM Predicted_Price_Credentials__mdt]){
              
                if(ppcm.DeveloperName  =='PPAPI'){
                       PPAPIToken =  ppcm.Endpoint__c;
                }
            }   
            
            http h = new http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(PPAPIToken);
            httpRequest.setMethod('POST');
            httpRequest.setHeader('Content-Type', 'application/json');            
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Length', '<calculated when request is sent>');
            httpRequest.setHeader('Authorization','Bearer '+authToken);
            //httpRequest.setHeader('Host','<calculated when request is sent>');
           
            httpRequest.setBody(bodyToSend);
            
            HttpResponse response = new HttpResponse();
        
        String json = '{'+
		'    \"epvResponse\": {'+
		'        \"fullStockNumber\": \"NONE\",'+
		'        \"stockID\": 0,'+
		'        \"vin\": \"3P3BK46KXKT968258\",'+
		'        \"year\": 1989,'+
		'        \"make\": \"PLYMOUTH\",'+
		'        \"model\": \"RELIANT\",'+
		'        \"series\": \"LE\",'+
		'        \"engineDescription\": \"2.5L I4 FI  F\",'+
		'        \"vehicleClass\": \"Non Luxury Traditional Compact\",'+
		'        \"fuelType\": \"Gas\",'+
		'        \"driveLine\": \"FWD\",'+
		'        \"cylinders\": \"4\",'+
		'        \"transmissionType\": \"Manual\",'+
		'        \"predictedPrice\": 1150.0,'+
		'        \"errorRange\": 0.252551,'+
		'        \"max95\": 1730.8673,'+
		'        \"min95\": 569.1326999999999,'+
		'        \"max75\": 1483.9986975,'+
		'        \"min75\": 816.0013025000001,'+
		'        \"max68\": 1440.43365,'+
		'        \"min68\": 859.56635,'+
		'        \"filterCode\": 0,'+
		'        \"filterCodeDescription\": \"\"'+
		'    },'+
		'    \"referenceId\": \"4bc10ee5482b3742b71c25a4c5ebfff9\",'+
		'    \"status\": \"ACCEPT\",'+
		'    \"rejectReasonCode\": null,'+
		'    \"rejectReasonDescription\": null'+
		'}';
        
         String j;
          if(!Test.isRunningTest()){  
            response = h.send(httpRequest);
              j = response.getBody();
              
          } else{
              j = json;
          }   
        
             if(response.getStatusCode() == 200 || Test.isRunningTest()){
                 IAAI_PredictivePriceJsonResponse obj1 = IAAI_PredictivePriceJsonResponse.parse(j);
                 IAAI_PredictivePriceJsonResponse.EpvResponse o1 =   obj1.EpvResponse;
                 if(o1 != null) {
                     objVpe.Predicted_Price__c = o1.predictedPrice;
                     objVpe.Model_Year__c = String.valueof(o1.year);
                     objVpe.Make__c = o1.make;
                     objVpe.Model__c = o1.model;
                     objVpe.Series__c = o1.series;
                     objVpe.Max95__c = o1.Max95; 
                     objVpe.Min95__c = o1.Min95;
                     objVpe.Max75__c = o1.Max75;
                     objVpe.Min75__c = o1.Min75; 
                     objVpe.Max68__c = o1.Max68;
                     objVpe.Min68__c = o1.Min68;  
                     objVpe.Predicted_Price_status__c = 'Success';   
                 } else {
                     objVpe.Predicted_Price_status__c = 'Failed :'+response.getBody() ;
                 }
             }
        	else{
                 objVpe.Predicted_Price_status__c = 'Failed :'+response.getBody() ;
            }
            
        return objVpe;
    }

      
}