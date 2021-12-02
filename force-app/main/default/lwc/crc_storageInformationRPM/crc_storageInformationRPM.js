import { LightningElement, api, wire } from 'lwc';
import { validateFieldsAndGetData, getCoutryVsStateCodeMapping, showSuccessMessage, showErrorMessage, getCountryCodes } from 'c/crc_util';
import searchStorageLocation from '@salesforce/apex/CRC_CaseDetailController.searchStorageLocation';
import getStorageLocationDetail from '@salesforce/apex/CRC_CaseDetailController.getStorageLocationDetail';
import addStorageLocation from '@salesforce/apex/CRC_CaseDetailController.addStorageLocation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CRC_PICKUP_STORAGE_LOCATION_TYPE from '@salesforce/schema/Case.CRC_Pickup_Location_Type__c';
import STORAGE_REQUIREMENT_FIELD from '@salesforce/schema/Account.Storage_Requirements__c';
import STORAGE_LOCATION_STATUS from '@salesforce/schema/Account.Storage_Location_Status__c';
import CASE_OBJECT from '@salesforce/schema/Case';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class Crc_storageInformationRPM extends LightningElement {
    @api storageInformation = {CONTACT : {}, MAILING_ADDRESS:{CONTACT:{}}};
    @api caseInformation = {};
    @api actionsNeeded;
    @api mode;
    @api rpmResponse;
    
    readonly;
    isLoading = true;
    fieldName;
    locations = [];
    cancelLabel;
    saveLabel;
    typeOptions;
    rpmHoursData;
    storageLocationId;
    selectedLocationId;
    openSearchLocation;
    storageDetailRPM = {};
    showAddLocationButton;
    caseRecordTypeId;
    storageRecordTypeId;
    isSelectionCriteriaPhone;
    storageRequirementOptions;
    openDetailStorageLocationModal;
    readonlyAddStorageLocation;
    locationSearchCriteria = {fieldName : 'Phone', value: ''};
    openAddStorageLocationModal;
    storageLocationStatusOptions;
    readonlyStorageDetailRPM;
    storageRequirementApiVsValue = {};
    storageLocationStatusApiVsValue = {};

    storageStateOptions = getCoutryVsStateCodeMapping()['US'];
    mailingStateOptions = getCoutryVsStateCodeMapping()['US'];
    countryOptions = getCountryCodes();
    countryVsStateMapping = getCoutryVsStateCodeMapping();

    get buttonLabel() {
        return (this.readonly) ? 'Edit' : 'View';
    }

    get storageRequirementValues() {
        return (this.storageInformation.Storage_Requirements__c) ? this.storageInformation.Storage_Requirements__c.split(';') : [];
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

    get releaseRequirementValue() {
        var finalValue = '';
        if(this.storageRequirementOptions && this.storageInformation.Storage_Requirements__c) {
            var tempStorageRequirementOptions = JSON.parse(JSON.stringify(this.storageRequirementOptions));
            var tempMapping = {};
            if(tempStorageRequirementOptions) {
                tempStorageRequirementOptions.forEach(element => {
                    tempMapping[element.value] = element.label;
                });
            }
            this.storageInformation.Storage_Requirements__c.split(';').forEach(element => {
                finalValue += (finalValue) ? '; '+tempMapping[element] : tempMapping[element];
            });
        }
        return finalValue;
    }

    get foundLocation() {
        return (this.locations) ? this.locations.length > 0 : false;
    }

    @wire(getObjectInfo, {objectApiName : CASE_OBJECT})
    getCaseObjectInfo ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.caseRecordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === 'CRC Storage Location');
            console.log('this.caseRecordTypeId', this.caseRecordTypeId);
        }
    }

    @wire(getObjectInfo, {objectApiName : ACCOUNT_OBJECT})
    getAccountObjectInfo ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.storageRecordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === 'Storage Location');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$storageRecordTypeId', fieldApiName: STORAGE_REQUIREMENT_FIELD })
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
            console.log('getPickupTypeValues', data);
            let tempResult = {};
            data.values.forEach(element => {
                tempResult[element.label] = element.value;
            });
            this.pickupLocationTypeApiVsValue = tempResult;
            this.typeOptions = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$storageRecordTypeId', fieldApiName: STORAGE_LOCATION_STATUS })
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
        this.doInit();
    }

    doInit() {
        this.isSelectionCriteriaPhone = true;
        if(this.mode === 'view') {
            this.readonly = true;
            this.readonlyStorageDetailRPM = true;
            var storageInformation = JSON.parse(JSON.stringify(this.storageInformation));
            storageInformation.CONTACT = {};
            storageInformation.MAILING_ADDRESS = {CONTACT : {}};
            this.storageDetailRPM = this.storageInformation;
        } else {
            this.storageDetailRPM = {CONTACT : {}, MAILING_ADDRESS:{CONTACT:{}}};
        }
        this.fetchHoursFromRPMResponse();
        this.isLoading = undefined;
        if(this.mode !== 'view') {
            let data = JSON.parse(JSON.stringify(this.storageInformation));
            data.CONTACT.COUNTRY_CODE = 'US';
            data.MAILING_ADDRESS.CONTACT.COUNTRY = 'US';
            this.storageInformation = data;
        }
    }

    fetchHoursFromRPMResponse() {
        if(this.rpmResponse) {
            var parser = new DOMParser();
            var data = parser.parseFromString(this.rpmResponse.response, 'text/xml');
            var rpmHours = data.querySelectorAll('HOURS');
            var hours = [];
            if(rpmHours.length > 0) {
                rpmHours.forEach(element => {
                    var hour = {};
                    for(var i = 0; i < element.children.length; i++) {
                        hour[element.children[i].nodeName] = element.children[i].textContent;
                    }
                    hours.push(hour);
                });
                this.rpmHoursData = hours;
            }
        }
    }

    toggleView() {
        this.readonly = !this.readonly;
    }

    @api
    handleSave() {
        return new Promise((resolve, reject) => {
            try {
                let data = validateFieldsAndGetData(this);
            
                if(data.isValid) {
                    let selectedOptions = JSON.parse(JSON.stringify(data.data.Release_Requirement__c));
                    let finalArray = {};
                    selectedOptions.forEach(element => {
                        finalArray[element] = 'A';
                    });
                    let finalData = data.data;
                    finalData.SL_RELEASE_REQUIREMENTS = finalArray;
                    finalData.hours = JSON.parse(JSON.stringify(this.template.querySelector('c-crc_operational-hours').getData()));
                    finalData.Id = this.storageInformation.Id;
                    //finalData.IAAI_STOCK_NUMBER = this.caseInformation.Stock__r.Stock__c;
                    finalData.IAAI_STOCK_NUMBER = this.caseInformation.CRC_Stock_Number__c;
                    finalData.SALVAGE_ID = this.caseInformation.CRC_Salvage_Id__c;
                    finalData.CHECKSUM = this.caseInformation.CRC_Checksum__c;
                    finalData.PROVIDER_NAME = this.caseInformation.Account.Name;
                    this.isLoading = true;
                    addStorageLocation({request : finalData})
                    .then(result => {
                        var parser = new DOMParser();
                        var data = parser.parseFromString(result.response, 'text/xml');
                        var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                        if(isRejected) {
                            showErrorMessage(this, isRejected.textContent);
                            this.isLoading = false;
                            reject();
                        } else {
                            var storageLocationId = data.querySelector('TEMP_STORAGE_LOCATION_ID').textContent;
                            showSuccessMessage(this, 'Storage location saved successfully. Location Id is '+storageLocationId);
                            const event = new CustomEvent('closemodal', {
                                detail: { locationId : storageLocationId }
                            });
                            this.dispatchEvent(event);
                            // this.toggleView();
                            this.isLoading = false;
                            resolve();
                        }
                    })
                    .catch(error => {
                        showErrorMessage(this, error);
                        this.isLoading = false;
                        reject();
                    });
                }
            } catch (error) {
                showErrorMessage(this, error);
                reject();
            }
        });
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
                console.log(result);
                this.parseStorageDetailResponse(result);
            })
            .catch(error => {
                showErrorMessage(this, error);
            });
    }

    parseStorageDetailResponse(result) {
        var parser = new DOMParser();
        var data = parser.parseFromString(result.response, 'text/xml');
        console.log('====================================');
        console.log(result.response);
        console.log(data);
        console.log('====================================');
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
                finalData[child.nodeName] = child.textContent;
            }
        }

        if(!finalData.hasOwnProperty('CONTACT')) {
            finalData.CONTACT = {};
        }

        if(!finalData.hasOwnProperty('MAILING_ADDRESS')) {
            finalData.MAILING_ADDRESS = {};
        }

        if(!finalData.MAILING_ADDRESS.hasOwnProperty('CONTACT')) {
            finalData.MAILING_ADDRESS.CONTACT = {};
        }

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
            // showErrorMessage(this, 'No Location Found');
            this.locations = undefined;
            this.showAddLocationButton = true;
        } else {
            this.showAddLocationButton = undefined;
            this.locations = finalLocations;
        }
    }
    
    handleMailingCountryChange(event) {
        this.mailingStateOptions = this.countryVsStateMapping[event.target.value];
    }

    handleStorageCountryChange(event) {
        this.storageStateOptions = this.countryVsStateMapping[event.target.value];
    }
}