//Generated by wsdl2apex

public class AsapWsdl {
    public class ProcessStandardAssignmentResponse_element {
        public String ProcessStandardAssignmentResult;
        private String[] ProcessStandardAssignmentResult_type_info = new String[]{'ProcessStandardAssignmentResult','http://localhost/assignment',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://localhost/assignment','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessStandardAssignmentResult'};
    }
    public class funProcessAssignment_element {
        public String strInputXML;
        public String Sender;
        public String password;
        private String[] strInputXML_type_info = new String[]{'strInputXML','http://localhost/assignment',null,'0','1','true'};
        private String[] Sender_type_info = new String[]{'Sender','http://localhost/assignment',null,'0','1','true'};
        private String[] password_type_info = new String[]{'password','http://localhost/assignment',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://localhost/assignment','true','false'};
        private String[] field_order_type_info = new String[]{'strInputXML','Sender','password'};
   
    }
    public class funProcessAssignmentResponse_element {
        public String funProcessAssignmentResult;
        private String[] funProcessAssignmentResult_type_info = new String[]{'funProcessAssignmentResult','http://localhost/assignment',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://localhost/assignment','true','false'};
        private String[] field_order_type_info = new String[]{'funProcessAssignmentResult'};
    }
    /*public class ProcessStandardAssignment_element {
        public String InputXML;
        public String UserID;
        public String Password;
        private String[] InputXML_type_info = new String[]{'InputXML','http://localhost/assignment',null,'0','1','true'};
        private String[] UserID_type_info = new String[]{'UserID','http://localhost/assignment',null,'0','1','true'};
        private String[] Password_type_info = new String[]{'Password','http://localhost/assignment',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://localhost/assignment','true','false'};
        private String[] field_order_type_info = new String[]{'InputXML','UserID','Password'};
    }*/
    public class BasicHttpBinding_assignment {
        public String endpoint_x; //= 'http://uat.eai.iaai.com/AssignmentSVC/Assignment.svc';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://localhost/assignment', 'AsapWsdl', 'http://schemas.microsoft.com/2003/10/Serialization/', 'schemasMicrosoftCom200310Serializat'};
       
           
            
        public String funProcessAssignment(String strInputXML) {
            AsapWsdl.funProcessAssignment_element request_x = new AsapWsdl.funProcessAssignment_element();
            IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'ASAP'] ; 
            request_x.strInputXML = strInputXML;
            request_x.Sender = imdt.UserName__c;
            request_x.password = imdt.Password__c;
            endpoint_x = imdt.Endpoint__c;
            AsapWsdl.funProcessAssignmentResponse_element response_x;
            Map<String, AsapWsdl.funProcessAssignmentResponse_element> response_map_x = new Map<String, AsapWsdl.funProcessAssignmentResponse_element>();
            response_map_x.put('response_x', response_x);
            
            if(Test.isRunningTest()){
                AsapWsdl.ProcessStandardAssignmentResponse_element a = new  AsapWsdl.ProcessStandardAssignmentResponse_element();
                AsapWsdl.funProcessAssignmentResponse_element b = new AsapWsdl.funProcessAssignmentResponse_element();
                return  '<STAGING>' 
    					+'<ASSIGNMENT_TYPE>STD</ASSIGNMENT_TYPE>'
    					+'<INS_CO_CD>PULS</INS_CO_CD>'
    					+'<INS_CO_OFFICE_CD>PM</INS_CO_OFFICE_CD>'
    					+'<INS_CO_NAME>PULS</INS_CO_NAME>'
    					+'<SENDER>VPES</SENDER>'
    					+'<VIN>1ZVFT80NX65140921</VIN>'
    					+'<VEH_LOC_ZIP>12001</VEH_LOC_ZIP>'
    			+'</STAGING>';
            }else{
                WebServiceCallout.invoke(this,request_x,response_map_x,new String[]{endpoint_x,'http://localhost/assignment/funProcessAssignment','http://localhost/assignment','funProcessAssignment','http://localhost/assignment',
              'funProcessAssignmentResponse',
              'AsapWsdl.funProcessAssignmentResponse_element'}
            );
            	response_x = response_map_x.get('response_x');
            	return response_x.funProcessAssignmentResult;
            }
        }
    }
}