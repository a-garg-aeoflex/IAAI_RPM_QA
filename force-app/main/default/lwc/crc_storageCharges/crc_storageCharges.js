import { LightningElement, api, wire, track} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { validateFieldsAndGetData, showSuccessMessage, showErrorMessage, processActionCodes, salesforceAccountToRpmStorageLocation, reversePicklistValues } from 'c/crc_util';
import RESPONSIBLE_PARTY from '@salesforce/schema/Release_Charge__c.Responsible_Party__c'; 
import saveStorageCharges from '@salesforce/apex/CRC_CaseDetailController.saveStorageCharges';

export default class Crc_storageCharges extends LightningElement {
    @api storageCharges = [];
    @api caseInformation = {};
    @api actionsNeeded;
    @api rateTypeOptions;
    
    responsiblePartyOptions;
    feeamount;
    isLoading;
    readonly = true;
    variablefee;
    numberOfDays;
    actionCode = 'U';
    calculatedStorageAmount;
    intialCalclulatedStorageAmount;
    @track data = {};
    variableCharges = {};
    @track records = [];
    isIAAI_AuthorizedCB;
    isAuthorizedManually;
   
    get buttonLabel() {
        return (this.readonly) ? 'Edit' : 'Cancel';
    }

    get isVariableStorage() {
        return this.data.CRC_Rate_Type__c === 'VAR';
    }

    get showAddStorageLocationButton() {
        return this.isVariableStorage && !this.readonly;
    }

    get rateType() {
        return reversePicklistValues(this.rateTypeOptions)[this.caseInformation.CRC_Rate_Type__c];
    }

    get isIAAI_Authorized() {
        return (this.isAuthorizedManually) ? this.data.IAA_Requested_to_Pay_Advance_Charges__c : this.caseInformation.IAA_Requested_to_Pay_Advance_Charges__c;
    }

    toggleView() {
        this.readonly = !this.readonly;
    }

    get required() {
        return this.data.Rate_Type__c !== 'VAR';
    }

    responseParseHelper() {
        var tempData = JSON.parse(JSON.stringify(this.caseInformation));
        if(tempData.CRC_Start_Date__c && tempData.CRC_End_Date__c) {
            var _numberOfDays = parseInt((new Date(tempData.CRC_End_Date__c) - new Date(tempData.CRC_Start_Date__c))/ (1000*60*60*24)); 
            this.numberOfDays = (_numberOfDays === 0) ? 1 : _numberOfDays+1;
            tempData.Number_Of_Days__c = this.numberOfDays;
        }

        if(tempData.CRC_Rate_Type__c === 'OTH' && tempData.CRC_Storage_Rate__c) {
            this.calculatedStorageAmount = parseFloat(tempData.CRC_Storage_Rate__c);
            tempData.VR_CALCULATED_STORAGE_AMOUNT = this.calculatedStorageAmount;
        } else if(tempData.CRC_Rate_Type__c === 'DLY' && tempData.CRC_Storage_Rate__c && this.numberOfDays) {
            this.calculatedStorageAmount = parseFloat(parseFloat(tempData.CRC_Storage_Rate__c) * parseInt(this.numberOfDays));
            tempData.VR_CALCULATED_STORAGE_AMOUNT = this.calculatedStorageAmount;
        }

        this.caseInformation = tempData;
    }

    get updatedAdvancedChgMaxAuthorizedAmount() {
        return this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c;
    }

    connectedCallback() {
        console.log('caseInformation', JSON.parse(JSON.stringify(this.caseInformation)));
        console.log(this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c);
        this.responseParseHelper();
        var tempData = JSON.parse(JSON.stringify(this.caseInformation));
        
        for (const key in tempData) {
            this.handleInputChange({target:{name: key, value: tempData[key]}});
        }
        this.handleInputChange({target:{name: 'IAA_Requested_to_Pay_Advance_Charges__c', checked: tempData['IAA_Requested_to_Pay_Advance_Charges__c']}});
        
        if(this.storageCharges.length === 0) {
            
        } else {
            var _records = JSON.parse(JSON.stringify(this.storageCharges));
            var finalRecords = [];
            var finalAmount = 0;
            for (let index = 0; index < _records.length; index++) {
                const element = _records[index];
                const rowCalculation = this.findStartEndDateForVariableCharge(index, finalRecords[index-1]);
                element.readonly = true;
                element.sequenceNumber = index+1;
                element.responsiblePartyText = reversePicklistValues(this.responsiblePartyOptions)[element.Responsible_Party__c];
                element.From_Day__c = rowCalculation.From_Day__c;
                element.Through_Day__c = (_records.length === index+1) ? this.caseInformation.Number_Of_Days__c : rowCalculation.Through_Day__c;
                element.Variable_Days__c = (parseInt(element.Through_Day__c) - parseInt(element.From_Day__c))+1;
                element.variableDays = (parseInt(element.Through_Day__c) - parseInt(element.From_Day__c))+1;
                finalAmount += parseFloat(element.Fee_Amount__c);
                finalRecords.push(element);
            }
            this.calculatedStorageAmount = finalAmount;
            this.intialCalculatedStorageAmount = this.calculatedStorageAmount;
            this.records = finalRecords;
        }
    }

