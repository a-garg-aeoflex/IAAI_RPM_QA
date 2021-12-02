import { LightningElement } from 'lwc';
import refreshFromRPM from '@salesforce/apex/RPM_APIController.refreshFromRPM';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Crc_util extends LightningElement {}

export function validateFieldsAndGetData(component) {
    let data = {};
    const allValid = [...component.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group, lightning-textarea, lightning-dual-listbox')]
        .reduce((validSoFar, inputCmp) => {
            if(inputCmp.name) {
                if(inputCmp.type === 'checkbox' && inputCmp.value !== 'TBD') {
                    data[inputCmp.name] = inputCmp.checked;
                } else if((inputCmp.name.includes('Birthdate') || inputCmp.name.includes('Birthday'))) {
                    if(new Date(inputCmp.value) > new Date()) {
                        inputCmp.setCustomValidity('Birthdate can\'t be a future date');
                    } else {
                        data[inputCmp.name] = inputCmp.value;
                        inputCmp.setCustomValidity('');
                    }
                } else {
                    data[inputCmp.name] = inputCmp.value;
                }
            }
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true); 
    return {isValid:allValid, data:data};
}

export function showErrorMessage(component, error) {
    // (typeof error === "string") ? error : error.body.message
    component.dispatchEvent(new ShowToastEvent({
        message: (error) ? ((error.message) ? error.message : ((error.body) ? ((error.body.message) ? error.body.message : error) : error)) : "Something went wrong!",
        variant: 'error'
    }));
}

export function showSuccessMessage(component, message) {
    component.dispatchEvent(new ShowToastEvent({
        message: message,
        variant: 'success'
    }));
}

export function processActionCodes(newData, oldData) {
    let finalData = {};
    let columnsToSkip = ['STORAGE_LOCATION_ID', 'Release_Requirement__c','IAAI_STOCK_NUMBER', 'STORAGE_LOCATION_ID', 'PROVIDER_NAME', 'IAAI_STOCK_NUMBER', 'SALVAGE_ID', 'CHECKSUM'];
    let checkboxColumns = ['SL_CASH_ONLY', 'SL_IAA_CREDIT_CARD', 'SL_CALL_BEFORE_PICKUP'];
    
    for (const key in newData) {
        let oldValue = oldData[key];
        let newValue = newData[key];
        if(columnsToSkip.indexOf(key) >= 0) {
            finalData[key] = newValue;
        } else if(newValue === oldValue) {
            // finalData[key] = {ActionCode : '', value: newData[key] }; // updated because of residential storage update need all fields
        } else if (!newValue && oldValue) {
            finalData[key] = {ActionCode : (checkboxColumns.indexOf(key) < 0) ? 'D' : 'U' , value: newValue };
        } else if (newValue != oldValue && oldValue) {
            finalData[key] = {ActionCode : 'U', value: newValue };
        } else if (!oldValue && newValue) {
            finalData[key] = {ActionCode : 'A', value: newValue };
        } else {
            // finalData[key] = {ActionCode : '', value: newData[key] }; // updated because of residential storage update need all fields
        }
    }
    return finalData;
}

export function salesforceAccountToRpmStorageLocation(data) {
    let mapping = {
        Location_Id__c : 'STORAGE_LOCATION_ID',
        Name : 'CONTACT.COMPANY_NAME',
        CRC_Pickup_Location_Type__c : 'PICKUP_LOCATION_TYPE',
        Storage_Location_Status__c : 'SL_STATUS',
        BillingStreet : 'CONTACT.ADDRESS_LINE1',
        BillingCity : 'CONTACT.CITY',
        BillingState : 'CONTACT.STATE',
        BillingPostalCode : 'CONTACT.ZIP',
        BillingCountry : 'CONTACT.COUNTRY_CODE',
        ShippingStreet : 'MAILING_ADDRESS.CONTACT.ADDRESS_LINE1',
        ShippingCity : 'MAILING_ADDRESS.CONTACT.CITY',
        ShippingState : 'MAILING_ADDRESS.CONTACT.STATE',
        ShippingCountry : 'MAILING_ADDRESS.CONTACT.COUNTRY_CODE',
        ShippingPostalCode : 'MAILING_ADDRESS.CONTACT.ZIP',
        Phone : 'CONTACT.PHONE_NUMBER1',
        Fax : 'CONTACT.FAX_NUMBER',
        Email : 'CONTACT.EMAIL',
        Validated__c : 'SL_VALIDATION_STATUS',
        Call_Before_Pickup__c : 'SL_CALL_BEFORE_PICKUP',
        Check_Payable_To__c : 'SL_CHECK_PAYABLE_TO',
        Cash_Only_Payments__c : 'SL_CASH_ONLY',
        CRC_checksum__c : 'CHECKSUM',
        Federal_Tax_ID__c : 'SL_FEDERAL_EIN',
        Credit_Card_Accepted__c : 'SL_IAA_CREDIT_CARD'
    };

    var finalData = {};
    for (const key in data) {
        if(mapping.hasOwnProperty(key)) {
            finalData[mapping[key]] = data[key];
        } else {
            finalData[key] = data[key];
        }
    }
    return finalData;
}

export function rpmStorageLocationToSalesforceAccount(data) {
    let mapping = {
        'STORAGE_LOCATION_ID' : 'Location_Id__c',
        'CONTACT.COMPANY_NAME' : 'Name',
        'PICKUP_LOCATION_TYPE' : 'CRC_Pickup_Location_Type__c',
        'SL_STATUS' : 'Storage_Location_Status__c',
        'CONTACT.ADDRESS_LINE1' : 'BillingStreet',
        'CONTACT.CITY' : 'BillingCity',
        'CONTACT.STATE' : 'BillingState',
        'CONTACT.ZIP' : 'BillingPostalCode',
        'CONTACT.COUNTRY_CODE' : 'BillingCountry',
        'MAILING_ADDRESS.CONTACT.ADDRESS_LINE1' : 'ShippingStreet',
        'MAILING_ADDRESS.CONTACT.CITY' : 'ShippingCity',
        'MAILING_ADDRESS.CONTACT.STATE' : 'ShippingState',
        'MAILING_ADDRESS.CONTACT.COUNTRY_CODE' : 'ShippingCountry',
        'MAILING_ADDRESS.CONTACT.ZIP' : 'ShippingPostalCode',
        'CONTACT.PHONE_NUMBER1' : 'Phone',
        'CONTACT.FAX_NUMBER' : 'Fax',
        'CONTACT.EMAIL' : 'Email',
        'SL_VALIDATION_STATUS' : 'Validated__c',
        'SL_CALL_BEFORE_PICKUP' : 'Call_Before_Pickup__c',
        'SL_CHECK_PAYABLE_TO' : 'Check_Payable_To__c',
        'SL_CASH_ONL' : 'Cash_Only_Payments__c',
        'CHECKSUM' : 'CRC_checksum__c',
        'SL_FEDERAL_EIN' : 'Federal_Tax_ID__c',
        'SL_IAA_CREDIT_CARD' : 'Credit_Card_Accepted__c' 
    };

    var finalData = {};
    for (const key in data) {
        if(mapping.hasOwnProperty(key)) {
            finalData[mapping[key]] = data[key];
        } else {
            finalData[key] = data[key];
        }
    }
    return finalData;
}

export function rpmAssignmentToSalesforceCase(data) {
    let mapping = {
        CRC_Mileage__c : 'CRC_Mileage__c',
        CRC_Release_Person_First_Name__c : 'VR_RELEASED_BY_FIRST_NAME',
        CRC_Release_Person_Last_Name__c : 'CRC_Release_Person_Last_Name__c',
        VIN : 'CRC_VIN__c',
        YEAR : 'CRC_Year__c',
        MODEL : 'CRC_Model__c',
        MAKE : 'CRC_Make__c',
        CRC_License_Plate__c : 'CRC_License_Plate__c',
        CRC_Exterior_Color__c : 'CRC_Exterior_Color__c',
        VR_IS_VEHICLE_AT_LOCATION : 'CRC_Is_Vehicle_There__c',
        VR_VEHICLE_RELEASED : 'CRC_Vehicle_Released__c',
        CRC_Mileage__c : 'CRC_Mileage__c',
        VR_VEHICLE_LOCATION_CODE : 'CRC_Vehicle_Location__c',
        VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME : 'CRC_Earliest_Available_Pickup__c',
        VR_ANTICIPATED_PICKUP_DATETIME : 'CRC_Anticipated_Release_Date_Time__c',
        SLA_CALCULATED_PICKUP_DATETIME : 'CRC_SLA_Calculated_Pickup_DateTime__c',
        VR_VEHICLE_BLOCKED_IN : 'CRC_Vehicle_Blocked_In__c',
        KEYS_INDICATOR : 'CRC_Keys_with_Vehicle__c',
        CRC_Assignment_Type__c : 'CRC_Assignment_Type__c',
        VR_CALL_BEFORE_COMING : 'CRC_Call_Before_Coming__c',
        VR_VEHICLE_TOWABLE : 'CRC_Vehicle_Towable__c',
        CRC_Tow_Zone__c : 'CRC_Tow_Zone__c',
        CRC_Primary_Damage_Code__c : 'PRIMARY_DAMAGE_CODE',
        DRIVE : 'CRC_Drive__c',
        FUEL_TYPE : 'CRC_Fuel_Type__c',
        TYPE_OF_LOSS_CODE : 'CRC_Loss_Type__c',
        CRC_Secondary_Damage_Code__c : 'CRC_Secondary_Damage_Code__c',
    };

    var finalData = {};
    for (const key in data) {
        if(mapping.hasOwnProperty(key)) {
            finalData[mapping[key]] = data[key];
        } else {
            finalData[key] = data[key];
        }
    }
    return finalData;
}

export function salesforceCaseToRpmAssignment(data) {
    let mapping = {
        CRC_Release_Person_First_Name__c : 'VR_RELEASED_BY_FIRST_NAME',
        CRC_Release_Person_Last_Name__c : 'VR_RELEASED_BY_LAST_NAME',
        CRC_VIN__c : 'VIN',
        CRC_Year__c : 'YEAR',
        Model__c : 'MODEL',
        CRC_Make__c : 'MAKE',
        CRC_License_Plate__c : 'LICENSE_PLATE_NUMBER',
        CRC_Exterior_Color__c : 'COLOR',
        CRC_Is_Vehicle_There__c : 'VR_IS_VEHICLE_AT_LOCATION',
        CRC_Vehicle_Released__c : 'VR_VEHICLE_RELEASED',
        CRC_Mileage__c : 'CRC_Mileage__c',
        CRC_Vehicle_Location__c : 'VR_VEHICLE_LOCATION_CODE',
        CRC_Anticipated_Release_Date_Time__c : 'VR_ANTICIPATED_PICKUP_DATETIME',
        CRC_Earliest_Available_Pickup__c : 'VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME',
        CRC_Vehicle_Blocked_In__c : 'VR_VEHICLE_BLOCKED_IN',
        CRC_Keys_with_Vehicle__c : 'KEYS_INDICATOR',
        CRC_Call_Before_Coming__c : 'VR_CALL_BEFORE_COMING',
        CRC_Vehicle_Towable__c : 'VR_VEHICLE_TOWABLE',
        CRC_Primary_Damage_Code__c : 'PRIMARY_DAMAGE_CODE',
        CRC_Drive__c : 'DRIVE',
        CRC_Fuel_Type__c : 'FUEL_TYPE',
        CRC_Loss_Type__c : 'TYPE_OF_LOSS_CODE',
        CRC_Secondary_Damage_Code__c : 'SECONDARY_DAMAGE_CODE',

        
        CRC_Calculated_Storage_Amount__c: 'VR_CALCULATED_STORAGE_AMOUNT',
        CRC_Checksum__c: 'CHECKSUM',
        CRC_Company_Name__c: 'CONTACT.COMPANY_NAME',
        CRC_IAA_Authorized_to_Pay__c: 'IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES',
        CRC_Pickup_Location_Type__c: 'PICKUP_LOCATION_TYPE',
        CRC_Rate_Type__c: 'VR_STORAGE_RATE_TYPE_CODE',
        CRC_Res_Location_Id__c: 'STORAGE_LOCATION_ID',
        CRC_Salvage_Id__c: 'SALVAGE_ID',
        CRC_Storage_Rate__c: 'VR_STORAGE_RATE',
        CRC_VO_Address_Line_1__c: 'CONTACT.ADDRESS_LINE1',
        CRC_VO_Country_Code__c: 'CONTACT.COUNTRY_CODE',
        CRC_VO_First_Name__c: 'CONTACT.FIRST_NAME',
        CRC_VO_Last_Name__c: 'CONTACT.LAST_NAME',
        CRC_VO_Primary_Phone_Number__c: 'CONTACT.PHONE_NUMBER1',
        CRC_VO_Zip__c: 'CONTACT.ZIP',
        VO_Status__c: 'SL_STATUS',
        VO_Validated__c: 'SL_VALIDATION'
    };

    var finalData = {};
    for (const key in data) {
        if(mapping.hasOwnProperty(key)) {
            finalData[mapping[key]] = data[key];
        } else {
            finalData[key] = data[key];
        }
    }
    return finalData;
}

/**
 * @returns object of value vs label of picklist values
 * @param {Array of picklist values Object} params : [{label: 'XYZ', value:'XYZ'}] 
 */
export function reversePicklistValues(data) {
    let finalData = {};
    data.forEach(element => {
        finalData[element.value] = element.label;
    });
    return finalData;
}

/**
 * @returns void
 * @description Sync RPM to Salesforce
 * @param {CaseId} params : CaseId
 */
export function syncRPM2SF(caseId) {
    if(caseId) {
        return;
    }
    refreshFromRPM({raId : caseId})
        .then(result => {
            console.log(result);
        })
        .catch(error => {
            showErrorMessage(this, error);
        });
}

export function getStateCodes() {
    return [
        {label: 'Alberta', value: 'AB'},
        {label: 'British Columbia', value: 'BC'},
        {label: 'Manitoba', value: 'MB'},
        {label: 'New Brunswick', value: 'NB'},
        {label: 'Newfoundland', value: 'NF'},
        {label: 'Nova Scotia', value: 'NS'},
        {label: 'Northwest Territories', value: 'NT'},
        {label: 'Nunavut', value: 'NU'},
        {label: 'Ontario', value: 'ON'},
        {label: 'Prince Edward Island', value: 'PE'},
        {label: 'Province of Quebec (Alternate for QC)', value: 'PQ'},
        {label: 'Quebec', value: 'QC'},
        {label: 'Saskatchewan', value: 'SK'},
        {label: 'Yukon Territory', value: 'YT'},
        {label: 'Alta Verapaz', value: 'AV'},
        {label: 'Baja Verapaz', value: 'BV'},
        {label: 'Chiquimula', value: 'CA'},
        {label: 'Chimaltenango', value: 'CO'},
        {label: 'El Progreso', value: 'EP'},
        {label: 'Escuintla', value: 'ES'},
        {label: 'Guatemala', value: 'GT'},
        {label: 'Huehuetenango', value: 'HU'},
        {label: 'Izabal', value: 'IZ'},
        {label: 'Jalapa', value: 'JA'},
        {label: 'Jutiapa', value: 'JU'},
        {label: 'Peten', value: 'PE'},
        {label: 'Quiche', value: 'QE'},
        {label: 'Quetzaltenango', value: 'QO'},
        {label: 'Retalhuleu', value: 'RE'},
        {label: 'Sacatepequez', value: 'SA'},
        {label: 'San Marcos', value: 'SM'},
        {label: 'Solola', value: 'SO'},
        {label: 'Santa Rosa', value: 'SR'},
        {label: 'Suchitepequez', value: 'SU'},
        {label: 'Totonicapan', value: 'TO'},
        {label: 'Zacapa', value: 'ZA'},
        {label: 'Guam', value: 'GU'},
        {label: 'AGUASCALIENTES', value: 'AGS'},
        {label: 'BAJA CALIFORNIA', value: 'BCN'},
        {label: 'BAJA CALIFORNIA SUR', value: 'BCS'},
        {label: 'CAMPECHE', value: 'CAM'},
        {label: 'CHIHUAHUA', value: 'CHH'},
        {label: 'CHIAPAS', value: 'CHP'},
        {label: 'COAHUILA', value: 'COA'},
        {label: 'COLIMA', value: 'COL'},
        {label: 'DISTRITO FEDERAL', value: 'DIF'},
        {label: 'DURANGO', value: 'DUR'},
        {label: 'GUERRERO', value: 'GRO'},
        {label: 'GUANAJUATO', value: 'GUA'},
        {label: 'HIDALGO', value: 'HID'},
        {label: 'JALISCO', value: 'JAL'},
        {label: 'MEXICO', value: 'MEX'},
        {label: 'MICHOACAN', value: 'MIC'},
        {label: 'MORELOS', value: 'MOR'},
        {label: 'NAYARIT', value: 'NAY'},
        {label: 'NUEVO LEON', value: 'NLE'},
        {label: 'OAXACA', value: 'OAX'},
        {label: 'PUEBLA', value: 'PUE'},
        {label: 'QUERETARO', value: 'QUE'},
        {label: 'QUINTANA ROO', value: 'ROO'},
        {label: 'SINALOA', value: 'SIN'},
        {label: 'SAN LUIS POTOSI', value: 'SLP'},
        {label: 'SONORA', value: 'SON'},
        {label: 'TABASCO', value: 'TAB'},
        {label: 'TAMAULIPAS', value: 'TAM'},
        {label: 'TLAXCALA', value: 'TLA'},
        {label: 'VERACRUZ', value: 'VER'},
        {label: 'YUCATAN', value: 'YUC'},
        {label: 'ZACATECAS', value: 'ZAC'},
        {label: 'Alaska', value: 'AK'},
        {label: 'Alabama', value: 'AL'},
        {label: 'Arkansas', value: 'AR'},
        {label: 'Arizona', value: 'AZ'},
        {label: 'California', value: 'CA'},
        {label: 'Colorado', value: 'CO'},
        {label: 'Connecticut', value: 'CT'},
        {label: 'District Of Columbia', value: 'DC'},
        {label: 'Delaware', value: 'DE'},
        {label: 'Florida', value: 'FL'},
        {label: 'Georgia', value: 'GA'},
        {label: 'Guam', value: 'GU'},
        {label: 'Hawaii', value: 'HI'},
        {label: 'Iowa', value: 'IA'},
        {label: 'Idaho', value: 'ID'},
        {label: 'Illinois', value: 'IL'},
        {label: 'Indiana', value: 'IN'},
        {label: 'Kansas', value: 'KS'},
        {label: 'Kentucky', value: 'KY'},
        {label: 'Louisiana', value: 'LA'},
        {label: 'Massachusetts', value: 'MA'},
        {label: 'Maryland', value: 'MD'},
        {label: 'Maine', value: 'ME'},
        {label: 'Michigan', value: 'MI'},
        {label: 'Minnesota', value: 'MN'},
        {label: 'Missouri', value: 'MO'},
        {label: 'Mississippi', value: 'MS'},
        {label: 'Montana', value: 'MT'},
        {label: 'North Carolina', value: 'NC'},
        {label: 'North Dakota', value: 'ND'},
        {label: 'Nebraska', value: 'NE'},
        {label: 'New Hampshire', value: 'NH'},
        {label: 'New Jersey', value: 'NJ'},
        {label: 'New Mexico', value: 'NM'},
        {label: 'Nevada', value: 'NV'},
        {label: 'New York', value: 'NY'},
        {label: 'Ohio', value: 'OH'},
        {label: 'Oklahoma', value: 'OK'},
        {label: 'Oregon', value: 'OR'},
        {label: 'Pennsylvania', value: 'PA'},
        {label: 'Puerto Rico', value: 'PR'},
        {label: 'Rhode Island', value: 'RI'},
        {label: 'South Carolina', value: 'SC'},
        {label: 'South Dakota', value: 'SD'},
        {label: 'Tennessee', value: 'TN'},
        {label: 'Texas', value: 'TX'},
        {label: 'Utah', value: 'UT'},
        {label: 'Virginia', value: 'VA'},
        {label: 'Virgin Islands', value: 'VI'},
        {label: 'Vermont', value: 'VT'},
        {label: 'Washington', value: 'WA'},
        {label: 'Wisconsin', value: 'WI'},
        {label: 'West Virginia', value: 'WV'},
        {label: 'Wyoming', value: 'WY'},
        {label: 'Not Applicable/Unknown', value: 'XX'}
    ];
}

export function getCountryCodes() {
    return [
        {label: 'Canada', value: 'CA'},
        {label: 'Guatemala', value: 'GT'},
        {label: 'Guam', value: 'GU'},
        {label: 'Mexico', value: 'MX'},
        {label: 'United States', value: 'US'},
    ];
}

export function getCoutryVsStateCodeMapping() {
    return {
        'CA':[
            {label: 'Alberta', value: 'AB'},
            {label: 'British Columbia', value: 'BC'},
            {label: 'Manitoba', value: 'MB'},
            {label: 'New Brunswick', value: 'NB'},
            {label: 'Newfoundland', value: 'NF'},
            {label: 'Nova Scotia', value: 'NS'},
            {label: 'Northwest Territories', value: 'NT'},
            {label: 'Nunavut', value: 'NU'},
            {label: 'Ontario', value: 'ON'},
            {label: 'Prince Edward Island', value: 'PE'},
            {label: 'Province of Quebec (Alternate for QC)', value: 'PQ'},
            {label: 'Quebec', value: 'QC'},
            {label: 'Saskatchewan', value: 'SK'},
            {label: 'Yukon Territory', value: 'YT'}
        ],
        'GT':[
            {label: 'Alta Verapaz', value: 'AV'},
            {label: 'Baja Verapaz', value: 'BV'},
            {label: 'Chiquimula', value: 'CA'},
            {label: 'Chimaltenango', value: 'CO'},
            {label: 'El Progreso', value: 'EP'},
            {label: 'Escuintla', value: 'ES'},
            {label: 'Guatemala', value: 'GT'},
            {label: 'Huehuetenango', value: 'HU'},
            {label: 'Izabal', value: 'IZ'},
            {label: 'Jalapa', value: 'JA'},
            {label: 'Jutiapa', value: 'JU'},
            {label: 'Peten', value: 'PE'},
            {label: 'Quiche', value: 'QE'},
            {label: 'Quetzaltenango', value: 'QO'},
            {label: 'Retalhuleu', value: 'RE'},
            {label: 'Sacatepequez', value: 'SA'},
            {label: 'San Marcos', value: 'SM'},
            {label: 'Solola', value: 'SO'},
            {label: 'Santa Rosa', value: 'SR'},
            {label: 'Suchitepequez', value: 'SU'},
            {label: 'Totonicapan', value: 'TO'},
            {label: 'Zacapa', value: 'ZA'}
        ],
        'GU':[{label: 'Guam', value: 'GU'}],
        'MX':[
            {label: 'AGUASCALIENTES', value: 'AGS'},
            {label: 'BAJA CALIFORNIA', value: 'BCN'},
            {label: 'BAJA CALIFORNIA SUR', value: 'BCS'},
            {label: 'CAMPECHE', value: 'CAM'},
            {label: 'CHIHUAHUA', value: 'CHH'},
            {label: 'CHIAPAS', value: 'CHP'},
            {label: 'COAHUILA', value: 'COA'},
            {label: 'COLIMA', value: 'COL'},
            {label: 'DISTRITO FEDERAL', value: 'DIF'},
            {label: 'DURANGO', value: 'DUR'},
            {label: 'GUERRERO', value: 'GRO'},
            {label: 'GUANAJUATO', value: 'GUA'},
            {label: 'HIDALGO', value: 'HID'},
            {label: 'JALISCO', value: 'JAL'},
            {label: 'MEXICO', value: 'MEX'},
            {label: 'MICHOACAN', value: 'MIC'},
            {label: 'MORELOS', value: 'MOR'},
            {label: 'NAYARIT', value: 'NAY'},
            {label: 'NUEVO LEON', value: 'NLE'},
            {label: 'OAXACA', value: 'OAX'},
            {label: 'PUEBLA', value: 'PUE'},
            {label: 'QUERETARO', value: 'QUE'},
            {label: 'QUINTANA ROO', value: 'ROO'},
            {label: 'SINALOA', value: 'SIN'},
            {label: 'SAN LUIS POTOSI', value: 'SLP'},
            {label: 'SONORA', value: 'SON'},
            {label: 'TABASCO', value: 'TAB'},
            {label: 'TAMAULIPAS', value: 'TAM'},
            {label: 'TLAXCALA', value: 'TLA'},
            {label: 'VERACRUZ', value: 'VER'},
            {label: 'YUCATAN', value: 'YUC'},
            {label: 'ZACATECAS', value: 'ZAC'}
        ],
        'US':[
            {label: 'Alaska', value: 'AK'},
            {label: 'Alabama', value: 'AL'},
            {label: 'Arkansas', value: 'AR'},
            {label: 'Arizona', value: 'AZ'},
            {label: 'California', value: 'CA'},
            {label: 'Colorado', value: 'CO'},
            {label: 'Connecticut', value: 'CT'},
            {label: 'District Of Columbia', value: 'DC'},
            {label: 'Delaware', value: 'DE'},
            {label: 'Florida', value: 'FL'},
            {label: 'Georgia', value: 'GA'},
            {label: 'Guam', value: 'GU'},
            {label: 'Hawaii', value: 'HI'},
            {label: 'Iowa', value: 'IA'},
            {label: 'Idaho', value: 'ID'},
            {label: 'Illinois', value: 'IL'},
            {label: 'Indiana', value: 'IN'},
            {label: 'Kansas', value: 'KS'},
            {label: 'Kentucky', value: 'KY'},
            {label: 'Louisiana', value: 'LA'},
            {label: 'Massachusetts', value: 'MA'},
            {label: 'Maryland', value: 'MD'},
            {label: 'Maine', value: 'ME'},
            {label: 'Michigan', value: 'MI'},
            {label: 'Minnesota', value: 'MN'},
            {label: 'Missouri', value: 'MO'},
            {label: 'Mississippi', value: 'MS'},
            {label: 'Montana', value: 'MT'},
            {label: 'North Carolina', value: 'NC'},
            {label: 'North Dakota', value: 'ND'},
            {label: 'Nebraska', value: 'NE'},
            {label: 'New Hampshire', value: 'NH'},
            {label: 'New Jersey', value: 'NJ'},
            {label: 'New Mexico', value: 'NM'},
            {label: 'Nevada', value: 'NV'},
            {label: 'New York', value: 'NY'},
            {label: 'Ohio', value: 'OH'},
            {label: 'Oklahoma', value: 'OK'},
            {label: 'Oregon', value: 'OR'},
            {label: 'Pennsylvania', value: 'PA'},
            {label: 'Puerto Rico', value: 'PR'},
            {label: 'Rhode Island', value: 'RI'},
            {label: 'South Carolina', value: 'SC'},
            {label: 'South Dakota', value: 'SD'},
            {label: 'Tennessee', value: 'TN'},
            {label: 'Texas', value: 'TX'},
            {label: 'Utah', value: 'UT'},
            {label: 'Virginia', value: 'VA'},
            {label: 'Virgin Islands', value: 'VI'},
            {label: 'Vermont', value: 'VT'},
            {label: 'Washington', value: 'WA'},
            {label: 'Wisconsin', value: 'WI'},
            {label: 'West Virginia', value: 'WV'},
            {label: 'Wyoming', value: 'WY'}
        ],
        'XX':[{label: 'Not Applicable/Unknown', value: 'XX'}]
    }
}