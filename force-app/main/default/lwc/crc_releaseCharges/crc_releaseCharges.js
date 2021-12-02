import { LightningElement, api, wire, track } from 'lwc';
import RELEASE_CHARGES from '@salesforce/schema/Release_Charge__c';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { showErrorMessage, showSuccessMessage, reversePicklistValues, syncRPM2SF } from 'c/crc_util';
import manageReleaseCharges from '@salesforce/apex/CRC_CaseDetailController.manageReleaseCharges';

export default class Crc_releaseCharges extends LightningElement {
    @api releaseCharges = [];
    @api actionsNeeded;
    @api caseInformation = {};

    isLoading;
    actualCharge = 0;
    finalData = {};
    needFooterActions;
    originalCharge = 0;
    chargeTypeOptions = [];
    responsiblePartyOptions = [];
    recordsToDelete = [];

    @track records = [];

    get totalCharge() {
        return this.actualCharge;
    }

    set updateTotalCharge(value) {
        this.actualCharge = value;
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: RELEASE_CHARGES, recordTypeId: '012000000000000AAA' })
    getPicklistValuesByRecordType ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.chargeTypeOptions = data.picklistFieldValues.Charge_Type__c.values;
            this.eventCategoryOptions = data.picklistFieldValues.Event_Category__c.values;
            this.responsiblePartyOptions = data.picklistFieldValues.Responsible_Party__c.values;
            this.doInit(true);
        }
    }

    doInit(readonly) {
        if(this.releaseCharges !== undefined) {
            let tempData = JSON.parse(JSON.stringify(this.releaseCharges));
            var a = 1;
            var needTableActions = false;
            tempData.forEach(element => {
                element.tempId = a;
                element.chargeTypeText = reversePicklistValues(this.chargeTypeOptions)[element.Charge_Type__c];
                element.eventCategoryText = reversePicklistValues(this.eventCategoryOptions)[element.Event_Category__c];
                element.responsiblePartyText = reversePicklistValues(this.responsiblePartyOptions)[element.Responsible_Party__c];
                element.needEdit = false;
                element.type = (element.eventCategoryText !== 'Assignment') ? 'U' : '';
                element.readonly = (readonly) ? true : (element.eventCategoryText === 'Assignment') ? true : false;
                element.needDelete = (element.eventCategoryText !== 'Assignment' && !readonly) ? true : false;
                if(element.eventCategoryText !== 'Assignment') {
                    needTableActions = true;
                }
                a++;
            });
    
            if(!readonly && needTableActions) {
                this.needFooterActions = true;
            }
    
            this.records = tempData;
            var tempRecords = JSON.parse(JSON.stringify(this.records));
            var _totalCharge = 0;
            tempRecords.forEach(element => {
                if(element.eventCategoryText === 'Release') {
                    _totalCharge += parseFloat(element.Amount__c) + parseFloat(element.Tax_Amount__c);
                }
            });
            this.actualCharge = _totalCharge;
            this.originalCharge = _totalCharge;
        }
    }

    addHandler() {
        var tempData = (this.records !== undefined) ? JSON.parse(JSON.stringify(this.records)) : [];
        this.records = undefined;
        tempData.push({readonly: false, isNew : true, type : 'A', tempId : (tempData.length > 0) ? tempData[tempData.length-1].tempId+1 : 0, eventCategoryText : 'Release', needDelete : true});
        this.records = tempData;
        this.needFooterActions = true;
    }

    editHandler(event) {
        var recordId = event.target.dataset.id;
        this.records.forEach(element => {
            if(element.Id === recordId) {
                element.readonly = !element.readonly;
            }
        });

    }

    deleteHandler(event) {
        var tempData = JSON.parse(JSON.stringify(this.records));
        this.records = undefined;
        var indexToRemove = 0;
        let data = {};
        var remainingData = [];
        if(!event.target.dataset.id) {
            for (let index = 0; index < tempData.length; index++) {
                if(tempData[index].Id === event.target.dataset.id) {
                    indexToRemove = index;
                    data = tempData[index];
                    tempData.splice(indexToRemove, 1);
                    this.records = tempData;
                    break;
                }
            }
        } else {
            for (let index = 0; index < tempData.length; index++) {
                if(tempData[index].Id === event.target.dataset.id) {
                    indexToRemove = index;
                    data = tempData[index];
                } else {
                    remainingData.push(tempData[index]);
                }
            }

            console.log(data);
            data.ActionCode = 'D';
            this.recordsToDelete.push(data);

            console.log('remainingData', remainingData);

            this.records = remainingData;

            // if(Object.keys(data).length > 0) {
            //     var payload = {};
            //     data.ActionCode = 'D';
            //     payload.charges = data;
            //     payload.IAAI_STOCK_NUMBER = this.caseInformation.Stock__r.Stock__c;
            //     payload.SALVAGE_ID = this.caseInformation.CRC_Salvage_Id__c;
            //     payload.CHECKSUM = this.caseInformation.CRC_Checksum__c;
            //     payload.PROVIDER_NAME = this.caseInformation.Account.Name;
            //     console.log('payload-->', payload);
        
            //     this.recordsToDelete.push(data);

            //     console.log('remainingData', remainingData);

            //     this.records = remainingData;

            //     // this.isLoading = true;
            //     // manageReleaseCharges({request : payload})
            //     //     .then(result => {
            //     //         console.log(result);
            //     //         var parser = new DOMParser();
            //     //         var response = parser.parseFromString(result.response, 'text/xml');
            //     //         var isRejected = response.querySelector('REJECT_REASON_DESCRIPTION');
            //     //         if(isRejected) {
            //     //             showErrorMessage(this, isRejected.textContent);
            //     //         } else {
            //     //             showSuccessMessage(this, 'Release Charges saved successfully');
            //     //         }
            //     //         this.isLoading = false;
            //     //         tempData.splice(indexToRemove, 1);
            //     //         this.records = tempData;
            //     //     })
            //     //     .catch(error => {
            //     //         showErrorMessage(this, error);
            //     //         this.isLoading = false;
            //     //     });
            // } else {
            //     showErrorMessage(this, 'Something went wrong. Please contact to System Administrator');
            // }
        }
    }

    handleSave() {
        let data = {};
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group, lightning-textarea, lightning-dual-listbox')]
            .reduce((validSoFar, inputCmp) => {
                if(inputCmp.name && !inputCmp.readOnly) {
                    if(!data.hasOwnProperty(inputCmp.dataset.id) && !data.hasOwnProperty(inputCmp.dataset.tempid)) {
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid] = {ActionCode : inputCmp.dataset.type};
                    }
                    data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid][inputCmp.name] = inputCmp.value;
                    data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Event_Category__c'] = 'RLS';

                    if(inputCmp.dataset.type === 'U') {
                        let tempRecords = JSON.parse(JSON.stringify(this.records));
                        var actualRecord = tempRecords.find((item) => item.Id === inputCmp.dataset.id);
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Charge_Type__c'] = actualRecord.Charge_Type__c;
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Responsible_Party__c'] = actualRecord.Responsible_Party__c;
                    }
                } 
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true); 

        // console.log(data);

        console.log('data', data);
        console.log('recordsToDelete', JSON.parse(JSON.stringify(this.recordsToDelete)));
        var payload = {};
        payload.charges = Object.values(data);
        payload.charges.push(...JSON.parse(JSON.stringify(this.recordsToDelete)));
        if(payload.charges.length > 0) {
            //payload.IAAI_STOCK_NUMBER = this.caseInformation.Stock__r.Stock__c;
            payload.IAAI_STOCK_NUMBER = this.caseInformation.CRC_Stock_Number__c;
            payload.SALVAGE_ID = this.caseInformation.CRC_Salvage_Id__c;
            payload.CHECKSUM = this.caseInformation.CRC_Checksum__c;
            payload.PROVIDER_NAME = this.caseInformation.Account.Name;
            payload.VR_TOTAL_CHECK_AMOUNT = {'ACTION_CODE' : (this.releaseCharges !== undefined && this.releaseCharges.length > 0) ? 'U' : 'A', 'value': this.totalCharge};
            console.log('payload-->', payload);
    
            this.isLoading = true;
            manageReleaseCharges({request : payload})
                .then(result => {
                    console.log(result);
                    var parser = new DOMParser();
                    var response = parser.parseFromString(result.response, 'text/xml');
                    var isRejected = response.querySelector('REJECT_REASON_DESCRIPTION');
                    if(isRejected) {
                        showErrorMessage(this, isRejected.textContent);
                    } else {
                        showSuccessMessage(this, 'Release Charges saved successfully');
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    showErrorMessage(this, error);
                    this.isLoading = false;
                });
        } else {
            showErrorMessage(this, 'Please add/update release charges');
        }
    }

    editAllHandler() {
        this.doInit(false);
        this.needFooterActions = true;
    }

    cancelHandler() {
        this.doInit(true);
        this.needFooterActions = false;
    }

    rowChangeHandler() {
        let data = {};
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group, lightning-textarea, lightning-dual-listbox')]
            .reduce((validSoFar, inputCmp) => {
                if(inputCmp.name && !inputCmp.readOnly) {
                    if(!data.hasOwnProperty(inputCmp.dataset.id) && !data.hasOwnProperty(inputCmp.dataset.tempid)) {
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid] = {ActionCode : inputCmp.dataset.type};
                    }
                    data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid][inputCmp.name] = inputCmp.value;
                    data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Event_Category__c'] = 'RLS';

                    if(inputCmp.dataset.type === 'U') {
                        let tempRecords = JSON.parse(JSON.stringify(this.records));
                        var actualRecord = tempRecords.find((item) => item.Id === inputCmp.dataset.id);
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Charge_Type__c'] = actualRecord.Charge_Type__c;
                        data[(inputCmp.dataset.id) ? inputCmp.dataset.id : inputCmp.dataset.tempid]['Responsible_Party__c'] = actualRecord.Responsible_Party__c;
                    }
                } 
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true); 
        console.log('data', data);
        let finalCharge = 0;
        Object.values(data).forEach(element => {
            finalCharge += parseFloat(element.Amount__c) + parseFloat(element.Tax_Amount__c);
        });
        console.log(finalCharge);
        this.updateTotalCharge = finalCharge;
    }
}