import { LightningElement, api, wire } from 'lwc';
import { validateFieldsAndGetData, getCoutryVsStateCodeMapping, showSuccessMessage, showErrorMessage,processActionCodes, salesforceCaseToRpmAssignment, salesforceAccountToRpmStorageLocation, getStateCodes, getCountryCodes } from 'c/crc_util';
import searchStorageLocation from '@salesforce/apex/CRC_CaseDetailController.searchStorageLocation';
import getStorageLocationDetail from '@salesforce/apex/CRC_CaseDetailController.getStorageLocationDetail';
import changeStorageLocationOnAssignment from '@salesforce/apex/CRC_CaseDetailController.changeStorageLocationOnAssignment';
import processStorageLocation from '@salesforce/apex/CRC_CaseDetailController.processStorageLocation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CRC_PICKUP_STORAGE_LOCATION_TYPE from '@salesforce/schema/Case.CRC_Pickup_Location_Type__c';
import STORAGE_REQUIREMENT_FIELD from '@salesforce/schema/Account.Storage_Requirements__c';
import STORAGE_LOCATION_STATUS from '@salesforce/schema/Account.Storage_Location_Status__c';
import CRC_STREET_ADDRESS_SEPARATOR from '@salesforce/label/c.CRC_Street_Address_Separator';

export default class Crc_storageInformation extends LightningElement {
    @api storageInformation = {};
    @api storageLocationContact = {};
    @api caseInformation = {};
    @api actionsNeeded;
    
    readonly = true;
    isLoading;
    fieldName;
    locations = [];
    cancelLabel;
    saveLabel;
    typeOptions;
    recordTypeId;
    caseRecordTypeId;
    storageLocationAdding;
    storageLocationId;
    selectedLocationId;
    openSearchLocation;
    storageDetailRPM = {};
    showAddLocationButton;
    rpmDetailResponse;
    isSelectionCriteriaPhone;
    storageRequirementOptions;
    openDetailStorageLocationModal;
    readonlyAddStorageLocation;
    locationSearchCriteria = {fieldName : 'Phone', value: ''};
    openAddStorageLocationModal;
    storageLocationStatusOptions;
    readonlyStorageDetailRPM = true;
    pickupLocationTypeApiVsValue = {};
    storageRequirementApiVsValue = {};
    storageLocationStatusApiVsValue = {};
    isStorageLocationBeingModify;

    storageStateOptions = getStateCodes();
    mailingStateOptions = getStateCodes();
    stateOptions = getStateCodes()['US'];
    countryVsStateMapping = getCoutryVsStateCodeMapping();
    countryOptions = getCountryCodes();

    // stateApiVsValue = {'Alberta' : 'AB', 'Ontario' : 'ON', 'Jalapa' : 'JA', 'Alaska' : 'AK', 'Florida' : 'FL', 'New Jersey' : 'NJ'};

    // countryApiVsValue = {'Canada' : 'CA', 'United States' : 'US', 'Mexico' : 'MX'};

    // get billingStateValue() {
    //     return this.storageInformation.BillingState;
    // }

    // get billingCountryValue() {
    //     return this.countryApiVsValue[this.storageInformation.BillingCountry];
    // }

    // get shippingStateValue() {
    //     return this.storageInformation.ShippingState;
    // }

    // get shippingCountryValue() {
    //     return this.countryApiVsValue[this.storageInformation.ShippingCountry];
    // }

    get pickupLocationType() {
        return this.pickupLocationTypeApiVsValue[this.caseInformation.CRC_Pickup_Location_Type__c];
    }

    get storageLocationStatus() {
        return this.storageLocationStatusApiVsValue[this.storageInformation.Storage_Location_Status__c];
    }

    get buttonLabel() {
        return (this.readonly) ? 'Edit' : 'View';
    }

    get phone() {
        return this.storageLocationContact.Phone;
    }

    get email() {
        return this.storageLocationContact.Email;
    }

    get fax() {
        return this.storageLocationContact.Fax;
    }

    get searchTypeClass() {
        return (this.isSelectionCriteriaPhone === true) ? 'slds-col slds-size_2-of-12 slds-large-size_2-of-12 slds-var-p-horizontal_small' : 'slds-col slds-size_9-of-12 slds-large-size_9-of-12 slds-var-p-horizontal_small';
    }

    get isResidentialStorage() {
        return this.storageInformation.CRC_Pickup_Location_Type__c === 'Residential';
    }