    handleInputChange(event) {
        if(event.target.name === 'CRC_Rate_Type__c') {
            this.calculatedStorageAmount  = 0;
            if(this.caseInformation.CRC_Rate_Type__c === 'VAR' && event.target.value !== 'VAR') {
                this.actionCode = 'D';
            } else if(this.caseInformation.CRC_Rate_Type__c !== 'VAR' && event.target.value === 'VAR') {
                this.actionCode = 'A'
            } else {
                this.actionCode = 'U';
            }
        }

        // console.log(event.target);
        // if(event.target.name === 'IAA_Requested_to_Pay_Advance_Charges__c' && !event.target.checked) {
        //     this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c = undefined;
        // }

        this.data[event.target.name] = (event.target.type === 'checkbox') ? event.target.checked : event.target.value;

        if(this.data.CRC_Start_Date__c && this.data.CRC_End_Date__c) {
            var _numberOfDays = parseInt((new Date(this.data.CRC_End_Date__c) - new Date(this.data.CRC_Start_Date__c))/ (1000*60*60*24));
            this.numberOfDays = (_numberOfDays === 0) ? 1 : _numberOfDays+1;
        }

        if(this.data.CRC_Rate_Type__c === 'OTH' && this.data.CRC_Storage_Rate__c) {
            this.calculatedStorageAmount = parseFloat(this.data.CRC_Storage_Rate__c);
        } else if(this.data.CRC_Rate_Type__c === 'DLY' && this.data.CRC_Storage_Rate__c && this.numberOfDays) {
            this.calculatedStorageAmount = parseFloat(parseFloat(this.data.CRC_Storage_Rate__c) * parseInt(this.numberOfDays));
        } else if(this.data.CRC_Rate_Type__c === 'VAR') {
            var finalObj = {};
            var tempStorageAmount = 0;
            var isValid = this.records !== undefined && this.records.length > 0;
            if(isValid) {
                var _records = JSON.parse(JSON.stringify(this.records));
                _records.forEach(element => {
                    let sequenceNumber = element.sequenceNumber;
                    element = this.variableCharges[element.sequenceNumber];
                    if(element.From_Day__c !== '' && element.Through_Day__c !== '') {
                        element.variableDays = (element.Through_Day__c - element.From_Day__c)+1;
                        element.Variable_Days__c = (element.Through_Day__c - element.From_Day__c)+1;
                    }
                    element.sequenceNumber = sequenceNumber;
                    tempStorageAmount += parseFloat(element.Fee_Amount__c);
                    finalObj[sequenceNumber] = element;
                });
                this.calculatedStorageAmount = tempStorageAmount;
                if(this.readonly) {
                    this.caseInformation.VR_CALCULATED_STORAGE_AMOUNT = this.calculatedStorageAmount;
                }
                this.records = JSON.parse(JSON.stringify(Object.values(finalObj)));
            }
        }
    }

