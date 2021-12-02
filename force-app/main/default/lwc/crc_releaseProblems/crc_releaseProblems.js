import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
//import CRC_RP_CODE from '@salesforce/schema/Task';
// import CRC_RP_CODE from '@salesforce/schema/Task.Release_Problem_Code__c';
import saveReleaseProblem from '@salesforce/apex/CRC_CaseDetailController.saveReleaseProblem';
import getReleaseProblemCodePicklistValues from '@salesforce/apex/CRC_CaseDetailController.getReleaseProblemCodePicklistValues';
import { validateFieldsAndGetData, showErrorMessage, showSuccessMessage } from 'c/crc_util';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class Crc_releaseProblems extends LightningElement {
    @api releaseProblem = {};
    @api caseInformation = {};
    @api releaseProblems;
    @api actionsNeeded;
    isLoading = false;
    releaseProblemOpened;
    releaseProblemEditOpened;
    crcRPCode;
    isButtonDisabled = true;
    @track openReleaseProblems = [];
    @track closeReleaseProblems = [];
    rpCodeValueVsLabel = {};
    timeZone = TIME_ZONE;
    //recordTypeId;

    // @wire(getObjectInfo, {objectApiName : CRC_RP_CODE})
    // getObjectInfo ({error, data}) {
    //     if (error) {
    //         showErrorMessage(this, error);
    //     } else if (data) {
    //         for (const key in data.recordTypeInfos) {
    //             if(data.recordTypeInfos[key].name === 'CRC Release Problem') {
    //                 this.recordTypeId = data.recordTypeInfos[key].recordTypeId;
    //             }
    //         }
    //     }
    // }

    connectedCallback() {
        this.handleValueChange(); //modified by anuj
    }

    @api
    handleValueChange(){ //modified by anuj
        if(this.releaseProblems) {
            let releaseProblemsTemp = JSON.parse(JSON.stringify(this.releaseProblems));
            let openReleaseProblemsLocal = [];
            let closeReleaseProblemsLocal = [];
            releaseProblemsTemp.forEach(ele => {
                if(ele.Status == 'Completed') {
                    closeReleaseProblemsLocal.push(ele);
                } else {
                    openReleaseProblemsLocal.push(ele);
                }
            });
            this.openReleaseProblems = openReleaseProblemsLocal;
            this.closeReleaseProblems = closeReleaseProblemsLocal;
        }
    }

    openAddReleaseProblem() {
        this.releaseProblem = {};
        JSON.parse(JSON.stringify(this.crcRPCode)).forEach(element => {
            this.rpCodeValueVsLabel[element.value] = element.label;
        });
        this.releaseProblemOpened = true;
    }

    handleModalSave(event) {
        let data = validateFieldsAndGetData(this);

        // if(this.releaseProblems) {
        //     var _problems = JSON.parse(JSON.stringify(this.releaseProblems));
        //     var isProblemExist = _problems.find((item) => item.Release_Problem_Code__c === data.data.CRC_RP_CODE);
        //     if(isProblemExist) {
        //         showErrorMessage(this, data.data.CRC_RP_CODE+' type of problem already exists');
        //         return;
        //     }
        // }

        this.isLoading = true;
        //data.data.Stock__c = this.caseInformation.Stock__r.Stock__c;
        data.data.Stock__c = this.caseInformation.CRC_Stock_Number__c;
        data.data.CRC_Salvage_Id__c = this.caseInformation.CRC_Salvage_Id__c;
        data.data.CRC_Checksum__c = this.caseInformation.CRC_Checksum__c;
        data.data.PROVIDER_NAME = this.caseInformation.Account.Name;
        if(this.releaseProblemEditOpened){
            // data.data.CRC_Comment_DateTime__c = this.releaseProblem.CRC_Comment_DateTime__c;
            data.data.CRC_Comment_DateTime__c = this.releaseProblem.CRC_Comment_Datetime_Text__c
        }
        data.data.CRC_RP_CODE_DESCRIPTION = this.rpCodeValueVsLabel[data.data.CRC_RP_CODE];
        
        data.data.RP_Follow_Up_Date_Time__c = data.data.RP_Follow_Up_Date_Time__c.replace('.000Z', 'Z');
        
        if(data.isValid) {
            saveReleaseProblem({request : data.data , isUpdate : this.releaseProblemEditOpened})
            .then(result => {
                console.log('001then-->', result);
                var parser = new DOMParser();
                var data = parser.parseFromString(result.response, 'text/xml');
                var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                if(isRejected) {
                    showErrorMessage(this, isRejected.textContent);
                     this.isLoading = false;
                } else {
                    
                    showSuccessMessage(this, 'Release problem updated successfully');
                    // this.toggleView();
                     this.isLoading = false;
                }
            })
            .catch(error => {
                showErrorMessage(this, error);
            });
        } else {
            showErrorMessage(this, 'Please validate required fields');
        }
        
        this.releaseProblemOpened = undefined;
    }

    handleEditModal(event){
        JSON.parse(JSON.stringify(this.crcRPCode)).forEach(element => {
            this.rpCodeValueVsLabel[element.value] = element.label;
        });
        var selectedId = event.target.dataset.id;
        var selectedRecord = JSON.parse(JSON.stringify(this.openReleaseProblems)).find((element) => element.Id === selectedId);
        this.releaseProblem = selectedRecord;
        this.releaseProblemEditOpened = true;
        this.releaseProblemOpened = true;
    }
    handleModalCancel(event) {
        this.releaseProblemOpened = undefined;
    }

    @wire(getReleaseProblemCodePicklistValues, {})
    getPickupTypeValues ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.crcRPCode = JSON.parse(data.values);
        }
    }

    handleInputChange(event) {
        if(event.target.name === 'RP_Follow_Up_Date_Time__c') {
            if(event.target.value && new Date(event.target.value) < new Date()) {
                event.target.setCustomValidity('Followup date should be future date only');
                event.preventDefault();
                return;
            } else {
                event.target.setCustomValidity('');
            }
        }

        var data = validateFieldsAndGetData(this);
        if(data.isValid) {
            this.isButtonDisabled = undefined;
        } else {
            this.isButtonDisabled = true;
        }
    }
}