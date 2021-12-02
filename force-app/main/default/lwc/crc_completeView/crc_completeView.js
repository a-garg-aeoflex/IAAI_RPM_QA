import { LightningElement, api, wire } from 'lwc';
import getCaseDetail from '@salesforce/apex/CRC_CaseDetailController.getCaseDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CRC_STREET_ADDRESS_SEPARATOR from '@salesforce/label/c.CRC_Street_Address_Separator';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { showErrorMessage } from 'c/crc_util';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } 
    from 'lightning/empApi';

export default class Crc_completeView extends LightningElement {
    subscription = {};//Added by Anuj on 25th Nov, 21 as part of testing
    @api channelName = '/event/Console_Tab__e';//Added by Anuj on 25th Nov, 21 as part of testing

    @api recordId;

    caseData = {};
    storageInformation = {};
    releaseProblems;
    storageCharges = [];
    releaseCharges = {};
    storageLocationContact = {};
    storageLocationMailingContact = {};
    
    isLoading = true;
    actionsNeeded;
    
    assignmentTypeOptions;
    rateTypeOptions;
    exteriorColorOptions;
    primaryDamageOptions;
    secondaryDamageOptions;
    titleIndicatorOptions;
    keysOptions;
    driveOptions;
    fuelTypeOptions;
    lossTypeOptions;
    vehicleLocationOptions;

    recordTypeId;

    get isResidentialStorage() {
        return this.storageInformation.CRC_Pickup_Location_Type__c === 'Residential';
    }

    get storageInformationLabel() {
        return (this.isResidentialStorage) ? 'Residential Information' : 'Storage Information';
    }

    @wire(getObjectInfo, {objectApiName : CASE_OBJECT})
    getObjectInfo ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            for (const key in data.recordTypeInfos) {
                if(data.recordTypeInfos[key].name === 'CRC Storage Location') {
                    this.recordTypeId = data.recordTypeInfos[key].recordTypeId;
                }
            }
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$recordTypeId' })
    getPicklistValuesByRecordType ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.assignmentTypeOptions = data.picklistFieldValues.CRC_Assignment_Type__c.values;
            this.exteriorColorOptions = data.picklistFieldValues.CRC_Exterior_Color__c.values;
            this.rateTypeOptions = data.picklistFieldValues.CRC_Rate_Type__c.values;
            this.primaryDamageOptions = data.picklistFieldValues.CRC_Primary_Damage_Code__c.values;
            this.titleIndicatorOptions = data.picklistFieldValues.Title_Indicator__c.values;
            this.secondaryDamageOptions = data.picklistFieldValues.CRC_Secondary_Damage_Code__c.values;
            this.driveOptions = data.picklistFieldValues.CRC_Drive__c.values;
            this.fuelTypeOptions = data.picklistFieldValues.CRC_Fuel_Type__c.values;
            this.lossTypeOptions = data.picklistFieldValues.CRC_Loss_Type__c.values;
            this.vehicleLocationOptions = data.picklistFieldValues.CRC_Vehicle_Location__c.values;
            this.keysOptions = data.picklistFieldValues.CRC_Keys_with_Vehicle__c.values;
            this.isLoading = false;
        }
    }

    connectedCallback() {
        this.doInit();
        this.handleSubscribe();//Added by Anuj on 25th Nov, 21 as part of testing
    }

    //Added by Anuj on 25th Nov, 21 as part of testing
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            thisReference.doInit();
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }    

    doInit() {
        getCaseDetail({caseId : this.recordId})
            .then(result => {
                console.log('result', result);
                this.caseData = result.case;
                let tempStorageInformation = {};
                if(result.case.CRC_Pickup_Location_Type__c === 'Residential') {
                    tempStorageInformation.caseId = result.case.Id;
                    tempStorageInformation.CRC_Pickup_Location_Type__c = result.case.CRC_Pickup_Location_Type__c;

                    tempStorageInformation.BillingStreet = result.case.CRC_VO_Address_Line_1__c;
                    tempStorageInformation.BillingStreet2 = result.case.CRC_VO_Address_Line_2__c;
                    tempStorageInformation.BillingCity = result.case.CRC_VO_City__c;
                    tempStorageInformation.BillingCountry = result.case.CRC_VO_Country__c;
                    tempStorageInformation.Name = result.case.CRC_Company_Name__c;
                    tempStorageInformation.BillingState = result.case.CRC_VO_StatePicklist__c;
                    tempStorageInformation.BillingPostalCode = result.case.CRC_VO_Zip__c;
                    tempStorageInformation.Validated__c = result.case.VO_Validated__c;
                    tempStorageInformation.Storage_Location_Status__c = (result.case.VO_Status__c === 'ACT') ? 'Active' : (result.case.VO_Status__c === 'CAN') ? 'Canceled' : '';

                    let tempStorageLocationContact = {};
                    tempStorageLocationContact.Email = result.case.CRC_VO_Email__c;
                    tempStorageLocationContact.Fax = result.case.CRC_VO_Fax__c;
                    tempStorageLocationContact.Phone = result.case.CRC_VO_Primary_Phone_Number__c;
                    this.storageLocationContact = tempStorageLocationContact;
                } else {
                    tempStorageInformation = (result.storage) ? result.storage : {};
                    if(tempStorageInformation.BillingStreet) {
                        let billingStreetArray = tempStorageInformation.BillingStreet.split(CRC_STREET_ADDRESS_SEPARATOR);
                        tempStorageInformation.BillingStreetComplete = billingStreetArray.join(', ');
                        tempStorageInformation.BillingStreet = billingStreetArray[0];
                        tempStorageInformation.BillingStreet2 = billingStreetArray[1];
                    }

                    if(tempStorageInformation.ShippingStreet) {
                        let shippingStreetArray = tempStorageInformation.ShippingStreet.split(CRC_STREET_ADDRESS_SEPARATOR);
                        tempStorageInformation.ShippingStreetComplete = shippingStreetArray.join(', ');
                        tempStorageInformation.ShippingStreet = shippingStreetArray[0];
                        tempStorageInformation.ShippingStreet2 = shippingStreetArray[1];
                    }
                    
                    tempStorageInformation.caseId = result.case.Id;
                    tempStorageInformation.CRC_Pickup_Location_Type__c = result.case.CRC_Pickup_Location_Type__c;
    
                    for (const key in tempStorageInformation) {
                        if (key.includes('Unavailable_From__c') || key.includes('Unavailable_To__c') || key.includes('Open_From__c') || key.includes('Closed_At__c')) {
                            tempStorageInformation[key] = new Date(tempStorageInformation[key]).toGMTString().split(" ")[4];
                        }
                    }

                    if(result.storageLocationContacts.length > 0) {
                        result.storageLocationContacts.forEach(element => {
                            if(element.Type__c === 'Storage Location') {
                                this.storageLocationContact = element;
                            } else if(element.Type__c === 'Storage Location') {
                                this.storageLocationMailingContact = element;
                            }
                        });
                    }
                }

                this.storageCharges = (result.case.Variable_Storage_Charges__r) ? result.case.Variable_Storage_Charges__r : [];
                this.storageInformation = tempStorageInformation;
                this.storageInformation.caseId = result.case.Id;
                this.releaseProblems = result.releaseProblems;
                this.releaseCharges = result.releaseCharges;
                this.actionsNeeded = result.actionsNeeded;
                

                this.isLoading = false;
                
                //calling releaseproblem method -- ANuj
                setTimeout(() => {
                    if(this.template.querySelector('c-crc_release-problems')){
                        this.template.querySelector('c-crc_release-problems').handleValueChange();
                    }
                },0);
                
            })
                
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }
}