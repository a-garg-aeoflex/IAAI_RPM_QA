//Generated by FuseIT WSDL2Apex (http://www.fuseit.com/Solutions/SFDC-Explorer/Help-WSDL-Parser.aspx)
//Methods Included: GetInfoByStockNumber, IAAI_ASSIGNMENT_INFO
// Primary Port Class Name: BasicHttpBinding_IAssignment
public class RPM_ReleaseAssignmentController {
    private static final String s_ns0 = 'http://tempuri.org/';
    public class BasicHttpBinding_IAssignment {
        public String endpoint_x = CRC_Constants.RPM_CREDENTIALS.Endpoint__c+'/IAAI.Services/Assignment.svc';
        public Map<String, String> inputHttpHeaders_x;
        public Map<String, String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private transient String[] ns_map_type_info = new List<String>{
            'http://tempuri.org/',
            'RPM_ReleaseAssignmentController',
            'http://schemas.microsoft.com/2003/10/Serialization/',
            'schemasMicrosoftCom200310Serializat'
        };
        public String GetInfoByStockNumber(String RequestXML, String Sender) {
            RPM_ReleaseAssignmentController.GetInfoByStockNumber_element request_x = new RPM_ReleaseAssignmentController.GetInfoByStockNumber_element();
            RPM_ReleaseAssignmentController.GetInfoByStockNumberResponse_element response_x;
            request_x.RequestXML = RequestXML;
            request_x.Sender = Sender;
            
            
            // A map of key-value pairs that represent the response that the external service sends after receiving the request. In each pair, the key is a response identifier. The value is the response object, which is an instance of a type that is created as part of the auto-generated stub class.
            Map<String, RPM_ReleaseAssignmentController.GetInfoByStockNumberResponse_element> response_map_x = new Map<String, RPM_ReleaseAssignmentController.GetInfoByStockNumberResponse_element>();
            
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this, // stub - An instance of the Apex class that is auto-generated from a WSDL (the stub class).
                request_x, // request - The request to the external service. The request is an instance of a type that is created as part of the auto-generated stub class.
                response_map_x, // response
                new List<String>{
                    endpoint_x, //  the URL of the external web service
                    'http://tempuri.org/IAssignment/GetInfoByStockNumber', // The SOAP action.
                    s_ns0, // The request namespace.
                    'GetInfoByStockNumber', // The request name.
                    s_ns0, // The response namespace.
                    'GetInfoByStockNumberResponse', //  The response name.
                    'RPM_ReleaseAssignmentController.GetInfoByStockNumberResponse_element'
                } // The response type.
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetInfoByStockNumberResult;
        }
        public String IAAI_ASSIGNMENT_INFO(String RequestXML, String Sender) {
            RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFO_element request_x = new RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFO_element();
            RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFOResponse_element response_x;
            request_x.RequestXML = RequestXML;
            request_x.Sender = Sender;
            // A map of key-value pairs that represent the response that the external service sends after receiving the request. In each pair, the key is a response identifier. The value is the response object, which is an instance of a type that is created as part of the auto-generated stub class.
            Map<String, RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFOResponse_element> response_map_x = new Map<String, RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this, // stub - An instance of the Apex class that is auto-generated from a WSDL (the stub class).
                request_x, // request - The request to the external service. The request is an instance of a type that is created as part of the auto-generated stub class.
                response_map_x, // response
                new List<String>{
                    endpoint_x, //  the URL of the external web service
                    'http://tempuri.org/IAssignment/IAAI_ASSIGNMENT_INFO', // The SOAP action.
                    s_ns0, // The request namespace.
                    'IAAI_ASSIGNMENT_INFO', // The request name.
                    s_ns0, // The response namespace.
                    'IAAI_ASSIGNMENT_INFOResponse', //  The response name.
                    'RPM_ReleaseAssignmentController.IAAI_ASSIGNMENT_INFOResponse_element'
                } // The response type.
            );
            response_x = response_map_x.get('response_x');
            return response_x.IAAI_ASSIGNMENT_INFOResult;
        }
    }
    public class GetInfoByStockNumber_element {
        public String RequestXML;
        public String Sender;
        private transient String[] RequestXML_type_info = new List<String>{ 'RequestXML', s_ns0, 'string', '0', '1', 'true' };
        private transient String[] Sender_type_info = new List<String>{ 'Sender', s_ns0, 'string', '0', '1', 'true' };
        private transient String[] apex_schema_type_info = new List<String>{ s_ns0, 'true', 'false' };
        private transient String[] field_order_type_info = new List<String>{ 'RequestXML', 'Sender' };
    }
    public class GetInfoByStockNumberResponse_element {
        public String GetInfoByStockNumberResult;
        private transient String[] GetInfoByStockNumberResult_type_info = new List<String>{
            'GetInfoByStockNumberResult',
            s_ns0,
            'string',
            '0',
            '1',
            'true'
        };
        private transient String[] apex_schema_type_info = new List<String>{ s_ns0, 'true', 'false' };
        private transient String[] field_order_type_info = new List<String>{ 'GetInfoByStockNumberResult' };
    }
    public class IAAI_ASSIGNMENT_INFO_element {
        public String UserName;
        public String Password;
        public String RequestXML;
        public String Sender;
        private transient String[] RequestXML_type_info = new List<String>{ 'RequestXML', s_ns0, 'string', '0', '1', 'true' };
        private transient String[] Sender_type_info = new List<String>{ 'Sender', s_ns0, 'string', '0', '1', 'true' };
        private transient String[] apex_schema_type_info = new List<String>{ s_ns0, 'true', 'false' };
        private transient String[] field_order_type_info = new List<String>{ 'RequestXML', 'Sender' };
    }
    public class IAAI_ASSIGNMENT_INFOResponse_element {
        public String IAAI_ASSIGNMENT_INFOResult;
        private transient String[] IAAI_ASSIGNMENT_INFOResult_type_info = new List<String>{
            'IAAI_ASSIGNMENT_INFOResult',
            s_ns0,
            'string',
            '0',
            '1',
            'true'
        };
        private transient String[] apex_schema_type_info = new List<String>{ s_ns0, 'true', 'false' };
        private transient String[] field_order_type_info = new List<String>{ 'IAAI_ASSIGNMENT_INFOResult' };
    }
}