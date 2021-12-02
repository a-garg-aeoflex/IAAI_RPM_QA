import { api, LightningElement, wire } from 'lwc';
import getCaseContactData from '@salesforce/apex/CRC_ReleaseAssignmentController.getCaseContactData';
import saveVehicleInformation from '@salesforce/apex/CRC_CaseDetailController.saveVehicleInformation';
import PHONE_TYPE_OPTIONS from '@salesforce/schema/Case.CRC_VO_Primary_Phone_Type__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { showErrorMessage, salesforceCaseToRpmAssignment, validateFieldsAndGetData, processActionCodes, showSuccessMessage } from 'c/crc_util';

export default class CRC_ReleaseAssignmentContacts extends LightningElement {
    @api recordId;

    openModal = false;
    openEdit = true;
    caseContactData;
    actionsNeeded;
    branchManager = {};
    adjuster = {};


    stateOptions = [
        {label: '--None--', value: ''},
        {label: 'Alberta', value: 'AB'},
        {label: 'Ontario', value: 'ON'},
        {label: 'Jalapa', value: 'JA'},
        {label: 'Alaska', value: 'AK'},
        {label: 'Florida', value: 'FL'},
        {label: 'Texas', value: 'TX'},
        {label: 'New Jersey', value: 'NJ'}
    ];

    countryOptions = [
        {label: '--None--', value: ''},
        {label: 'Canada', value: 'CA'},
        {label: 'United States', value: 'US'},
        {label: 'Mexico', value: 'MX'}
    ];

    phoneTypeOptions;
    phoneTypeApiVsValue = {};

    get isResidential() {
        return (!this.caseContactData) ? false : this.caseContactData.CRC_Pickup_Location_Type__c === 'Residential' ? true : false ;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: PHONE_TYPE_OPTIONS })
    getPicklistValues ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            data.values.forEach(element => {
                this.phoneTypeApiVsValue[element.label] = element.value;
            });
            this.phoneTypeOptions = data.values;
        }
    }

    connectedCallback() {
        this.doInit();
    }

    doInit() {
        getCaseContactData({rAId : this.recordId})
        .then(result => {
            if(result.case) {
                this.actionsNeeded = (result.case.OwnerId && result.case.OwnerId.startsWith('005')) ? true : false;
                this.caseContactData = result.case;
                this.branchManager = (result.branchManager) ? result.branchManager : {};
                this.adjuster = (result.adjuster) ? result.adjuster : {};
                this.showSpinner = false;
            }
         })
        .catch(error => {
            console.error(error);
            showErrorMessage(this, error);
            this.showSpinner = false;
        })
    }

    handleSave() {
        let response = validateFieldsAndGetData(this);
        if(response.isValid) {
            let finalData = processActionCodes(response.data, salesforceCaseToRpmAssignment(JSON.parse(JSON.stringify(this.caseContactData))));
            finalData.SALVAGE_ID = this.caseContactData.CRC_Salvage_Id__c;
            finalData.CHECKSUM = this.caseContactData.CRC_Checksum__c;
            //finalData.IAAI_STOCK_NUMBER = this.caseContactData.Stock__r.Stock__c;
            finalData.IAAI_STOCK_NUMBER = this.caseContactData.CRC_Stock_Number__c;
            finalData.PROVIDER_NAME = this.caseContactData.Account.Name;
            
            this.isLoading = true;
            saveVehicleInformation({request : finalData})
                .then(result => {
                    console.log(result);
                    this.isLoading = false;
                    var parser = new DOMParser();
                    var data = parser.parseFromString(result.response, 'text/xml');
                    var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                    if(isRejected) {
                        showErrorMessage(this, isRejected.textContent);
                        this.isLoading = false;
                    } else {
                        showSuccessMessage(this, 'Saved successfully');
                    }
                })
                .catch(error => {
                    showErrorMessage(this, error);
                    this.isLoading = false;
                });
        }
    }

    showModal() {
        console.log('test');
        this.openModal = true;
    }

    closeModel() {
        console.log('test');
        this.openModal = false;
    }

    openEditForm(){
        this.openEdit = false;
    }

    preventAlphabets(event) {
        if(event.keyCode >= 48 && event.keyCode <= 57) {
            // 0-9
        } else {
            event.preventDefault();
        }
    }
}