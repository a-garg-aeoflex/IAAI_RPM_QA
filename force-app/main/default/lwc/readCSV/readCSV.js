import { LightningElement, track, api } from 'lwc';
import createListing from '@salesforce/apex/BoltOnController.createListing';
import createListingRecord from '@salesforce/apex/BoltOnController.createListingRecord';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import vehicleCondition from '@salesforce/label/c.Vehicle_Condition_Grade_PDF';

const columns = [
    { label: 'Provider First Name', fieldName: 'Provider_First_Name__c' },
    { label: 'Provider Last Name', fieldName: 'Provider_Last_Name__c' },
    { label: 'VIN', fieldName: 'VIN__c' },
    { label: 'Make', fieldName: 'Make__c' },
    { label: 'Model', fieldName: 'Model__c' },
    { label: 'Year', fieldName: 'Model_Year__c' }
];

export default class ReadCSV extends LightningElement {
    @api recordId;
    @track error;
    @track columns = columns;
    @track data = [];
    @track originalData = [];
    showCreateRecordModal;
    showSpinner;
    loggedInUser = userId;
    loggedInEmail;
    listingUploadModal = false;
    partnerId;
    label = {
        vehicleCondition
    };
    gradeOptions = [{ label: '1', value: '1' }, { label: '1.5', value: '1.5' }, { label: '2', value: '2' }, { label: '2.5', value: '2.5' }, { label: '3', value: '3' }, { label: '3.5', value: '3.5' }, { label: '4', value: '4' }, { label: '4.5', value: '4.5' }, { label: '5', value: '5' }];
    keysOptions = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    showSpinner = false;
    fields = ['Provider_First_Name__c', 'Provider_Last_Name__c', 'VIN__c', 'Vehicle_Condition_Grade__c', 'Make__c', 'Mileage__c', 'Model__c', 'Model_Year__c', 'Vehicle_Image__c', 'Hyperlink__c', 'Vehicle_Image__c', 'Provider_Address__c', 'Provider_City__c', 'Provider_Country__c', 'Provider_Zip__c', 'Pickup_Phone_Number__c', 'Provider_Street__c', 'Pickup_Street__c', 'Pickup_City__c', 'Pickup_Zip__c', 'Pickup_State__c', 'Has_Keys__c', 'Notes__c'];

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        let _this = this;
        this.readCSV(event.detail.files[0], function(value) {
            let data = value.split('\r\n');
            console.log('splitted Value', data);
            if (data[data.length - 1] == '') {
                data.pop();
            }
            let recordData = data;
            let makeData = [];
            for (let index = 1; index < recordData.length; index++) {
                let csvRowData = recordData[index].split(',', 16);
                let objAcc = {};
                objAcc.Provider_First_Name__c = csvRowData[0].trim();
                objAcc.Provider_Last_Name__c = csvRowData[1].trim();
                objAcc.VIN__c = csvRowData[2].trim();
                objAcc.Vehicle_Condition_Grade__c = csvRowData[3].trim();
                objAcc.Make__c = csvRowData[4].trim();
                objAcc.Model__c = csvRowData[5].trim();
                objAcc.Model_Year__c = csvRowData[6].trim();
                objAcc.Mileage__c = csvRowData[7].trim();
                objAcc.Vehicle_Image__c = csvRowData[8].trim();
                objAcc.Pickup_Phone_Number__c = csvRowData[9].trim();
                objAcc.Pickup_Street__c = csvRowData[10].trim();
                objAcc.Pickup_City__c = csvRowData[11].trim();
                objAcc.Pickup_State__c = csvRowData[12].trim();
                objAcc.Pickup_Zip__c = csvRowData[13].trim();
                objAcc.Has_Keys__c = csvRowData[14].trim();
                objAcc.Notes__c = csvRowData[15].trim();
                objAcc.Status_of_Listing__c = 'Upcoming';
                objAcc.Listing_Id__c = userId + csvRowData[2].trim();
                makeData.push(objAcc);
                objAcc = {};
            }
            if (makeData.length > 0) {
                console.log('makeData', makeData);
                createListing({ data: makeData })
                    .then(controllerResult => {
                        _this.showSpinner = false;
                        if (controllerResult.length === 0) {
                            _this.dispatchEvent(new ShowToastEvent({
                                title: 'File Uploaded Successfully',
                                message: 'Please wait while we process your request. We\'ll notify you via Email when it\'s Done',
                                variant: 'success'
                            }));
                        } else {
                            _this.dispatchEvent(new CustomEvent('listingcreated'));
                            _this.dispatchEvent(new ShowToastEvent({
                                title: 'File Uploaded Successfully',
                                message: 'Listings created successfully',
                                variant: 'success'
                            }));
                        }
                    })
                    .catch(error => {
                        _this.showSpinner = false;
                        _this.dispatchEvent(new ShowToastEvent({
                            message: error.body.message,
                            variant: 'error'
                        }));
                        // this.showToast('ERROR', error.body.message, 'error');
                    });
            }
        });
    }

    showToast(title, msg, type) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: type
        }));
    }

    readCSV(file, callback) {
        let reader = new FileReader();
        reader.onloadend = function(e) {
            callback(e.target.result);
        }
        reader.readAsText(file);
    }

    downloadCSVTemplate(event) {
        event.preventDefault();
        let csv = 'Provider First Name,Provider Last Name,VIN,Vehicle Condition Grade,Make,Model,Year,Mileage,Vehicle Image,Pickup Phone Number, Street,Pickup City,Pickup State,Pickup Zip Code,Has Keys?,Notes\n';
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'listing_template_' + Date.now() + '.csv';
        hiddenElement.click();
    }

    createRecordSuccessHandler(event) {
        this.showCreateRecordModal = false;
        this.listingUploadModal = 'Listing Record Created Successfully';
    }

    createRecordButtonHandler() {
        this.showCreateRecordModal = true;
    }

    hideRecordCreationModal() {
        this.showCreateRecordModal = false;
    }

    closeModal() {
        this.listingUploadModal = null;
    }

    checkValid() {
        let fields = {};
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                fields[inputCmp.name] = inputCmp.value;
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return { valid: allValid, listing: fields };
    }

    createRecordSubmitHandler() {
        if (this.checkValid().valid) {
            this.showSpinner = true;
            const fields = this.checkValid().listing;
            fields.VPE_Listing_Partner__c = this.partnerId; // modify a field
            fields.Contact__c = this.loggedInContactId;
            fields.Status_of_Listing__c = 'Upcoming';
            fields.Listing_Id__c = userId + fields.VIN__c;
            createListingRecord({ listing: fields })
                .then(result => {
                    console.log(result);
                    if (result.success) {
                        this.dispatchEvent(new CustomEvent('listingcreated'));
                        this.dispatchEvent(new ShowToastEvent({
                            message: 'Listing created successfully',
                            variant: 'success'
                        }));
                    }
                    this.hideRecordCreationModal();
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(error);
                    this.showSpinner = false;
                });
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: 'Please fill all required fields',
                variant: 'error'
            }));
            window.scrollTo(0);
            this.showSpinner = false;
        }
    }

    openPDF() {
        console.log('PDF');
        window.open(this.label.vehicleCondition);
    }

    listingCreationHandler() {
        this.showCreateRecordModal = false;
    }
}