import { LightningElement, wire } from 'lwc';
import decodeVIN from '@salesforce/apex/BoltOnController.decodeVIN';
import saveListing from '@salesforce/apex/BoltOnController.saveListing';
import getPredictedPrice from '@salesforce/apex/IAAI_PredictedPriceCalloutClass.getPPrice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPE_OF_TITLE_FIELD from '@salesforce/schema/VPE_Listings__c.Type_Of_Title__c';
import { NavigationMixin } from 'lightning/navigation';

export default class VinDecode extends NavigationMixin(LightningElement) {
    vehicleInfo;
    currentVin;
    vpeListingRecord = {};
    currentStep = "VIN";
    showSpinner;

    get hasKeysOptions() {
        return [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    }

    get showPreviousButton() {
        return this.currentStep !== 'VIN';
    }

    get options() {
        return [
            { label: '1', value: '1' },
            { label: '1.5', value: '1.5' },
            { label: '2', value: '2' },
            { label: '2.5', value: '2.5' },
            { label: '3', value: '3' },
            { label: '3.5', value: '3.5' },
            { label: '4', value: '4' },
            { label: '4.5', value: '4.5' },
            { label: '5', value: '5' }
        ];
    }

    get stateList() {
        return [
            { label: 'Alabama' , value: 'Alabama' },
            { label: 'Alaska' , value: 'Alaska' },
            { label: 'American Samoa' , value: 'American Samoa' },
            { label: 'Arizona' , value: 'Arizona' },
            { label: 'Arkansas' , value: 'Arkansas' },
            { label: 'California' , value: 'California' },
            { label: 'Colorado' , value: 'Colorado' },
            { label: 'Connecticut' , value: 'Connecticut' },
            { label: 'Delaware' , value: 'Delaware' },
            { label: 'District of Columbia' , value: 'District of Columbia' },
            { label: 'Florida' , value: 'Florida' },
            { label: 'Georgia' , value: 'Georgia' },
            { label: 'Guam' , value: 'Guam' },
            { label: 'Hawaii' , value: 'Hawaii' },
            { label: 'Idaho' , value: 'Idaho' },
            { label: 'Illinois' , value: 'Illinois' },
            { label: 'Indiana' , value: 'Indiana' },
            { label: 'Iowa' , value: 'Iowa' },
            { label: 'Kansas' , value: 'Kansas' },
            { label: 'Kentucky' , value: 'Kentucky' },
            { label: 'Louisiana' , value: 'Louisiana' },
            { label: 'Maine' , value: 'Maine' },
            { label: 'Maryland' , value: 'Maryland' },
            { label: 'Massachusetts' , value: 'Massachusetts' },
            { label: 'Michigan' , value: 'Michigan' },
            { label: 'Minnesota' , value: 'Minnesota' },
            { label: 'Minor Outlying Islands' , value: 'Minor Outlying Islands' },
            { label: 'Mississippi' , value: 'Mississippi' },
            { label: 'Missouri' , value: 'Missouri' },
            { label: 'Montana' , value: 'Montana' },
            { label: 'Nebraska' , value: 'Nebraska' },
            { label: 'Nevada' , value: 'Nevada' },
            { label: 'New Hampshire' , value: 'New Hampshire' },
            { label: 'New Jersey' , value: 'New Jersey' },
            { label: 'New Mexico' , value: 'New Mexico' },
            { label: 'New York' , value: 'New York' },
            { label: 'North Carolina' , value: 'North Carolina' },
            { label: 'North Dakota' , value: 'North Dakota' },
            { label: 'Northern Mariana Islands' , value: 'Northern Mariana Islands' },
            { label: 'Ohio' , value: 'Ohio' },
            { label: 'Oklahoma' , value: 'Oklahoma' },
            { label: 'Oregon' , value: 'Oregon' },
            { label: 'Pennsylvania' , value: 'Pennsylvania' },
            { label: 'Puerto Rico' , value: 'Puerto Rico' },
            { label: 'Rhode Island' , value: 'Rhode Island' },
            { label: 'South Carolina' , value: 'South Carolina' },
            { label: 'South Dakota' , value: 'South Dakota' },
            { label: 'Tennessee' , value: 'Tennessee' },
            { label: 'Texas' , value: 'Texas' },
            { label: 'U.S. Virgin Islands' , value: 'U.S. Virgin Islands' },
            { label: 'Utah' , value: 'Utah' },
            { label: 'Vermont' , value: 'Vermont' },
            { label: 'Virginia' , value: 'Virginia' },
            { label: 'Washington' , value: 'Washington' },
            { label: 'West Virginia' , value: 'West Virginia' },
            { label: 'Wisconsin' , value: 'Wisconsin' },
            { label: 'Wyoming' , value: 'Wyoming' }
        ];
    }

    get countryList() {
        return [
            { label: 'United States', value: 'United States' }
        ];
    }
    get showPredictedPrice() {
        return this.currentStep === "Vehicle Condition Grade";
    }

    get showVinDecode() {
        return this.currentStep === "VIN";
    }

    get showVehicleInfo() {
        return this.currentStep === "Vehicle Basic Information";
    }

    get showLocation() {
        return this.currentStep === "Location";
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TYPE_OF_TITLE_FIELD })
    typeOfTitleOptions;

    


