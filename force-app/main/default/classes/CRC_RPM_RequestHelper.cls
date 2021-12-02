public class CRC_RPM_RequestHelper {

    public static String createStorageLocationRequest(Map<String, Object> data) {
        List<Object> hours = (List<Object>) JSON.deserializeUntyped(JSON.serialize(data.get('hours')));
        Map<String, Object> sundayHours = (Map<String, Object>) hours.get(0);
        Map<String, Object> mondayHours = (Map<String, Object>) hours.get(1);
        Map<String, Object> tuesdayHours = (Map<String, Object>) hours.get(2);
        Map<String, Object> wednesdayHours = (Map<String, Object>) hours.get(3);
        Map<String, Object> thursdayHours = (Map<String, Object>) hours.get(4);
        Map<String, Object> fridayHours = (Map<String, Object>) hours.get(5);
        Map<String, Object> saturdayHours = (Map<String, Object>) hours.get(6);

        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartElement(null, 'IAAI_STORAGE_LOCATION_MAINTENANCE', null);
            writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_storage_location_maintenance/');
            writer.writeAttribute(null, null, 'xmlns:xsi', 'http://eai.iaa.com/AssignmentRelease/iaai_storage_location_maintenance/');

            writer.writeStartElement(null, 'TRAN_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CREATE_DATETIME', null);
                writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
            writer.writeEndElement();

            writer.writeStartElement(null, 'SENT_FROM', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'VERSION', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                writer.writeCharacters('STOR LOC ADD');
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                writer.writeCharacters(UserInfo.getName());
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                writer.writeCData(UserInfo.getName());
            writer.writeEndElement();

            writer.writeStartElement(null, 'STORAGE_DTL', null);
                
                writer.writeStartElement(null, 'CHECKSUM', null);
                    writer.writeCharacters('0');
                writer.writeEndElement();

                writer.writeStartElement(null, 'VEHICLE_LOCATION', null);
                    writer.writeStartElement(null, 'PICKUP_LOCATION_TYPE', null);
                        writer.writeCData(data.containsKey('PICKUP_LOCATION_TYPE') ? String.valueOf(data.get('PICKUP_LOCATION_TYPE')) : '');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'STORAGE_LOCATION_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'TEMP_STORAGE_LOCATION_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_VALIDATION_STATUS', null);
                        writer.writeCharacters(Boolean.valueOf(data.get('SL_VALIDATION')) ? 'Y' : 'N');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_CONTACT_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_ADDRESS_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_STATUS', null);
                        writer.writeCData(data.containsKey('SL_STATUS') ? String.valueOf(data.get('SL_STATUS')) : '');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_FEDERAL_EIN', null);
                        writer.writeCData(data.containsKey('SL_FEDERAL_EIN') ? String.valueOf(data.get('SL_FEDERAL_EIN')) : '');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_CASH_ONLY', null);
                        writer.writeCharacters(Boolean.valueOf(data.containsKey('SL_CASH_ONLY') ? String.valueOf(data.get('SL_CASH_ONLY')) : 'false') ? 'Y' : 'N');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_TOWER_CHECK', null);
                        writer.writeCharacters(Boolean.valueOf(data.containsKey('SL_TOWER_CHECK') ? String.valueOf(data.get('SL_TOWER_CHECK')) : 'false') ? 'Y' : 'N');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_CHECK_PAYABLE_TO', null);
                        writer.writeCData(data.containsKey('SL_CHECK_PAYABLE_TO') ? String.valueOf(data.get('SL_CHECK_PAYABLE_TO')) : '');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_CALL_BEFORE_PICKUP', null);
                        writer.writeCharacters(Boolean.valueOf(data.containsKey('SL_CALL_BEFORE_PICKUP') ? String.valueOf(data.get('SL_CALL_BEFORE_PICKUP')) : 'false') ? 'Y' : 'N');
                    writer.writeEndElement();
                    
                    if(data.get('hours') != null) {
                        writer.writeStartElement(null, 'SL_HOURS_OF_OPERATION', null);
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('1');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(sundayHours.get('Sunday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(sundayHours.get('Sunday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(sundayHours.get('Sunday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(sundayHours.get('Sunday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(sundayHours.get('Sunday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(sundayHours.get('Sunday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('2');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(mondayHours.get('Monday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(mondayHours.get('Monday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(mondayHours.get('Monday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(mondayHours.get('Monday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(mondayHours.get('Monday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(mondayHours.get('Monday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('3');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(tuesdayHours.get('Tuesday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(tuesdayHours.get('Tuesday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(tuesdayHours.get('Tuesday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(tuesdayHours.get('Tuesday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(tuesdayHours.get('Tuesday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(tuesdayHours.get('Tuesday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('4');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(wednesdayHours.get('Wednesday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(wednesdayHours.get('Wednesday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(wednesdayHours.get('Wednesday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(wednesdayHours.get('Wednesday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(wednesdayHours.get('Wednesday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(wednesdayHours.get('Wednesday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('5');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(thursdayHours.get('Thursday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(thursdayHours.get('Thursday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(thursdayHours.get('Thursday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(thursdayHours.get('Thursday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(thursdayHours.get('Thursday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(thursdayHours.get('Thursday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('6');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(fridayHours.get('Friday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(fridayHours.get('Friday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(fridayHours.get('Friday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(fridayHours.get('Friday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(fridayHours.get('Friday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(fridayHours.get('Friday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'HOURS', null);
                                writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                    writer.writeCharacters('7');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                    writer.writeCharacters(saturdayHours.get('Saturday_Open_From__c') == null ? '2001-01-01T00:00:00' : String.valueOf(saturdayHours.get('Saturday_Open_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                    writer.writeCharacters(saturdayHours.get('Saturday_Closed_At__c') == null ? '2001-01-01T00:00:00' : String.valueOf(saturdayHours.get('Saturday_Closed_At__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                    writer.writeCharacters(String.valueOf(saturdayHours.get('Saturday_Unavailable_From__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                    writer.writeCharacters(String.valueOf(saturdayHours.get('Saturday_Unavailable_To__c')));
                                writer.writeEndElement();
                            writer.writeEndElement();
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SL_RELEASE_REQUIREMENTS')) {
                        Map<String, Object> rrMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_RELEASE_REQUIREMENTS')));
                        writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENTS', null);
                            for (String key : rrMap.keySet()) {

                                writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENT', null);
                                    writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENT_CODE', null);
                                        writer.writeCData(key);
                                    writer.writeEndElement();
                                writer.writeEndElement();   
                            }
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'SL_VALIDATED_USING_STANDARDIZED_ADDRESS', null);
                        writer.writeCharacters('N');
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'CONTACT', null);
                        writer.writeStartElement(null, 'COMPANY_NAME', null);
                            writer.writeCData(data.containsKey('CONTACT.COMPANY_NAME') ? String.valueOf(data.get('CONTACT.COMPANY_NAME')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'ADDRESS_LINE1', null);
                            writer.writeCData(data.containsKey('CONTACT.ADDRESS_LINE1') ? String.valueOf(data.get('CONTACT.ADDRESS_LINE1')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'ADDRESS_LINE2', null);
                            writer.writeCData(data.containsKey('CONTACT.ADDRESS_LINE2') ? String.valueOf(data.get('CONTACT.ADDRESS_LINE2')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'CITY', null);
                            writer.writeCData(data.containsKey('CONTACT.CITY') ? String.valueOf(data.get('CONTACT.CITY')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'STATE', null);
                            writer.writeCData(data.containsKey('CONTACT.STATE') ? String.valueOf(data.get('CONTACT.STATE')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'ZIP', null);
                            writer.writeCData(data.containsKey('CONTACT.ZIP') ? String.valueOf(data.get('CONTACT.ZIP')) : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'COUNTRY_CODE', null);
                            writer.writeCData((data.containsKey('CONTACT.COUNTRY_CODE') ? String.valueOf(data.get('CONTACT.COUNTRY_CODE')) : ''));
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'PHONE_NUMBER1', null);
                            writer.writeCData(data.containsKey('CONTACT.PHONE_NUMBER1') ? String.valueOf(data.get('CONTACT.PHONE_NUMBER1')) : '');
                        writer.writeEndElement();
                        
                        writer.writeStartElement(null, 'FAX_NUMBER', null);
                            writer.writeCData(data.containsKey('CONTACT.FAX_NUMBER') ? String.valueOf(data.get('CONTACT.FAX_NUMBER')) : '');
                        writer.writeEndElement();
                        
                        writer.writeStartElement(null, 'EMAIL', null);
                            writer.writeCData(data.containsKey('CONTACT.EMAIL') ? String.valueOf(data.get('CONTACT.EMAIL')) : '');
                        writer.writeEndElement();

                    writer.writeEndElement();

                    writer.writeStartElement(null, 'MAILING_ADDRESS', null);
                        writer.writeStartElement(null, 'CONTACT', null);
                            writer.writeStartElement(null, 'ADDRESS_LINE1', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.ADDRESS_LINE1') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.ADDRESS_LINE1')) : '');
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'ADDRESS_LINE2', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.ADDRESS_LINE2') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.ADDRESS_LINE2')) : '');
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'CITY', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.CITY') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.CITY')) : 'CITY');
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'STATE', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.STATE') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.STATE')) : '');
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'ZIP', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.ZIP') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.ZIP')) : '');
                            writer.writeEndElement();
                            writer.writeStartElement(null, 'COUNTRY_CODE', null);
                                writer.writeCData(data.containsKey('MAILING_ADDRESS.CONTACT.COUNTRY_CODE') ? String.valueOf(data.get('MAILING_ADDRESS.CONTACT.COUNTRY_CODE')) : '');
                            writer.writeEndElement();
                        writer.writeEndElement();
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        
        writer.writeEndElement();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String updateStorageLocationRequest(Map<String, Object> data) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartElement(null, 'IAAI_STORAGE_LOCATION_MAINTENANCE', null);
            writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_storage_location_maintenance/');
            writer.writeAttribute(null, null, 'xmlns:xsi', 'http://eai.iaa.com/AssignmentRelease/iaai_storage_location_maintenance/');

            writer.writeStartElement(null, 'TRAN_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CREATE_DATETIME', null);
                writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
            writer.writeEndElement();

            writer.writeStartElement(null, 'SENT_FROM', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'VERSION', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                writer.writeCharacters('STOR LOC UPDATE');
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                writer.writeCharacters(UserInfo.getName());
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                writer.writeCData(UserInfo.getName());
            writer.writeEndElement();


            writer.writeStartElement(null, 'STORAGE_DTL', null);
                
                writer.writeStartElement(null, 'CHECKSUM', null);
                    writer.writeCharacters(data.containsKey('CHECKSUM') ? String.valueOf(data.get('CHECKSUM')) : '');
                writer.writeEndElement();

                writer.writeStartElement(null, 'VEHICLE_LOCATION', null);

                    if(data.containsKey('PICKUP_LOCATION_TYPE')) {
                        Map<String, Object> pickupLocationType = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PICKUP_LOCATION_TYPE')));
                        writer.writeStartElement(null, 'PICKUP_LOCATION_TYPE', null);
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(pickupLocationType.get('ActionCode')));
                            writer.writeCData(String.valueOf(pickupLocationType.get('value')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'STORAGE_LOCATION_ID', null);
                        writer.writeCharacters(data.containsKey('STORAGE_LOCATION_ID') ? String.valueOf(data.get('STORAGE_LOCATION_ID')) : '');
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'TEMP_STORAGE_LOCATION_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SL_VALIDATION_STATUS', null);
                        if(data.containsKey('SL_VALIDATION')) {
                            Map<String, Object> validationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_VALIDATION')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(validationMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(validationMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SL_CONTACT_ID', null);
                        writer.writeCharacters('0');
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'SL_ADDRESS_ID', null);
                        // writer.writeCharacters(data.containsKey('SL_ADDRESS_ID') ? String.valueOf(data.get('SL_ADDRESS_ID')) : '');
                        writer.writeCharacters('60527');
                    writer.writeEndElement();

                    if(data.containsKey('SL_STATUS')) {
                        Map<String, Object> statusMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_STATUS')));
                        writer.writeStartElement(null, 'SL_STATUS', null);
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(statusMap.get('ActionCode')));
                            writer.writeCData(String.valueOf(statusMap.get('value')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SL_ADDRESS_LINE2')) {
                        Map<String, Object> statusMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_ADDRESS_LINE2')));
                        writer.writeStartElement(null, 'SL_ADDRESS_LINE2', null);
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(statusMap.get('ActionCode')));
                            writer.writeCData(String.valueOf(statusMap.get('value')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SL_FEDERAL_EIN')) {
                        Map<String, Object> federalMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_FEDERAL_EIN')));
                        writer.writeStartElement(null, 'SL_FEDERAL_EIN', null);
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(federalMap.get('ActionCode')));
                            writer.writeCData(String.valueOf(federalMap.get('value')));
                        writer.writeEndElement();
                    }

                    
                    writer.writeStartElement(null, 'SL_CASH_ONLY', null);
                        if(data.containsKey('SL_CASH_ONLY')) {
                            Map<String, Object> cashMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_CASH_ONLY')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(cashMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(cashMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SL_TOWER_CHECK', null);
                        if(data.containsKey('SL_TOWER_CHECK')) {
                            Map<String, Object> ccMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_TOWER_CHECK')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(ccMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(ccMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SL_IAA_CHECK', null);
                        if(data.containsKey('SL_IAA_CHECK')) {
                            Map<String, Object> ccMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_IAA_CHECK')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(ccMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(ccMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();
                
                    writer.writeStartElement(null, 'SL_IAA_CREDIT_CARD', null);
                        if(data.containsKey('SL_IAA_CREDIT_CARD')) {
                            Map<String, Object> ccMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_IAA_CREDIT_CARD')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(ccMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(ccMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();

                    if(data.containsKey('SL_CHECK_PAYABLE_TO')) {
                        Map<String, Object> checkMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_CHECK_PAYABLE_TO')));
                        writer.writeStartElement(null, 'SL_CHECK_PAYABLE_TO', null);
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(checkMap.get('ActionCode')));
                            writer.writeCharacters(String.valueOf(checkMap.get('value')));
                        writer.writeEndElement();
                    }
                    
                    writer.writeStartElement(null, 'SL_CALL_BEFORE_PICKUP', null);
                        if(data.containsKey('SL_CALL_BEFORE_PICKUP')) {
                            Map<String, Object> callBeforeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_CALL_BEFORE_PICKUP')));
                            writer.writeAttribute(null, null, 'ActionCode', String.valueOf(callBeforeMap.get('ActionCode')));
                            writer.writeCharacters(Boolean.valueOf(callBeforeMap.get('value')) ? 'Y' : 'N');
                        } else {
                            writer.writeCharacters('N');
                        }
                    writer.writeEndElement();

                    if(data.get('hours') != null) {
                        writer.writeStartElement(null, 'SL_HOURS_OF_OPERATION', null);
                        Integer a = 1;
                        List<Object> hours = (List<Object>) JSON.deserializeUntyped(JSON.serialize(data.get('hours')));
                        Map<Integer, String> getDayName = new Map<Integer, String>{
                            1     =>      'Sunday',
                            2     =>      'Monday',
                            3     =>      'Tuesday',
                            4     =>      'Wednesday',
                            5     =>      'Thursday',
                            6     =>      'Friday',
                            7     =>      'Saturday'
                        };
                        for (Object hourObject : hours) {
                            Map<String, Object> hour = (Map<String, Object>) hourObject;
                            if(hour.containsKey('actionCode')) {
                                writer.writeStartElement(null, 'HOURS', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(hour.get('actionCode')));
                                    for (Integer i = 0; i < 5; i++) {
                                        if(i == 0) {
                                            writer.writeStartElement(null, 'HOO_DAY_OF_WEEK', null);
                                                writer.writeCharacters(String.valueOf(hour.get('dayNumber')));
                                            writer.writeEndElement();
                                        } else if(i == 1) {
                                            writer.writeStartElement(null, 'HOO_OPEN_FROM', null);
                                                writer.writeCharacters(String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Open_From__c')) == null ? '2001-01-01T00:00:00' : String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Open_From__c')));
                                            writer.writeEndElement();
                                        } else if(i == 2) {
                                            writer.writeStartElement(null, 'HOO_CLOSED_AT', null);
                                                writer.writeCharacters(String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Closed_At__c')) == null ? '2001-01-01T00:00:00' : String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Closed_At__c')));
                                            writer.writeEndElement();
                                        } else if(i == 3) {
                                            writer.writeStartElement(null, 'HOO_UNAVAILABLE_FROM', null);
                                                writer.writeCharacters(String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Unavailable_From__c')) == null ? '2001-01-01T00:00:00' : String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Unavailable_From__c')));
                                            writer.writeEndElement();
                                        } else if(i == 4) {
                                            writer.writeStartElement(null, 'HOO_UNAVAILABLE_TO', null);
                                                writer.writeCharacters(String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Unavailable_To__c')) == null ? '2001-01-01T00:00:00' : String.valueOf(hour.get(String.valueOf(hour.get('dayText'))+'_Unavailable_To__c')));
                                            writer.writeEndElement();
                                        }
                                    }
                                writer.writeEndElement();
                                a++;
                            }
                        }
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SL_RELEASE_REQUIREMENTS')) {
                        Map<String, Object> rrMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SL_RELEASE_REQUIREMENTS')));
                        writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENTS', null);
                            for (String key : rrMap.keySet()) {

                                writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENT', null);
                                    writer.writeStartElement(null, 'SL_RELEASE_REQUIREMENT_CODE', null);
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(rrMap.get(key)));
                                        writer.writeCData(key);
                                    writer.writeEndElement();
                                writer.writeEndElement();   
                            }
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'SL_VALIDATED_USING_STANDARDIZED_ADDRESS', null);
                        writer.writeCharacters('N');
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'CONTACT', null);

                        if(data.containsKey('CONTACT.COMPANY_NAME')) {
                            Map<String, Object> contactCompanyNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.COMPANY_NAME')));
                            writer.writeStartElement(null, 'COMPANY_NAME', null);
                                if(String.isNotBlank(String.valueOf(contactCompanyNameMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCompanyNameMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactCompanyNameMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.FIRST_NAME')) {
                            Map<String, Object> contactCompanyNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.FIRST_NAME')));
                            writer.writeStartElement(null, 'FIRST_NAME', null);
                                if(String.isNotBlank(String.valueOf(contactCompanyNameMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCompanyNameMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactCompanyNameMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.LAST_NAME')) {
                            Map<String, Object> contactCompanyNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.LAST_NAME')));
                            writer.writeStartElement(null, 'LAST_NAME', null);
                                if(String.isNotBlank(String.valueOf(contactCompanyNameMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCompanyNameMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactCompanyNameMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.ADDRESS_LINE1')) {
                            Map<String, Object> contactAddressLineMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.ADDRESS_LINE1')));
                            writer.writeStartElement(null, 'ADDRESS_LINE1', null);
                                if(String.isNotBlank(String.valueOf(contactAddressLineMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactAddressLineMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactAddressLineMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.CITY')) {
                            Map<String, Object> contactCityMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.CITY')));
                            writer.writeStartElement(null, 'CITY', null);
                                if(String.isNotBlank(String.valueOf(contactCityMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCityMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactCityMap.get('value')));
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('CONTACT.STATE')) {
                            Map<String, Object> contactStateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.STATE')));
                            writer.writeStartElement(null, 'STATE', null);
                                if(String.isNotBlank(String.valueOf(contactStateMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactStateMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactStateMap.get('value')));
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('CONTACT.ZIP')) {
                            Map<String, Object> contactZipMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.ZIP')));
                            writer.writeStartElement(null, 'ZIP', null);
                                if(String.isNotBlank(String.valueOf(contactZipMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactZipMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactZipMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.COUNTRY_CODE')) {
                            Map<String, Object> contactCountryCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.COUNTRY_CODE')));
                            writer.writeStartElement(null, 'COUNTRY_CODE', null);
                                if(String.isNotBlank(String.valueOf(contactCountryCodeMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCountryCodeMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactCountryCodeMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.PHONE_NUMBER1')) {
                            Map<String, Object> contactPhoneNumberMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.PHONE_NUMBER1')));
                            writer.writeStartElement(null, 'PHONE_NUMBER1', null);
                                if(String.isNotBlank(String.valueOf(contactPhoneNumberMap.get('ActionCode')))) {
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactPhoneNumberMap.get('ActionCode')));
                                }
                                writer.writeCharacters(String.valueOf(contactPhoneNumberMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CONTACT.FAX_NUMBER')) {
                            Map<String, Object> contactCompanyNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.FAX_NUMBER')));
                            if(contactCompanyNameMap.containsKey('value') && String.isNotBlank(String.valueOf(contactCompanyNameMap.get('value')))) {
                                writer.writeStartElement(null, 'FAX_NUMBER', null);
                                    if(String.isNotBlank(String.valueOf(contactCompanyNameMap.get('ActionCode')))) {
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCompanyNameMap.get('ActionCode')));
                                    }
                                    writer.writeCharacters(String.valueOf(contactCompanyNameMap.get('value')));
                                writer.writeEndElement();
                            }
                        }

                        if(data.containsKey('CONTACT.EMAIL')) {
                            Map<String, Object> contactCompanyNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CONTACT.EMAIL')));
                            if(contactCompanyNameMap.containsKey('value') && String.isNotBlank(String.valueOf(contactCompanyNameMap.get('value')))) {
                                writer.writeStartElement(null, 'EMAIL', null);
                                    if(String.isNotBlank(String.valueOf(contactCompanyNameMap.get('ActionCode')))) {
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(contactCompanyNameMap.get('ActionCode')));
                                    }
                                    writer.writeCharacters(String.valueOf(contactCompanyNameMap.get('value')));
                                writer.writeEndElement();
                            }
                        }
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'MAILING_ADDRESS', null);
                        writer.writeStartElement(null, 'CONTACT', null);

                            if(data.containsKey('MAILING_ADDRESS.CONTACT.ADDRESS_LINE1')) {
                                Map<String, Object> mailingContactAddressLineMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAILING_ADDRESS.CONTACT.ADDRESS_LINE1')));
                                writer.writeStartElement(null, 'ADDRESS_LINE1', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(mailingContactAddressLineMap.get('ActionCode')));
                                    writer.writeCharacters(String.valueOf(mailingContactAddressLineMap.get('value')));
                                writer.writeEndElement();
                            }

                            if(data.containsKey('MAILING_ADDRESS.CONTACT.ADDRESS_LINE2')) {
                                Map<String, Object> mailingContactAddressLineMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAILING_ADDRESS.CONTACT.ADDRESS_LINE2')));
                                writer.writeStartElement(null, 'ADDRESS_LINE2', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(mailingContactAddressLineMap.get('ActionCode')));
                                    writer.writeCharacters(String.valueOf(mailingContactAddressLineMap.get('value')));
                                writer.writeEndElement();
                            }

                            if(data.containsKey('MAILING_ADDRESS.CONTACT.CITY')) {
                                Map<String, Object> mailingContactCityMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAILING_ADDRESS.CONTACT.CITY')));
                                writer.writeStartElement(null, 'CITY', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(mailingContactCityMap.get('ActionCode')));
                                    writer.writeCharacters(String.valueOf(mailingContactCityMap.get('value')));
                                writer.writeEndElement();
                            }
                            
                            if(data.containsKey('MAILING_ADDRESS.CONTACT.STATE')) {
                                Map<String, Object> mailingContactStateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAILING_ADDRESS.CONTACT.STATE')));
                                writer.writeStartElement(null, 'STATE', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(mailingContactStateMap.get('ActionCode')));
                                    writer.writeCharacters(String.valueOf(mailingContactStateMap.get('value')));
                                writer.writeEndElement();
                            }

                            if(data.containsKey('MAILING_ADDRESS.CONTACT.COUNTRY_CODE')) {
                                Map<String, Object> mailingContactCountryCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAILING_ADDRESS.CONTACT.COUNTRY_CODE')));
                                writer.writeStartElement(null, 'COUNTRY_CODE', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(mailingContactCountryCodeMap.get('ActionCode')));
                                    writer.writeCharacters(String.valueOf(mailingContactCountryCodeMap.get('value')));
                                writer.writeEndElement();
                            }

                        writer.writeEndElement();
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        
        writer.writeEndElement();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String assignmentUpdateRequest(Map<String, Object> data) {
        System.debug('requestjson'+JSON.serialize(data));
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT UPDATE');
                writer.writeEndElement();

                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();

                        if(data.containsKey('TYPE_OF_LOSS_CODE')) {
                            Map<String, Object> lossCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('TYPE_OF_LOSS_CODE')));
                            writer.writeStartElement(null, 'TYPE_OF_LOSS_CODE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(lossCodeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(lossCodeMap.get('value')));
                            writer.writeEndElement();
                        }
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                        
                        if(data.containsKey('VIN')) {
                            Map<String, Object> vinMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VIN')));
                            writer.writeStartElement(null, 'VIN', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(vinMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(vinMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('YEAR')) {
                            Map<String, Object> yearMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('YEAR')));
                            writer.writeStartElement(null, 'YEAR', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(yearMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(yearMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('MAKE')) {
                            Map<String, Object> makeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MAKE')));
                            writer.writeStartElement(null, 'MAKE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(makeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(makeMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('MODEL')) {
                            Map<String, Object> modelMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('MODEL')));
                            writer.writeStartElement(null, 'MODEL', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(modelMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(modelMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('COLOR')) {
                            Map<String, Object> colorMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('COLOR')));
                            writer.writeStartElement(null, 'COLOR', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(colorMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(colorMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('DRIVE')) {
                            Map<String, Object> driveMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('DRIVE')));
                            writer.writeStartElement(null, 'DRIVE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(driveMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(driveMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('FUEL_TYPE')) {
                            Map<String, Object> fuelTypeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('FUEL_TYPE')));
                            writer.writeStartElement(null, 'FUEL_TYPE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(fuelTypeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(fuelTypeMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('KEYS_INDICATOR')) {
                            Map<String, Object> keysMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('KEYS_INDICATOR')));
                            writer.writeStartElement(null, 'KEYS_INDICATOR', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(keysMap.get('ActionCode')));
                                //writer.writeCData(String.valueOf(keysMap.get('value')) == 'Yes' ? '1' : '0' );
                                writer.writeCData(String.valueOf(keysMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('LICENSE_PLATE_NUMBER')) {
                            Map<String, Object> licensePlateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('LICENSE_PLATE_NUMBER')));
                            writer.writeStartElement(null, 'LICENSE_PLATE_NUMBER', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(licensePlateMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(licensePlateMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('PRIMARY_DAMAGE_CODE')) {
                            Map<String, Object> primaryDamageCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PRIMARY_DAMAGE_CODE')));
                            writer.writeStartElement(null, 'PRIMARY_DAMAGE_CODE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(primaryDamageCodeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(primaryDamageCodeMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('SECONDARY_DAMAGE_CODE')) {
                            Map<String, Object> secondaryDamageCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('SECONDARY_DAMAGE_CODE')));
                            writer.writeStartElement(null, 'SECONDARY_DAMAGE_CODE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(secondaryDamageCodeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(secondaryDamageCodeMap.get('value')));
                            writer.writeEndElement();
                        }

                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        String lossDate = getAssignmentLossDate(data);
                        if(String.isNotBlank(lossDate)) {
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(lossDate+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();
                        
                    writer.writeStartElement(null, 'RELEASE', null);
                        if(data.containsKey('VR_RELEASED_BY_FIRST_NAME')) {
                            Map<String, Object> firstNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_RELEASED_BY_FIRST_NAME')));
                            writer.writeStartElement(null, 'VR_RELEASED_BY_FIRST_NAME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(firstNameMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(firstNameMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_RELEASED_BY_LAST_NAME')) {
                            Map<String, Object> firstNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_RELEASED_BY_LAST_NAME')));
                            writer.writeStartElement(null, 'VR_RELEASED_BY_LAST_NAME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(firstNameMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(firstNameMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_IS_VEHICLE_AT_LOCATION')) {
                            Map<String, Object> isVehicleLocationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_IS_VEHICLE_AT_LOCATION')));
                            writer.writeStartElement(null, 'VR_IS_VEHICLE_AT_LOCATION', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(isVehicleLocationMap.get('ActionCode')));
                                writer.writeCData(Boolean.valueOf(isVehicleLocationMap.get('value')) ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_VEHICLE_RELEASED')) {
                            Map<String, Object> isVehicleReleaseMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_VEHICLE_RELEASED')));
                            writer.writeStartElement(null, 'VR_VEHICLE_RELEASED', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(isVehicleReleaseMap.get('ActionCode')));
                                writer.writeCData(Boolean.valueOf(isVehicleReleaseMap.get('value')) ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_ANTICIPATED_PICKUP_DATETIME')) {
                            Map<String, Object> anticipatedDateTimeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_ANTICIPATED_PICKUP_DATETIME')));
                            writer.writeStartElement(null, 'VR_ANTICIPATED_PICKUP_DATETIME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(anticipatedDateTimeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(anticipatedDateTimeMap.get('value')).replace('.000Z', 'Z'));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME')) {
                            Map<String, Object> anticipatedDateTimeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME')));
                            writer.writeStartElement(null, 'VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                                writer.writeCData(String.valueOf(anticipatedDateTimeMap.get('value')).replace('.000Z', 'Z'));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_TITLE_IND')) {
                            Map<String, Object> anticipatedDateTimeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_TITLE_IND')));
                            writer.writeStartElement(null, 'VR_TITLE_IND', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(anticipatedDateTimeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(anticipatedDateTimeMap.get('value')));
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_CALL_BEFORE_COMING')) {
                            Map<String, Object> callBeforePickupMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_CALL_BEFORE_COMING')));
                            writer.writeStartElement(null, 'VR_CALL_BEFORE_COMING', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(callBeforePickupMap.get('ActionCode')));
                                writer.writeCData(Boolean.valueOf(callBeforePickupMap.get('value')) ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_VEHICLE_BLOCKED_IN')) {
                            Map<String, Object> vehicleBlockedInMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_VEHICLE_BLOCKED_IN')));
                            writer.writeStartElement(null, 'VR_VEHICLE_BLOCKED_IN', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(vehicleBlockedInMap.get('ActionCode')));
                                writer.writeCData(Boolean.valueOf(vehicleBlockedInMap.get('value')) ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_VEHICLE_TOWABLE')) {
                            Map<String, Object> vehicleTowableMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_VEHICLE_TOWABLE')));
                            writer.writeStartElement(null, 'VR_VEHICLE_TOWABLE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(vehicleTowableMap.get('ActionCode')));
                                writer.writeCData(Boolean.valueOf(vehicleTowableMap.get('value')) ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('VR_VEHICLE_LOCATION_CODE')) {
                            Map<String, Object> vehicleLocationCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_VEHICLE_LOCATION_CODE')));
                            writer.writeStartElement(null, 'VR_VEHICLE_LOCATION_CODE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(vehicleLocationCodeMap.get('ActionCode')));
                                writer.writeCData(String.valueOf(vehicleLocationCodeMap.get('value')));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String changeStorageLocationOnAssignment(Map<String, Object> data) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT UPDATE');
                writer.writeEndElement();

                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();

                        writer.writeStartElement(null, 'VEHICLE_LOCATION', null);
                            writer.writeStartElement(null, 'STORAGE_LOCATION_ID', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                                writer.writeCharacters(data.containsKey('STORAGE_LOCATION_ID') ? String.valueOf(data.get('STORAGE_LOCATION_ID')) : '');
                            writer.writeEndElement();    
                        writer.writeEndElement();
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        String lossDate = getAssignmentLossDate(data);
                        if(String.isNotBlank(lossDate)) {
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(lossDate+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }
    
    public static String saveReleaseProblemRequest(Map<String, Object> data, Boolean isUpdate) {
        System.debug(JSON.serialize(data));
        XmlStreamWriter writer = new XmlStreamWriter();

        writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
            writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

            writer.writeStartElement(null, 'TRAN_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CREATE_DATETIME', null);
                writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
            writer.writeEndElement();

            writer.writeStartElement(null, 'SENT_FROM', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'VERSION', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                writer.writeCharacters('ASSIGNMENT UPDATE');
            writer.writeEndElement();

            writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                writer.writeCharacters(String.valueOf(data.get('Stock__c')));
            writer.writeEndElement();
            writer.writeStartElement(null, 'SALVAGE_ID', null);
                writer.writeCharacters(String.valueOf(data.get('CRC_Salvage_Id__c')));
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_Id__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                writer.writeCharacters('csr0611');
            writer.writeEndElement();

            writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                writer.writeCData('Stinson Amy');
            writer.writeEndElement();

            writer.writeStartElement(null, 'RLSE_ASN', null);
                
                writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                    writer.writeCharacters(String.valueOf(data.get('Stock__c')));
                writer.writeEndElement();

                writer.writeStartElement(null, 'SALVAGE_ID', null);
                    writer.writeCharacters(String.valueOf(data.get('CRC_Salvage_Id__c')));
                writer.writeEndElement();

                writer.writeStartElement(null, 'CHECKSUM', null);
                    writer.writeCharacters(String.valueOf(data.get('CRC_Checksum__c')));
                writer.writeEndElement();
               

                writer.writeStartElement(null, 'SALVOR', null);
                    writer.writeStartElement(null, 'BRANCH', null);
                    writer.writeEndElement();
                writer.writeEndElement();

                writer.writeStartElement(null, 'VEHICLE', null);
                writer.writeEndElement();

                writer.writeStartElement(null, 'PROC_STATUS', null);

                    writer.writeStartElement(null, 'RELEASE_PROBLEMS', null);
                        writer.writeStartElement(null, 'RELEASE_PROBLEM', null);
                            
                            if(isUpdate == true){
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                            }else{
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                            }
                            

                                writer.writeStartElement(null, 'RELEASE_PROBLEM_CODE', null);
                                    writer.writeCharacters(String.valueOf(data.get('CRC_RP_CODE')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'RELEASE_PROBLEM_DESCRIPTION', null);
                                    writer.writeCharacters(String.valueOf(data.get('CRC_RP_CODE_DESCRIPTION')));
                                    writer.writeEndElement();

                                    writer.writeStartElement(null, 'RELEASE_PROBLEM_OPEN_DATETIME', null);
                                    System.debug('isUpdate----'+isUpdate);
                                    system.debug('-11-'+String.valueOf(data.get('CRC_Comment_DateTime__c')));
                                 if(isUpdate == true){
                                    system.debug('-1-'+data.get('CRC_Comment_DateTime__c'));
                                    system.debug('-2-'+isUpdate);
                                         writer.writeCharacters(String.valueOf(data.get('CRC_Comment_DateTime__c')));
                                    }else{
                                         writer.writeCharacters(String.valueOfGMT(System.now()).replace(' ', 'T')+'Z');
                                    }
                                    writer.writeEndElement();
                                    system.debug('-3-'+system.now());
                                    system.debug('-4-'+String.valueOfGMT(System.now()).replace(' ', 'T'));
                                    

                                if(isUpdate == true && data.get('CRC_Resolved') == true){
                                    writer.writeStartElement(null, 'RELEASE_PROBLEM_RESOLVED_DATETIME', null);
                                        writer.writeCharacters(String.valueOfGMT(System.now()).replace(' ', 'T')+'Z');
                                    writer.writeEndElement();
                                }
                                writer.writeStartElement(null, 'RELEASE_PROBLEM_LAST_WORKED_DATETIME', null);
                                    writer.writeCharacters(String.valueOfGMT(System.now()).replace(' ', 'T')+'Z');
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'RELEASE_PROBLEM_FOLLOW_UP_DATETIME', null);
                                system.debug('-4RP_Follow_Up_Date_Time__c-'+String.valueOf(data.get('RP_Follow_Up_Date_Time__c')));
                                system.debug('-4RP_Follow_Up_Date_Time__c-'+data.get('RP_Follow_Up_Date_Time__c'));
                                    writer.writeCharacters(String.valueOf(data.get('RP_Follow_Up_Date_Time__c')));
                                writer.writeEndElement();
                                writer.writeStartElement(null, 'RELEASE_PROBLEM_RESOLVED', null);

                                    if(isUpdate == true && data.get('CRC_Resolved') == true){
                                        writer.writeCharacters('Y');
                                    }else{
                                        writer.writeCharacters('N');
                                    }
                                writer.writeEndElement();
                        writer.writeEndElement(); 
                    writer.writeEndElement();

                    String lossDate = getAssignmentLossDate(data);
                    if(String.isNotBlank(lossDate)) {
                        writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'A');
                            writer.writeCData(lossDate+'T00:00:00');
                        writer.writeEndElement();

                        writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'A');
                            writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                        writer.writeEndElement();

                        writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'A');
                            writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                        writer.writeEndElement();
                    }

                writer.writeEndElement();
             writer.writeEndElement(); 
         writer.writeEndElement();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> fetchNotesCategories(){
        try {
            List<Map<String, String>> pickListValuesList= new List<Map<String, String>>();
            Schema.DescribeFieldResult fieldResult = Task.CRC_Note_Category__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(new Map<String, String>{'label' => pickListVal.getLabel(), 'value' => pickListVal.getValue()});
            }     
            return pickListValuesList;       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String vehicleOwnerUpdateRequest(Map<String, Object> data) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT UPDATE');
                writer.writeEndElement();

                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();

                        writer.writeStartElement(null, 'OWNER', null);
                            
                            writer.writeStartElement(null, 'CONTACT', null);
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.FIRST_NAME')) {
                                    writer.writeStartElement(null, 'FIRST_NAME', null);
                                        Map<String, Object> firstNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.FIRST_NAME')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(firstNameMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(firstNameMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.LAST_NAME')) {
                                    writer.writeStartElement(null, 'LAST_NAME', null);
                                        Map<String, Object> lastNameMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.LAST_NAME')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(lastNameMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(lastNameMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.ADDRESS_LINE1')) {
                                    writer.writeStartElement(null, 'ADDRESS_LINE1', null);
                                        Map<String, Object> addressLine1Map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.ADDRESS_LINE1')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(addressLine1Map.get('ActionCode')));
                                        writer.writeCData(String.valueOf(addressLine1Map.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.ADDRESS_LINE2')) {
                                    writer.writeStartElement(null, 'ADDRESS_LINE2', null);
                                        Map<String, Object> addressLine2Map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.ADDRESS_LINE2')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(addressLine2Map.get('ActionCode')));
                                        writer.writeCData(String.valueOf(addressLine2Map.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.CITY')) {
                                    writer.writeStartElement(null, 'CITY', null);
                                        Map<String, Object> cityMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.CITY')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(cityMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(cityMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.STATE')) {
                                    writer.writeStartElement(null, 'STATE', null);
                                        Map<String, Object> stateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.STATE')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(stateMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(stateMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.ZIP')) {
                                    writer.writeStartElement(null, 'ZIP', null);
                                        Map<String, Object> zipMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.ZIP')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(zipMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(zipMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.COUNTRY_CODE')) {
                                    writer.writeStartElement(null, 'COUNTRY_CODE', null);
                                        Map<String, Object> countryMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.COUNTRY_CODE')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(countryMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(countryMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_NUMBER1')) {
                                    writer.writeStartElement(null, 'PHONE_NUMBER1', null);
                                        Map<String, Object> phone1Map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_NUMBER1')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phone1Map.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phone1Map.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_NUMBER1_EXT')) {
                                    writer.writeStartElement(null, 'PHONE_NUMBER1_EXT', null);
                                        Map<String, Object> phone1ExtMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_NUMBER1_EXT')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phone1ExtMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phone1ExtMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_TYPE1')) {
                                    writer.writeStartElement(null, 'PHONE_TYPE1', null);
                                        Map<String, Object> phoneType1Map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_TYPE1')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phoneType1Map.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phoneType1Map.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_NUMBER2')) {
                                    writer.writeStartElement(null, 'PHONE_NUMBER2', null);
                                        Map<String, Object> phone2Map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_NUMBER2')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phone2Map.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phone2Map.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_NUMBER2_EXT')) {
                                    writer.writeStartElement(null, 'PHONE_NUMBER2_EXT', null);
                                        Map<String, Object> phone2ExtMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_NUMBER2_EXT')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phone2ExtMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phone2ExtMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.PHONE_TYPE2')) {
                                    writer.writeStartElement(null, 'PHONE_TYPE2', null);
                                        Map<String, Object> phone2TypeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.PHONE_TYPE2')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(phone2TypeMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(phone2TypeMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.FAX_NUMBER')) {
                                    writer.writeStartElement(null, 'FAX_NUMBER', null);
                                        Map<String, Object> faxMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.FAX_NUMBER')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(faxMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(faxMap.get('value')));
                                    writer.writeEndElement();
                                }
                            
                                if(data.containsKey('PROVIDER.OWNER.CONTACT.EMAIL')) {
                                    writer.writeStartElement(null, 'EMAIL', null);
                                        Map<String, Object> emailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('PROVIDER.OWNER.CONTACT.EMAIL')));
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(emailMap.get('ActionCode')));
                                        writer.writeCData(String.valueOf(emailMap.get('value')));
                                    writer.writeEndElement();
                                }
                            writer.writeEndElement();

                        writer.writeEndElement();
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        String lossDate = getAssignmentLossDate(data);
                        if(String.isNotBlank(lossDate)) {
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(lossDate+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String manageReleaseCharges(Map<String, Object> data) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT UPDATE');
                writer.writeEndElement();

                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        String lossDate = getAssignmentLossDate(data);
                        if(String.isNotBlank(lossDate)) {
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(lossDate+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'RELEASE', null);
                        if(data.containsKey('VR_TOTAL_CHECK_AMOUNT')) {
                            writer.writeStartElement(null, 'VR_TOTAL_CHECK_AMOUNT', null);
                                Map<String, Object> totalCheckAmount = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_TOTAL_CHECK_AMOUNT')));
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(totalCheckAmount.get('ACTION_CODE')));
                                writer.writeCharacters(String.valueOf(totalCheckAmount.get('value')));
                            writer.writeEndElement();
                        }

                        writer.writeStartElement(null, 'VR_EXPENSES', null);
                            if(data.get('charges') != null) {
                                List<Object> charges = (List<Object>) data.get('charges');
                                for (Object o : charges) {
                                    Map<String, Object> charge = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                                    writer.writeStartElement(null, 'VR_EXPENSE', null);
                                        writer.writeAttribute(null, null, 'ActionCode', String.valueOf(charge.get('ActionCode')));
        
                                        if(charge.containsKey('Charge_Type__c')) {
                                            writer.writeStartElement(null, 'VRE_CHARGE_TYPE_ID', null);
                                                writer.writeCharacters(String.valueOf(charge.get('Charge_Type__c')));
                                            writer.writeEndElement();
                                        }
        
                                        if(charge.containsKey('Event_Category__c')) {
                                            writer.writeStartElement(null, 'VRE_EVENT_CATEGORY_CODE', null);
                                                writer.writeCharacters('RLS');
                                            writer.writeEndElement();
                                        }
        
                                        if(charge.containsKey('Amount__c')) {
                                            writer.writeStartElement(null, 'VRE_AMOUNT', null);
                                                writer.writeCharacters(String.valueOf(charge.get('Amount__c')));
                                            writer.writeEndElement();
                                        }
        
                                        if(charge.containsKey('Tax_Amount__c')) {
                                            writer.writeStartElement(null, 'VRE_TAX_AMOUNT', null);
                                                writer.writeCharacters(String.valueOf(charge.get('Tax_Amount__c')));
                                            writer.writeEndElement();
                                        }
        
                                        if(charge.containsKey('Responsible_Party__c')) {
                                            writer.writeStartElement(null, 'VRE_RESPONSIBLE_PARTY_CODE', null);
                                                writer.writeCharacters(String.valueOf(charge.get('Responsible_Party__c')));
                                            writer.writeEndElement();
                                        }
        
                                    writer.writeEndElement();
                                }
                            }
                        writer.writeEndElement();
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String getStorageLocationDetail(String locationId, Boolean isTemp) {
        XmlStreamWriter writer = new XmlStreamWriter();

        writer.writeStartElement(null, 'IAAI_STOR_LOC_DETAIL', null);
            writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_stor_loc_detail/');
            writer.writeAttribute(null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');

            writer.writeStartElement(null, 'TRAN_ID', null);
                writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CREATE_DATETIME', null);
                writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
            writer.writeEndElement();

            writer.writeStartElement(null, 'SENT_FROM', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'VERSION', null);
                writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
            writer.writeEndElement();

            writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                writer.writeCharacters('STOR LOC DETAILS');
            writer.writeEndElement();

            writer.writeStartElement(null, 'STOR_LOC_DETAIL_SEARCH_CRITERIA', null);
                writer.writeStartElement(null, (isTemp ? 'TEMP_STORAGE_LOCATION_ID' : 'STORAGE_LOCATION_ID'), null);
                    writer.writeCharacters(locationId);
                writer.writeEndElement();

                writer.writeStartElement(null, 'COMPANY_NAME', null);
                    writer.writeCharacters('');
                writer.writeEndElement();
            writer.writeEndElement();
         writer.writeEndElement();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static Map<String, String> parseRPMResponse(String xmlString) {
        Dom.Document doc = new DOM.Document();
        doc.load(xmlString);
        Dom.XmlNode assignmentInfo = doc.getRootElement();
        System.debug(assignmentInfo.getChildElements());
        Map<String, String> response = new Map<String, String>();
        for (DOM.XmlNode child : assignmentInfo.getChildElements()) {
            if(child.getChildElements().size() > 0) {
                for (DOM.XmlNode grandChild : child.getChildElements()) {
                    if(grandChild.getChildElements().size() > 0) {
                        String keyName = grandChild.getName();
                        for (DOM.XmlNode grandChild1 : grandChild.getChildElements()) {
                            if(grandChild1.getChildElements().size() > 0) {
                                // System.debug('-------------------'+grandChild1.getName()+'-->'+grandChild1.getChildElements());
                            } else {
                                response.put(keyName+'.'+grandChild1.getName(), grandChild1.getText());
                            }
                        }
                    } else {
                        response.put(grandChild.getName(), grandChild.getText());
                    }
                }
            } else {
                response.put(child.getName(), child.getText());
            }
        }
        System.debug(JSON.serialize(response));
        return response;
    }

    public static String saveStorageChargesFlatOrDaily(Map<String, Object> data) {
        System.debug(JSON.serialize(data));
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT UPDATE');
                writer.writeEndElement();

                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        if(data.containsKey('IAA_Requested_to_Pay_Advance_Charges__c')) {
                            Map<String, Object> authorizedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('IAA_Requested_to_Pay_Advance_Charges__c')));
                            writer.writeStartElement(null, 'IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                                writer.writeCharacters(Boolean.valueOf(authorizedMap.get('value')) == true ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        Boolean isAuthorizedFieldChanged = false;
                        
                        if(data.containsKey('Updated_Advance_Chg_Max_Authorized_Amt__c')) {
                            Map<String, Object> authorizedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Updated_Advance_Chg_Max_Authorized_Amt__c')));
                            Map<String, Object> authorizedMap1 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('REQUESTED_TO_PAY_ADVANCE_CHARGES')));
                            writer.writeStartElement(null, 'UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(authorizedMap.get('ActionCode')));
                                if(authorizedMap1 != null && String.valueOf(authorizedMap1.get('ActionCode')) =='D'){
                                    writer.writeCharacters(String.valueOf(0));
                                }else{
                                    writer.writeCharacters(String.valueOf(authorizedMap.get('value')));
                                }
                                isAuthorizedFieldChanged = true;
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('Updated_Advance_Chg_Auth_By_First_Name__c')) {
                            Map<String, Object> authorizedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Updated_Advance_Chg_Auth_By_First_Name__c')));
                            writer.writeStartElement(null, 'UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_FIRST_NAME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(authorizedMap.get('ActionCode')));
                                writer.writeCharacters(String.valueOf(authorizedMap.get('value')));
                                isAuthorizedFieldChanged = true;
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('Updated_Advance_Chg_Auth_By_Last_Name__c')) {
                            Map<String, Object> authorizedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Updated_Advance_Chg_Auth_By_Last_Name__c')));
                            writer.writeStartElement(null, 'UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_LAST_NAME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(authorizedMap.get('ActionCode')));
                                writer.writeCharacters(String.valueOf(authorizedMap.get('value')));
                                isAuthorizedFieldChanged = true;
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('Updated_Advance_Chg_Auth_DateTime__c')) {
                            Map<String, Object> authorizedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Updated_Advance_Chg_Auth_DateTime__c')));
                            writer.writeStartElement(null, 'UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(authorizedMap.get('ActionCode')));
                                writer.writeCharacters(String.valueOf(authorizedMap.get('value')).replace('.000Z', ''));
                            writer.writeEndElement();
                        }
                        else if(data.containsKey('REQUESTED_TO_PAY_ADVANCE_CHARGES') || isAuthorizedFieldChanged){
                            Map<String, Object> authorizedMap = (data.containsKey('REQUESTED_TO_PAY_ADVANCE_CHARGES')) ? (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('REQUESTED_TO_PAY_ADVANCE_CHARGES'))) : new Map<String, Object>();
                            writer.writeStartElement(null, 'UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME', null);
                            if(String.valueOf(authorizedMap.get('ActionCode')) == 'A'){
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                            } else if(String.valueOf(authorizedMap.get('ActionCode')) == 'D'){
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                            } else if(isAuthorizedFieldChanged){
                                writer.writeAttribute(null, null, 'ActionCode', 'U');
                            } 
                            system.debug('-=UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME'+System.now());
                            system.debug('-=UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME1'+String.valueOfGMT(System.now()).replace(' ', 'T'));
                            system.debug('-=UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME2'+String.valueOfGMT(System.now()).replace(' ', 'T')+'Z');
                            writer.writeCharacters(String.valueOfGMT(System.now()).replace(' ', 'T')+'Z');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CRC_Start_Date__c')) {
                            Map<String, Object> startDateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CRC_Start_Date__c')));
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(startDateMap.get('ActionCode')));
                                writer.writeCharacters(startDateMap.containsKey('value') ? String.valueOf(startDateMap.get('value'))+'T00:00:00' : '');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('CRC_End_Date__c')) {
                            Map<String, Object> endDateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CRC_End_Date__c')));
                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(endDateMap.get('ActionCode')));
                                writer.writeCharacters(endDateMap.containsKey('value') ? String.valueOf(endDateMap.get('value'))+'T00:00:00' : '');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('Number_Of_Days__c')) {
                            Map<String, Object> numberOfDaysMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Number_Of_Days__c')));
                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(numberOfDaysMap.get('ActionCode')));
                                writer.writeCharacters(numberOfDaysMap.containsKey('value') ? String.valueOf(numberOfDaysMap.get('value')) : '');
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'RELEASE', null);
                    
                        if(data.containsKey('CRC_Storage_Rate__c')) {
                            Map<String, Object> storageRateMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CRC_Storage_Rate__c')));
                            writer.writeStartElement(null, 'VR_STORAGE_RATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(storageRateMap.get('ActionCode')));
                                writer.writeCharacters(storageRateMap.containsKey('value') ? String.valueOf(storageRateMap.get('value')) : '');
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('CRC_Rate_Type__c')) {
                            Map<String, Object> rateTypeMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('CRC_Rate_Type__c')));
                            writer.writeStartElement(null, 'VR_STORAGE_RATE_TYPE_CODE', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(rateTypeMap.get('ActionCode')));
                                writer.writeCharacters(rateTypeMap.containsKey('value') ? String.valueOf(rateTypeMap.get('value')) : '');
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('Calculated_Storage_Amount__c')) {
                            Map<String, Object> calculatedAmountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('Calculated_Storage_Amount__c')));
                            writer.writeStartElement(null, 'VR_CALCULATED_STORAGE_AMOUNT', null);
                                writer.writeAttribute(null, null, 'ActionCode', String.valueOf(calculatedAmountMap.get('ActionCode')));
                                writer.writeCharacters(calculatedAmountMap.containsKey('value') ? String.valueOf(calculatedAmountMap.get('value')) : '');
                            writer.writeEndElement();
                        }
                        
                        if(data.containsKey('VR_CHARGES_CLEARED')) {
                            Map<String, Object> chargesCleared = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data.get('VR_CHARGES_CLEARED')));
                            writer.writeStartElement(null, 'VR_CHARGES_CLEARED', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'U'); 
                                writer.writeCharacters(chargesCleared.containsKey('value') && String.valueOf(chargesCleared.get('value')) == 'true' ? 'Y' : 'N');
                            writer.writeEndElement();
                        }

                        if(data.containsKey('variableCharges')) {
                            List<Object> storageCharges = (List<Object>) data.get('variableCharges');
                            if(storageCharges.size() > 0) {
                                writer.writeStartElement(null, 'VARIABLE_STORAGE_RATE_INFO', null);
                                    writer.writeAttribute(null, null, 'ActionCode', String.valueOf(data.get('ACTION_CODE')));
                                    for (Object o : storageCharges) {
                                        Map<String, Object> charge = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                                        writer.writeStartElement(null, 'VARIABLE_RATE_STORAGE', null);
                                            writer.writeStartElement(null, 'VRS_SEQUENCE_NBR', null);
                                                writer.writeCharacters(charge.containsKey('sequenceNumber') ? String.valueOf(charge.get('sequenceNumber')) : '');
                                            writer.writeEndElement();
                                            writer.writeStartElement(null, 'VRS_FEE_AMOUNT', null);
                                                writer.writeCharacters(charge.containsKey('Fee_Amount__c') ? String.valueOf(charge.get('Fee_Amount__c')) : '');
                                            writer.writeEndElement();
                                            writer.writeStartElement(null, 'VRS_VARIABLE_DAYS', null);
                                                writer.writeCharacters(charge.containsKey('variableDays') ? String.valueOf(charge.get('variableDays')) : '');
                                            writer.writeEndElement();
                                            writer.writeStartElement(null, 'VRS_RATE_TYPE', null);
                                                writer.writeCharacters('VAR');
                                            writer.writeEndElement();
                                            writer.writeStartElement(null, 'VRS_RESPONSIBLE_PARTY', null);
                                                writer.writeCharacters(charge.containsKey('Responsible_Party__c') ? String.valueOf(charge.get('Responsible_Party__c')) : '');
                                            writer.writeEndElement();
                                        writer.writeEndElement();
                                    }   
                                writer.writeEndElement();
                            }
                        }
                    writer.writeEndElement();
                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();
    }

    public static String releaseVehiclePost(Map<String, Object> data) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null, 'IAAI_ASSIGNMENT_INFO', null);
                writer.writeAttribute(null, null, 'xmlns', 'http://eai.iaa.com/AssignmentRelease/iaai_assignment_info/');

                writer.writeStartElement(null, 'TRAN_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_TRANSACTION_ID);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CREATE_DATETIME', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREATE_DATETIME);
                writer.writeEndElement();

                writer.writeStartElement(null, 'SENT_FROM', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                writer.writeEndElement();

                writer.writeStartElement(null, 'VERSION', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Version__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'TRANSACTION_TYPE', null);
                    writer.writeCharacters('ASSIGNMENT RLSE');
                writer.writeEndElement();
                
                if(data.containsKey('IAAI_STOCK_NUMBER')) {
                    writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                        writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                    writer.writeEndElement();
                }

                if(data.containsKey('SALVAGE_ID')) {
                    writer.writeStartElement(null, 'SALVAGE_ID', null);
                        writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                    writer.writeEndElement();
                }

                writer.writeStartElement(null, 'CALL_CENTER_ID', null);
                    writer.writeCharacters(CRC_Constants.RPM_CREDENTIALS.Call_Center_ID__c);
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_ID', null);
                    writer.writeCharacters('csr2913');
                writer.writeEndElement();

                writer.writeStartElement(null, 'CALL_CENTER_USER_NAME', null);
                    writer.writeCData(UserInfo.getName());
                writer.writeEndElement();

                writer.writeStartElement(null, 'RLSE_ASN', null);
                    
                    if(data.containsKey('IAAI_STOCK_NUMBER')) {
                        writer.writeStartElement(null, 'IAAI_STOCK_NUMBER', null);
                            writer.writeCharacters(String.valueOf(data.get('IAAI_STOCK_NUMBER')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('SALVAGE_ID')) {
                        writer.writeStartElement(null, 'SALVAGE_ID', null);
                            writer.writeCharacters(String.valueOf(data.get('SALVAGE_ID')));
                        writer.writeEndElement();
                    }

                    if(data.containsKey('CHECKSUM')) {
                        writer.writeStartElement(null, 'CHECKSUM', null);
                            writer.writeCharacters(String.valueOf(data.get('CHECKSUM')));
                        writer.writeEndElement();
                    }

                    writer.writeStartElement(null, 'PROVIDER', null);
                        writer.writeStartElement(null, 'PROVIDER_NAME', null);
                            writer.writeCData(data.containsKey('PROVIDER_NAME') ? String.valueOf(data.get('PROVIDER_NAME')) : '');
                        writer.writeEndElement();
                        
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'SALVOR', null);
                        writer.writeStartElement(null, 'BRANCH', null);
                        writer.writeEndElement();
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'VEHICLE', null);
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'PROC_STATUS', null);
                        String lossDate = getAssignmentLossDate(data);
                        if(String.isNotBlank(lossDate)) {
                            writer.writeStartElement(null, 'STORAGE_START_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(lossDate+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'STORAGE_STOP_DATE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(DATE.today())+'T00:00:00');
                            writer.writeEndElement();

                            writer.writeStartElement(null, 'NUMBER_OF_DAYS_OF_STORAGE', null);
                                writer.writeAttribute(null, null, 'ActionCode', 'A');
                                writer.writeCData(String.valueOf(Date.valueOf(lossDate).daysBetween(Date.today())+1));
                            writer.writeEndElement();
                        }
                    writer.writeEndElement();

                    writer.writeStartElement(null, 'RELEASE', null);
                        writer.writeStartElement(null, 'VR_VEHICLE_RELEASED', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'U');
                            writer.writeCharacters('Y');
                        writer.writeEndElement();
                        // writer.writeStartElement(null, 'VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME', null);
                        //     writer.writeAttribute(null, null, 'ActionCode', 'U');
                        //     writer.writeCharacters(data.containsKey('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME') ? String.valueOf(data.get('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME')).replace('.000Z', '') : '');
                        // writer.writeEndElement();
                        writer.writeStartElement(null, 'VR_ANTICIPATED_PICKUP_DATETIME', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'U');
                            writer.writeCharacters(data.containsKey('VR_ANTICIPATED_PICKUP_DATETIME') ? String.valueOf(data.get('VR_ANTICIPATED_PICKUP_DATETIME')).replace('.000Z', '')+'z' : '');
                        writer.writeEndElement();
                        writer.writeStartElement(null, 'VR_CHARGES_CLEARED', null);
                            writer.writeAttribute(null, null, 'ActionCode', 'U'); 
                            writer.writeCharacters(data.containsKey('VR_CHARGES_CLEARED') && String.valueOf(data.get('VR_CHARGES_CLEARED')) == 'true' ? 'Y' : 'N');
                        writer.writeEndElement();
                    writer.writeEndElement();

                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();
        System.debug('variable: ' + writer.getXmlString());
        return writer.getXmlString();    
    }

    private static String getAssignmentLossDate(Map<String, Object> data) {
        String stockNumber = (data.containsKey('IAAI_STOCK_NUMBER') && data.get('IAAI_STOCK_NUMBER') != null) ? String.valueOf(data.get('IAAI_STOCK_NUMBER')) : String.valueOf(data.get('Stock__c'));
        if(String.isBlank(stockNumber)) {
            return null;
        } 

        return String.valueOf([SELECT Id, CRC_Date_of_Loss__c, CRC_Start_Date__c, CRC_End_Date__c FROM Case WHERE (CRC_Stock_Number__c =:stockNumber AND CRC_Start_Date__c = null AND CRC_End_Date__c = null) LIMIT 1]?.CRC_Date_of_Loss__c);
    }
}