    get storageInformationLabel() {
        return (this.isResidentialStorage) ? 'Residential Information' : 'Storage Information';
    }

    get storageRequirementValues() {
        let selectedValues = [];
        if(this.storageInformation.Storage_Requirements__c) {
            this.storageInformation.Storage_Requirements__c.split(';').forEach(element => {
                selectedValues.push(this.storageRequirementApiVsValue[element]);
            });
        }
        return selectedValues;
    }

    get storageOwnerFirstName() {
        return (this.isResidentialStorage) ? this.caseInformation.CRC_VO_First_Name__c : '';
    }

    get storageOwnerLastName() {
        return (this.isResidentialStorage) ? this.caseInformation.CRC_VO_Last_Name__c : '';
    }

    get storageLocationSearchOptions() {
        return [
            {
                label: 'Address',
                value: 'Address'
            },
            {
                label: 'City',
                value: 'City'
            },
            {
                label: 'Zipcode',
                value: 'Zip'
            },
            {
                label: 'Phone',
                value: 'Phone'
            },
        ];
    }

    get foundLocation() {
        return (this.locations) ? this.locations.length > 0 : false;
    }

    errorCallback(error, stack) {
        console.error(stack);
        showErrorMessage(this, error);
    }

    @wire(getObjectInfo, {objectApiName : ACCOUNT_OBJECT})
    getObjectInfo ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.recordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === 'Storage Location');
        }
    }

    @wire(getObjectInfo, {objectApiName : CASE_OBJECT})
    getCaseObjectInfo ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.caseRecordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === 'CRC Storage Location');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STORAGE_REQUIREMENT_FIELD })
    getPicklistValues ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            data.values.forEach(element => {
                this.storageRequirementApiVsValue[element.label] = element.value;
            });
            this.storageRequirementOptions = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$caseRecordTypeId', fieldApiName: CRC_PICKUP_STORAGE_LOCATION_TYPE })
    getPickupTypeValues ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            let tempResult = {};
            data.values.forEach(element => {
                tempResult[element.label] = element.value;
            });
            this.pickupLocationTypeApiVsValue = tempResult;
            this.typeOptions = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STORAGE_LOCATION_STATUS })
    getStorageLocationStatus ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            data.values.forEach(element => {
                this.storageLocationStatusApiVsValue[element.label] = element.value;
            });
            this.storageLocationStatusOptions = data.values;
        }
    }

    connectedCallback() {
        this.isSelectionCriteriaPhone = true;
        this.doInit();        
    }

    doInit() {
        setTimeout(() => {
            this.handleMailingCountryChange({target: {value: this.storageInformation.ShippingCountry}});
            this.handleStorageCountryChange({target: {value: this.storageInformation.BillingCountry}});
        }, 3000);
    }

    toggleView() {
        this.readonly = !this.readonly;
    }

    handleSave() {
        try {
            let data = validateFieldsAndGetData(this);
            console.log('data2', data.data);
            if(data.data.SL_CASH_ONLY == true &&  (data.data.SL_IAA_CHECK == true || data.data.SL_TOWER_CHECK == true)){
                showErrorMessage(this, 'when payment is cash only then you can not select IAA Check or Tower Check');
                data.isValid = false;
            }else if(data.data.SL_CASH_ONLY == false &&  data.data.SL_IAA_CHECK == false && data.data.SL_TOWER_CHECK == false){
                showErrorMessage(this, 'Please select at least one payment method.');
                data.isValid = false;
            }else if(data.data.SL_IAA_CHECK == true && data.data.SL_TOWER_CHECK == true && data.data.SL_CHECK_PAYABLE_TO != null){
                showErrorMessage(this, 'Check Payble to is mandatory when IAA check or Tower Check is selected.');
                data.isValid = false;
            }
            if(data.isValid) {
                this.isLoading = true;
                data.data.Id = this.storageInformation.Id;
                let storageRequirementOptions = Object.values(this.storageRequirementOptions);
                let selectedOptions = data.data.Release_Requirement__c;
                let finalArray = {};
                storageRequirementOptions.forEach(element => {
                    if(selectedOptions && selectedOptions.includes(element.value)) {
                        finalArray[element.value] = 'A';
                    } else {
                        finalArray[element.value] = 'D';
                    }
                });
                data.data.CHECKSUM = (this.isResidentialStorage) ? this.caseInformation.CRC_Res_Checksum__c : this.storageInformation.CRC_checksum__c ;
                let tempAccountToProcess = (this.isResidentialStorage) ? JSON.parse(JSON.stringify(this.caseInformation)) : JSON.parse(JSON.stringify(this.storageInformation));
                tempAccountToProcess.Storage_Location_Status__c = this.storageLocationStatusApiVsValue[tempAccountToProcess.Storage_Location_Status__c];
                console.log(data.data, salesforceCaseToRpmAssignment(tempAccountToProcess));
                let finalData = processActionCodes(data.data, salesforceCaseToRpmAssignment(tempAccountToProcess));
                finalData.SL_RELEASE_REQUIREMENTS = finalArray;

                if(!this.isResidentialStorage) {
                    var operationalHoursCmp = this.template.querySelector('c-crc_operational-hours');
                    finalData.hours = JSON.parse(JSON.stringify(operationalHoursCmp.getData()));
                    if(!finalData.hours) {
                        this.isLoading = undefined;
                        return;
                    }

                } else {
                    finalData.STORAGE_LOCATION_ID = this.caseInformation.CRC_Res_Location_Id__c;
                    
                    if(!finalData.hasOwnProperty('CONTACT.ADDRESS_LINE1') && (finalData.hasOwnProperty('CONTACT.CITY') || finalData.hasOwnProperty('CONTACT.STATE') || finalData.hasOwnProperty('CONTACT.ZIP'))) {
                        finalData['CONTACT.ADDRESS_LINE1'] = {ActionCode: '', value: data.data['CONTACT.ADDRESS_LINE1']};
                    }
                    if(!finalData.hasOwnProperty('CONTACT.CITY') && (finalData.hasOwnProperty('CONTACT.ADDRESS_LINE1') || finalData.hasOwnProperty('CONTACT.STATE') || finalData.hasOwnProperty('CONTACT.ZIP'))) {
                        finalData['CONTACT.CITY'] = {ActionCode: '', value: data.data['CONTACT.CITY']};
                    }
                    if(!finalData.hasOwnProperty('CONTACT.STATE') && (finalData.hasOwnProperty('CONTACT.ADDRESS_LINE1') || finalData.hasOwnProperty('CONTACT.CITY') || finalData.hasOwnProperty('CONTACT.ZIP'))) {
                        finalData['CONTACT.STATE'] = {ActionCode: '', value: data.data['CONTACT.STATE']};
                    }
                    if(!finalData.hasOwnProperty('CONTACT.ZIP') && (finalData.hasOwnProperty('CONTACT.ADDRESS_LINE1') || finalData.hasOwnProperty('CONTACT.CITY') || finalData.hasOwnProperty('CONTACT.STATE'))) {
                        finalData['CONTACT.ZIP'] = {ActionCode: '', value: data.data['CONTACT.ZIP']};
                    }
                }
                console.log('finalData', finalData);
                processStorageLocation({request : finalData})
                .then(result => {
                    var parser = new DOMParser();
                    var data = parser.parseFromString(result.response, 'text/xml');
                    var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                    if(isRejected) {
                        showErrorMessage(this, isRejected.textContent);
                    } else {
                        var storageLocationId = data.querySelector('STORAGE_LOCATION_ID').textContent;
                        showSuccessMessage(this, 'Storage location updated successfully');
                        this.toggleView();
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    showErrorMessage(this, error);
                    this.isLoading = false;
                });
            }
        } catch (error) {
            showErrorMessage(this, error);
        }
    }

    handleSearchChange() {
        this.openSearchLocation = true;
    }

    modalCancel() {
        this.locations = undefined;
        this.locationSearchCriteria = {};
        this.openSearchLocation = false;
    }

    modalSave() {
        this.openSearchLocation = false;
    }

    handleChange(event) {
        this.fieldName = event.target.value;
    }

    handleLocationSearch(event) {
        if((this.locationSearchCriteria.fieldName === 'Phone' && !this.locationSearchCriteria.value) ||
            (this.locationSearchCriteria.fieldName !== 'Phone') && (!this.locationSearchCriteria.value && 
                                                                    !this.locationSearchCriteria.LocationName && 
                                                                    !this.locationSearchCriteria.State && 
                                                                    !this.locationSearchCriteria.Country)) {
            showErrorMessage(this, 'Please enter the search text');
        } else {
            event.target.disabled = true;
            this.isLoading = true;
            let payload = { inputData : JSON.parse(JSON.stringify(this.locationSearchCriteria))};
            searchStorageLocation(payload)
            .then(result => {
                console.log(result);
                this.parseStorageLookupResponse(result);
                this.isLoading = false;
                this.template.querySelector('.searchLocation').disabled = false;
            })
            .catch(error => {
                this.isLoading = false;
                showErrorMessage(this, error);
                event.target.disabled = false;
            });
        }
    }

    getStorageLocationDetail(event) {
        getStorageLocationDetail({locationId : event.target.dataset.id})
            .then(result => {
                this.parseStorageDetailResponse(result);
            })
            .catch(error => {
                showErrorMessage(this, error);
            });
    }

    jsonToXml(result) {
        var xml = '';
        for (var prop in obj) {
            xml += obj[prop] instanceof Array ? '' : "<" + prop + ">";
            if (obj[prop] instanceof Array) {
                for (var array in obj[prop]) {
                    xml += "<" + prop + ">";
                    xml += jsonToXml(new Object(obj[prop][array]));
                    xml += "</" + prop + ">";
                }
            } else if (typeof obj[prop] == "object") {
                xml += jsonToXml(new Object(obj[prop]));
            } else {
                xml += obj[prop];
            }
            xml += obj[prop] instanceof Array ? '' : "</" + prop + ">";
        }
        var xml = xml.replace(/<\/?[0-9]{1,}>/g, '');
        return xml
    }

    parseStorageDetailResponse(result) {
        this.rpmDetailResponse = result;
        var parser = new DOMParser();
        var data = parser.parseFromString(result.response, 'text/xml');
        var vehicleLocation = data.querySelector('VEHICLE_LOCATION');
        var finalData = {};
        for(let a = 0; a < vehicleLocation.children.length; a++) {
            let child = vehicleLocation.children[a];
            if(child.children.length > 0) {
                finalData[child.nodeName] = {};
                for(let b = 0; b < child.children.length; b++) {
                    let nestedChild = child.children[b];
                    if(nestedChild.children.length > 0) {
                        finalData[child.nodeName][nestedChild.nodeName] = {};
                        for (let c = 0; c < nestedChild.children.length; c++) {
                            const grandChild = nestedChild.children[c];
                            finalData[child.nodeName][nestedChild.nodeName][grandChild.nodeName] = grandChild.textContent;
                        }
                    } else {
                        finalData[child.nodeName][nestedChild.nodeName] = nestedChild.textContent;
                    }
                }
            } else {
                finalData[child.nodeName] = (child.textContent === 'Y') ? true : (child.textContent === 'N') ? false : child.textContent;
            }
        }

        if(!finalData.hasOwnProperty('CONTACT')) {
            finalData.CONTACT = {};
        } else {
            finalData.CONTACT.ADDRESS_LINE1 = finalData.CONTACT.ADDRESS_LINE1 + CRC_STREET_ADDRESS_SEPARATOR + finalData.CONTACT.ADDRESS_LINE2;
        }

        if(!finalData.hasOwnProperty('MAILING_ADDRESS')) {
            finalData.MAILING_ADDRESS = {};
        } 

        if(!finalData.MAILING_ADDRESS.hasOwnProperty('CONTACT')) {
            finalData.MAILING_ADDRESS.CONTACT = {};
        } else {
            finalData.MAILING_ADDRESS.CONTACT.ADDRESS_LINE1 = finalData.MAILING_ADDRESS.CONTACT.ADDRESS_LINE1 + CRC_STREET_ADDRESS_SEPARATOR + finalData.MAILING_ADDRESS.CONTACT.ADDRESS_LINE2;
        }

        console.log('====================================');
        console.log(finalData);
        console.log('====================================');

        this.storageDetailRPM = finalData;
        this.cancelLabel = 'Cancel'
        this.saveLabel = 'Edit';
        this.openDetailStorageLocationModal = true;
    }

    addNewStorageLocation() {
        this.readonlyAddStorageLocation = undefined;
        
        this.openAddStorageLocationModal = true;
        this.readonly = undefined;
    }

    parseStorageLookupResponse(result) {
		var parser = new DOMParser();
        var finalLocations = [];
		var response = parser.parseFromString(result.response, 'text/xml');
		var statusCode = response.querySelector('STATUS_CODE').textContent.trim();
		var locations = response.querySelectorAll('ALTERNATIVE_LOCATION');
        if(locations.length > 0) {
            locations.forEach(location => {
                var locationTemp = {};
                for(let a = 0; a < location.children.length; a++) {
                    let child = location.children[a];
                    locationTemp[child.nodeName] = child.textContent;
                }
                finalLocations.push(locationTemp);
            });
        }
        if(finalLocations.length === 0) {
            this.locations = undefined;
            this.showAddLocationButton = true;
        } else {
            this.showAddLocationButton = undefined;
            this.locations = finalLocations;
        }
    }

    recordEditFormSuccessHandler(event) {
        let data = JSON.parse(JSON.stringify(event.detail));
        let finalObject = {};
        for (const key in data.fields) {
            finalObject[key] = data.fields[key].value;
        }
        this.locations = [finalObject];
        this.storageLocationId = undefined;
        this.openDetailStorageLocationModal = undefined;
    }

    modalCancelNewStorageLocation(event) {
        this.readonlyStorageDetailRPM = true;
        this.openDetailStorageLocationModal = undefined;
    }

    modalSaveNewStorageLocation(event) {
        if(event.detail === 'Edit') {
            this.readonlyStorageDetailRPM = false;
        } else if(event.detail === 'Save') {

        }
    }

    handleLocationSelection(event) {
        this.selectedLocationId= (event.target.checked) ? event.target.dataset.location : undefined;
        var allInputs = this.template.querySelectorAll('.checkboxes');
        allInputs.forEach(element => {
            if(element.dataset.location !== this.selectedLocationId) {
                element.checked = false;
            }
        });
    }

    handleLocationSearchChange(event) {
        this.locationSearchCriteria[event.target.name] = event.target.value;
        if(event.target.name === 'fieldName') {
            if (event.target.value === 'Phone') {
                this.isSelectionCriteriaPhone = true;
            } else {
                this.isSelectionCriteriaPhone = undefined;
            }
        } 

        if(event.target.name === 'Country') {
            this.stateOptions = this.countryVsStateMapping[event.target.value];
        }
    }
    
    modalCancelAddStorageLocation() {
        this.openAddStorageLocationModal = undefined;
        this.readonly = true;
    }

    modalSaveAddStorageLocation() {
        this.storageLocationAdding = true;
        let component = this.template.querySelector('c-crc_storage-information-r-p-m');
        if(component) {
            component.handleSave()
                .then(result => {
                    console.log('success');
                    this.openAddStorageLocationModal = undefined;
                    this.openSearchLocation = undefined;
                })
                .catch(error => {
                    console.log('failed');
                });
        }
    }

    closeModal() {
        this.openAddStorageLocationModal = undefined;
        this.storageLocationAdding = false;
    }

    changeStorageLocationOnAssignment() {
        let data = {};
        data.STORAGE_LOCATION_ID = this.selectedLocationId;
        //data.IAAI_STOCK_NUMBER = this.caseInformation.Stock__r.Stock__c;
        data.IAAI_STOCK_NUMBER = this.caseInformation.CRC_Stock_Number__c;
        data.SALVAGE_ID = this.caseInformation.CRC_Salvage_Id__c;
        data.CHECKSUM = this.caseInformation.CRC_Checksum__c;
        data.PROVIDER_NAME = this.caseInformation.Account.Name;
        console.log('payload-->', data);

        if(data.STORAGE_LOCATION_ID) {
            this.isStorageLocationBeingModify = true;
            changeStorageLocationOnAssignment({request : data})
                .then(result => {
                    var parser = new DOMParser();
                    var data = parser.parseFromString(result.response, 'text/xml');
                    var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                    if(isRejected) {
                        showErrorMessage(this, isRejected.textContent);
                    } else {
                        showSuccessMessage(this, 'Storage location has been modified successfully');
                        this.openSearchLocation = undefined;
                    }
                    this.isStorageLocationBeingModify = false;
                })
                .catch(error => {
                    showErrorMessage(this, error);
                    this.isStorageLocationBeingModify = false;
                });
        } else {
            showErrorMessage(this, 'Please select storage first');
        }
    }

    handleMailingCountryChange(event) {
        this.mailingStateOptions = this.countryVsStateMapping[event.target.value];
    }

    handleStorageCountryChange(event) {
        this.storageStateOptions = this.countryVsStateMapping[event.target.value];
    }
}