    getPredictedPriceMethod() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                this.vpeListingRecord[inputCmp.name] = inputCmp.value;
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            console.log(this.vpeListingRecord);
            this.showSpinner = true;
            getPredictedPrice({ objVPE: this.vpeListingRecord })
                .then(result => {
                    const returnedCopy = Object.assign(result, this.vpeListingRecord);
                    this.vpeListingRecord = returnedCopy;
                    console.log(this.vpeListingRecord);
                    this.showSpinner = false;
                    this.currentStep = 'Location';
                })
                .catch(error => {
                    console.error(">>> valueListerror... " + error);
                });
        }
    }

    handleGo() {
        let vin = this.template.querySelector('lightning-input').value;
        this.currentVin = vin;
        this.vpeListingRecord.VIN__c = vin;
        if (vin) {
            this.showSpinner = true;
            decodeVIN({ vin: vin })
                .then(result => {
                    console.log(result);
                    if (!result.success) {
                        this.dispatchEvent(new ShowToastEvent({
                            message: 'Please enter a valid VIN',
                            variant: 'error'
                        }));
                    } else {
                        this.vehicleInfo = result.data;
                        this.currentStep = 'Vehicle Basic Information';
                        console.log(">>> valueListdata... " + result.data);
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error(">>> valueListerror... " + error);
                });
        } else {
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                message: 'Please Enter a VIN',
                variant: 'error'
            }));
        }
    }

    handleChange(event) {
        this.vpeListingRecord[event.target.name] = event.target.value;
    }

    handleClick() {
        if (this.currentStep === "VIN") {
            this.handleGo();
        } else if (this.currentStep === "Vehicle Basic Information") {
            this.currentStep = 'Vehicle Condition Grade';
        } else if (this.currentStep === "Vehicle Condition Grade") {
            this.currentStep = 'Location';
        } else if (this.currentStep === "Location") {
            alert('Finish');
        }
    }

    handlePrevious() {
        if (this.currentStep === "VIN") {
            showPrevious
        } else if (this.currentStep === "Vehicle Basic Information") {
            this.currentStep = 'VIN';
        } else if (this.currentStep === "Vehicle Condition Grade") {
            this.currentStep = 'Vehicle Basic Information';
        } else if (this.currentStep === "Location") {
            this.currentStep = 'Vehicle Condition Grade';
        }
    }

    saveListing() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                this.vpeListingRecord[inputCmp.name] = inputCmp.value;
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            this.showSpinner = true;
            saveListing({ listing: JSON.parse(JSON.stringify(this.vpeListingRecord)) })
                .then(result => {
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Listing Created Succesfully',
                        variant: 'success'
                    }));
                    this.dispatchEvent(new CustomEvent('listingcreated'));
                    this.showSpinner = false;
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Home'
                        }
                    });
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        message: error.body.message,
                        variant: 'error'
                    }));
                    this.showSpinner = false;
                });
        }
    }
}