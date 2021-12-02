import { LightningElement, api, wire } from 'lwc';
import updateAssignmentInRPM from '@salesforce/apex/CRC_CaseDetailController.updateAssignmentInRPM';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { validateFieldsAndGetData, showSuccessMessage, processActionCodes, showErrorMessage, rpmAssignmentToSalesforceCase, salesforceCaseToRpmAssignment } from 'c/crc_util';

export default class Crc_vehicleInformation extends LightningElement {
    @api vehicleInformation = {};
    @api assignmentTypeOptions;
    @api exteriorColorOptions;
    @api vehicleLocationOptions;
    @api actionsNeeded;
    @api keysOptions;
    @api primaryDamageOptions;
    @api titleIndicatorOptions;
    @api secondaryDamageOptions;
    @api driveOptions;
    @api fuelTypeOptions;
    @api lossTypeOptions;

    readonly = true;
    isLoading;
    timeZone = TIME_ZONE;

    get isResidential() {
        return this.vehicleInformation.CRC_Pickup_Location_Type__c === 'Residential';
    }

    get data() {
        let tempData = (this.vehicleInformation) ? JSON.parse(JSON.stringify(this.vehicleInformation)) : {};
        tempData.earliestAvailablePickupDateFormat = tempData.CRC_Earliest_Available_Pickup__c;
        // tempData.earliestAvailablePickupDateFormat = (tempData.CRC_Earliest_Available_Pickup__c) ?  Date.parse(tempData.CRC_Earliest_Available_Pickup__c) : '';
        return tempData;
    }

    get releaseName() {
        return (this.vehicleInformation.hasOwnProperty('CRC_Release_Person_First_Name__c') ? this.vehicleInformation.CRC_Release_Person_First_Name__c : '')+' '+(this.vehicleInformation.hasOwnProperty('CRC_Release_Person_Last_Name__c') ? this.vehicleInformation.CRC_Release_Person_Last_Name__c : '');
    }

    get buttonLabel() {
        return (this.readonly) ? 'Edit' : 'View';
    }

    get exteriorColorLabel() {
        if (this.vehicleInformation.CRC_Exterior_Color__c) {
            let findValue = this.exteriorColorOptions.find((single) => single.value === this.vehicleInformation.CRC_Exterior_Color__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get vehicleLocationLabel() {
        if (this.vehicleInformation.CRC_Vehicle_Location__c) {
            let findValue = this.vehicleLocationOptions.find((single) => single.value === this.vehicleInformation.CRC_Vehicle_Location__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get keyLabel() {
        if (this.vehicleInformation.CRC_Keys_with_Vehicle__c && this.keysOptions) {
            let findValue = this.keysOptions.find((single) => single.value === this.vehicleInformation.CRC_Keys_with_Vehicle__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get primaryDamageLabel() {
        if (this.vehicleInformation.CRC_Primary_Damage_Code__c && this.primaryDamageOptions) {
            let findValue = this.primaryDamageOptions.find((single) => single.value === this.vehicleInformation.CRC_Primary_Damage_Code__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }
    get primaryTitleIndicatorLabel() {
        if (this.vehicleInformation.Title_Indicator__c && this.titleIndicatorOptions) {
            let findValue = this.titleIndicatorOptions.find((single) => single.value === this.vehicleInformation.Title_Indicator__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get driveLabel() {
        if (this.vehicleInformation.CRC_Drive__c && this.driveOptions) {
            let findValue = this.driveOptions.find((single) => single.value === this.vehicleInformation.CRC_Drive__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get fuelTypeLabel() {
        if (this.vehicleInformation.CRC_Fuel_Type__c && this.fuelTypeOptions) {
            let findValue = this.fuelTypeOptions.find((single) => single.value === this.vehicleInformation.CRC_Fuel_Type__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get lossTypeLabel() {
        if (this.vehicleInformation.CRC_Loss_Type__c && this.lossTypeOptions) {
            let findValue = this.lossTypeOptions.find((single) => single.value === this.vehicleInformation.CRC_Loss_Type__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    get secondaryDamageLabel() {
        if (this.vehicleInformation.CRC_Secondary_Damage_Code__c && this.secondaryDamageOptions) {
            let findValue = this.secondaryDamageOptions.find((single) => single.value === this.vehicleInformation.CRC_Secondary_Damage_Code__c);
            return (findValue) ? findValue.label : '';
        } else {
            return '';
        }
        
    }

    toggleView() {
        if(this.readonly && !this.isResidential) {
            // if(!this.vehicleInformation.CRC_Start_Date__c || !this.vehicleInformation.CRC_End_Date__c) {
            //     showErrorMessage(this, 'Storage Start date or End date is not available');
            // } else {
            //     this.readonly = !this.readonly;    
            // }
        //} else {
            this.readonly = !this.readonly;
        }
    }

    saveVehicleInformation() {
        let data = validateFieldsAndGetData(this);
        if(data.isValid) {
            if( data.data.PRIMARY_DAMAGE_CODE === data.data.SECONDARY_DAMAGE_CODE) {
                showErrorMessage(this, 'Primary Damage should not be same as Secondary Damage code');
                return;
            }

            if(data.data.VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME && new Date(data.data.VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME) < new Date()) {
                showErrorMessage(this, 'Earliest Available Pickup Datetime should be a future datetime');
                return;
            }
            
            if(!data.data.VIN && (!data.data.MAKE || !data.data.MODEL || !data.data.YEAR)) {
                showErrorMessage(this, 'Make, Model and Year is required');
                return;
            }

            this.isLoading = true;
            data.data.Id = this.vehicleInformation.Id;
            //data.data.IAAI_STOCK_NUMBER = this.vehicleInformation.Stock__r.Stock__c;
            data.data.IAAI_STOCK_NUMBER = this.vehicleInformation.CRC_Stock_Number__c;
            data.data.SALVAGE_ID = this.vehicleInformation.CRC_Salvage_Id__c;
            data.data.CHECKSUM = this.vehicleInformation.CRC_Checksum__c;
            let finalData = processActionCodes(data.data, salesforceCaseToRpmAssignment(JSON.parse(JSON.stringify(this.vehicleInformation))));
            finalData.PROVIDER_NAME = this.vehicleInformation.Account.Name;
            updateAssignmentInRPM({inputData : finalData})
            .then(result => {
                console.log(result);
                var parser = new DOMParser();
                var data = parser.parseFromString(result.response, 'text/xml');
                var isRejected = data.querySelector('REJECT_REASON_DESCRIPTION');
                if(isRejected) {
                    showErrorMessage(this, isRejected.textContent);
                } else {
                    showSuccessMessage(this, 'Vehicle Information saved successfully');
                    // this.toggleView();
                    
                }
                
                this.toggleView();
                this.isLoading = false;
            })
            .then(dmlResponse => {
                console.log('dmlResponse', dmlResponse);
            })
            .catch(error => {
                this.isLoading = false;
                showErrorMessage(this, error);
            });
        }
    }
}