    saveStorageCharges() {
        try {
            let result = validateFieldsAndGetData(this);
            console.log(result);
            if(result.isValid && this.calculatedStorageAmount >= 0 && this.calculatedStorageAmount != this.intialCalclulatedStorageAmount) {

                if( this.caseInformation.IAA_Requested_to_Pay_Advance_Charges__c && 
                    this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c && 
                    this.caseInformation.Provider_Defined_Max_Auth_Amount__c && 
                    this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c < this.caseInformation.Provider_Defined_Max_Auth_Amount__c
                ) {
                    showErrorMessage(this, 'Advanced charges should be greater than or equal to provider charges');
                    return;
                }

                if(this.caseInformation.CRC_Start_Date__c > this.caseInformation.CRC_End_Date__c) {
                    showErrorMessage(this, 'End Date should be greater than or equal to Start Date');
                    return;
                }

                var payload = {};
                var variableCharges = JSON.parse(JSON.stringify(this.records));
                if(variableCharges.length > 0) {
                    variableCharges[variableCharges.length-1].variableDays = -1;
                }
                this.data = result.data;
                this.data.Number_Of_Days__c = this.numberOfDays;

                var processedActionCodes = processActionCodes(JSON.parse(JSON.stringify(this.data)), JSON.parse(JSON.stringify(this.caseInformation)));
                payload = processedActionCodes;
                if(this.data.CRC_Rate_Type__c === 'VAR') {
                    payload.variableCharges = variableCharges;
                }

                payload.VR_CALCULATED_STORAGE_AMOUNT = this.calculatedStorageAmount; 
                payload.VR_STORAGE_RATE = this.data.CRC_Storage_Rate__c;
                payload.ACTION_CODE = this.actionCode;
                payload.VR_STORAGE_RATE_TYPE_CODE = this.data.CRC_Rate_Type__c;
                payload.CASE_ID = this.caseInformation.Id;
                payload.VR_NUMBER_OF_DAYS = this.numberOfDays;
                //payload.IAAI_STOCK_NUMBER = this.caseInformation.Stock__r.Stock__c;
                payload.IAAI_STOCK_NUMBER = this.caseInformation.CRC_Stock_Number__c;
                payload.SALVAGE_ID = this.caseInformation.CRC_Salvage_Id__c;
                payload.CHECKSUM = this.caseInformation.CRC_Checksum__c;
                payload.PROVIDER_NAME = this.caseInformation.Account.Name;
                payload.REQUESTED_TO_PAY_ADVANCE_CHARGES = payload.IAA_Requested_to_Pay_Advance_Charges__c;
                payload.VR_CHARGES_CLEARED = payload.CRC_Charges_Cleared__c;

                if(payload.VR_CALCULATED_STORAGE_AMOUNT !== this.calculatedStorageAmount) {

                }

                if(payload.REQUESTED_TO_PAY_ADVANCE_CHARGES && payload.REQUESTED_TO_PAY_ADVANCE_CHARGES.value === false && this.caseInformation.IAA_Requested_to_Pay_Advance_Charges__c) {
                    payload.REQUESTED_TO_PAY_ADVANCE_CHARGES = {ActionCode: 'U', value : false};
                    payload.Updated_Advance_Chg_Auth_By_Last_Name__c = {ActionCode: 'U', value : this.caseInformation.Updated_Advance_Chg_Auth_By_Last_Name__c};
                    payload.Updated_Advance_Chg_Auth_By_First_Name__c = {ActionCode: 'U', value : this.caseInformation.Updated_Advance_Chg_Auth_By_First_Name__c};
                    payload.Updated_Advance_Chg_Max_Authorized_Amt__c = {ActionCode: 'U', value : 0};
                }

                if( payload.Updated_Advance_Chg_Auth_By_Last_Name__c || 
                    payload.Updated_Advance_Chg_Auth_By_First_Name__c || 
                    payload.Updated_Advance_Chg_Max_Authorized_Amt__c) {
                    
                        if( (this.caseInformation.Updated_Advance_Chg_Auth_By_Last_Name__c === undefined && payload.Updated_Advance_Chg_Auth_By_Last_Name__c === undefined)  || 
                            (this.caseInformation.Updated_Advance_Chg_Auth_By_First_Name__c === undefined && payload.Updated_Advance_Chg_Auth_By_First_Name__c === undefined)  || 
                            (this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c === undefined && payload.Updated_Advance_Chg_Max_Authorized_Amt__c === undefined) ) {
                                showErrorMessage(this, 'Firstname, Lastname and Amount is required');
                                return;
                        }

                        if(payload.Updated_Advance_Chg_Auth_By_First_Name__c === undefined) {
                            payload.Updated_Advance_Chg_Auth_By_First_Name__c = {ActionCode: 'U', value: this.caseInformation.Updated_Advance_Chg_Auth_By_First_Name__c};
                        }

                        if(payload.Updated_Advance_Chg_Auth_By_Last_Name__c === undefined) {
                            payload.Updated_Advance_Chg_Auth_By_Last_Name__c = {ActionCode: 'U', value: this.caseInformation.Updated_Advance_Chg_Auth_By_Last_Name__c};
                        }

                        if(payload.Updated_Advance_Chg_Max_Authorized_Amt__c === undefined) {
                            payload.Updated_Advance_Chg_Max_Authorized_Amt__c = {ActionCode: 'U', value: this.caseInformation.Updated_Advance_Chg_Max_Authorized_Amt__c};
                        }
                }

                if(payload.VR_CALCULATED_STORAGE_AMOUNT === this.caseInformation.VR_CALCULATED_STORAGE_AMOUNT && 
                    payload.VR_STORAGE_RATE_TYPE_CODE && 
                    payload.VR_STORAGE_RATE_TYPE_CODE === this.caseInformation.CRC_Rate_Type__c) {
                    delete payload.VR_CALCULATED_STORAGE_AMOUNT;
                }

                console.log(payload.VR_STORAGE_RATE_TYPE_CODE, this.caseInformation.CRC_Rate_Type__c);
                console.log(payload.VR_CALCULATED_STORAGE_AMOUNT, this.caseInformation.VR_CALCULATED_STORAGE_AMOUNT);
                console.log('payload-->', payload);
                this.isLoading = true;
                // return;
                saveStorageCharges({request : payload})
                    .then(result => {
                        console.log(result);
                        var parser = new DOMParser();
                        var response = parser.parseFromString(result.response, 'text/xml');
                        var isRejected = response.querySelector('REJECT_REASON_DESCRIPTION');
                        if(isRejected) {
                            showErrorMessage(this, isRejected.textContent);
                        } else {
                            var tempData = JSON.parse(JSON.stringify(this.caseInformation));
                            tempData.CRC_Rate_Type__c = this.data.CRC_Rate_Type__c;
                            tempData.CRC_Start_Date__c = this.data.CRC_Start_Date__c;
                            tempData.CRC_End_Date__c = this.data.CRC_End_Date__c;
                            tempData.CRC_Maximum_Authorized_Amount__c = this.data.CRC_Maximum_Authorized_Amount__c;
                            tempData.CRC_Storage_Rate__c = this.data.CRC_Storage_Rate__c;
                            tempData.IAA_Requested_to_Pay_Advance_Charges__c = this.data.IAA_Requested_to_Pay_Advance_Charges__c;
                            this.caseInformation = tempData;
                            this.toggleView();
                            showSuccessMessage(this, 'Release Charges saved successfully');
                        }
                        this.isLoading = false;
                    })
                    .catch(error => {
                        showErrorMessage(this, error);
                        this.isLoading = false;
                    });
            } else {
                showErrorMessage(this, 'Please check required fields');
            }
        } catch (error) {
            showErrorMessage(this, error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: RESPONSIBLE_PARTY })
    getPickupTypeValues ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.responsiblePartyOptions = data.values;
        }
    }

    handleVariableRowChange(event) {
        try {
            console.log(event.target.dataset.id);
            var allInputs = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            allInputs.forEach(element => {
                if(element.dataset.hasOwnProperty('id')) {
                    if(!this.variableCharges.hasOwnProperty(element.dataset.id)) {
                        this.variableCharges[element.dataset.id] = {};
                    }
                    this.variableCharges[element.dataset.id][element.name] = element.value;
                }
            });

            var finalObj = {};
            var tempStorageAmount = 0;
            if(Object.keys(this.variableCharges).length > 0) {
                var _records = JSON.parse(JSON.stringify(this.records));
                _records.forEach(element => {
                    let sequenceNumber = element.sequenceNumber;
                    element = this.variableCharges[element.sequenceNumber];
                    if(element.From_Day__c !== '' && element.Through_Day__c !== '') {
                        element.variableDays = (element.Through_Day__c - element.From_Day__c)+1;
                        element.Variable_Days__c = (element.Through_Day__c - element.From_Day__c)+1;
                    }
                    element.sequenceNumber = sequenceNumber;
                    tempStorageAmount += parseFloat(element.Fee_Amount__c);
                    finalObj[sequenceNumber] = element;
                });
                this.calculatedStorageAmount = tempStorageAmount;
                this.records = JSON.parse(JSON.stringify(Object.values(finalObj)));
            }
        } catch (error) {
            showErrorMessage(this, error);
        }
    }

    addHandler() {
        var tempData = JSON.parse(JSON.stringify(this.records));
        this.records = undefined;
        tempData.push({sequenceNumber: tempData.length+1});
        this.records = tempData;
    }
    
    findStartEndDateForVariableCharge(index, previousIteration) {
        var finalData = {};
        var storageCharges = JSON.parse(JSON.stringify(this.storageCharges));
        var caseData = JSON.parse(JSON.stringify(this.caseInformation));
        if(index === 0) {
            finalData.From_Day__c = 1;
            finalData.Through_Day__c = storageCharges[index].Variable_Days__c;
        } else {
            finalData.From_Day__c = parseInt(previousIteration.Through_Day__c)+1;
            finalData.Through_Day__c = parseInt(previousIteration.Through_Day__c)+storageCharges[index].Variable_Days__c;
        }
        return finalData;
    }

    rowEditHandler(event) {
        var _records = JSON.parse(JSON.stringify(this.records));
        _records[parseInt(event.target.dataset.id)-1].readonly = false;
        this.records = _records;
    }

    rowDeleteHandler(event) {
        var _records = JSON.parse(JSON.stringify(this.records));
        var finalRecords = [];
        _records.forEach(element => {
            if(element.sequenceNumber !== parseInt(event.target.dataset.id)) {
                element.sequenceNumber = finalRecords.length+1;
                finalRecords.push(element);
            }
        });
        this.records = finalRecords;
    }

    handleInputChangeAdvancePay(event) {
        this.isAuthorizedManually = true;
        this.data[event.target.name] = event.target.checked;
    }
}