import { LightningElement, api } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class Crc_operationalHours extends LightningElement {
    @api storageInformation = {};
    @api isRPM;
    @api viewOnly;
    @api rpmData;

    hours;
    timeZone = TIME_ZONE;
    weekdayVsNumber = {'Sunday' : '1', 'Monday' : '2', 'Tuesday' : '3', 'Wednesday' : '4', 'Thursday' : '5', 'Friday' : '6', 'Saturday' : '7'};
    numberVsWeekday = {'1' : 'Sunday', '2' : 'Monday', '3' : 'Tuesday', '4' : 'Wednesday', '5' : 'Thursday', '6' : 'Friday', '7' : 'Saturday'};

    sundayValues = {};
    mondayValues = {};
    tuesdayValues = {};
    wednesdayValues = {};
    thursdayValues = {};
    fridayValues = {};
    saturdayValues = {};

    connectedCallback() {
        this.doInit();
    }

    doInit() {
        if(this.rpmData) {
            var data = JSON.parse(JSON.stringify(this.rpmData));
            data.forEach(element => {
                element.HOO_DAY_OF_WEEK_TEXT = this.numberVsWeekday[element.HOO_DAY_OF_WEEK];
                element.HOO_OPEN_FROM = (element.HOO_OPEN_FROM) ? new Date(element.HOO_OPEN_FROM).toString().split(' ')[4] : '';
                element.HOO_CLOSED_AT = (element.HOO_CLOSED_AT) ? new Date(element.HOO_CLOSED_AT).toString().split(' ')[4] : '';
                element.HOO_UNAVAILABLE_FROM = (element.HOO_UNAVAILABLE_FROM) ? new Date(element.HOO_UNAVAILABLE_FROM).toString().split(' ')[4] : '';
                element.HOO_UNAVAILABLE_TO = (element.HOO_UNAVAILABLE_TO) ? new Date(element.HOO_UNAVAILABLE_TO).toString().split(' ')[4] : '';
            });
            this.hours = data;
        }
    }

    handleChange(event) {
        let actionCode = '';
        if(event.target.value) {
            if(!event.target.dataset.value && event.target.value) {
                actionCode = 'A';
            } else if(event.target.dataset.value && event.target.value) {
                actionCode = 'U';
            } 
        } else {
            actionCode = 'D';
        }

        this.makeRelativeFieldsRequired(event.target.dataset.day);

        if(event.target.dataset.day === 'Sunday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }

            this.sundayValues['fieldName'] = event.target.name;
            this.sundayValues['value'] = event.target.value;
            this.sundayValues['actionCode'] = actionCode;
            this.sundayValues['dayText'] = event.target.dataset.day;
            this.sundayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Monday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.mondayValues['fieldName'] = event.target.name;
            this.mondayValues['value'] = event.target.value;
            this.mondayValues['actionCode'] = actionCode;
            this.mondayValues['dayText'] = event.target.dataset.day;
            this.mondayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Tuesday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.tuesdayValues['fieldName'] = event.target.name;
            this.tuesdayValues['value'] = event.target.value;
            this.tuesdayValues['actionCode'] = actionCode;
            this.tuesdayValues['dayText'] = event.target.dataset.day;
            this.tuesdayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Wednesday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.wednesdayValues['fieldName'] = event.target.name;
            this.wednesdayValues['value'] = event.target.value;
            this.wednesdayValues['actionCode'] = actionCode;
            this.wednesdayValues['dayText'] = event.target.dataset.day;
            this.wednesdayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Thursday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.thursdayValues['fieldName'] = event.target.name;
            this.thursdayValues['value'] = event.target.value;
            this.thursdayValues['actionCode'] = actionCode;
            this.thursdayValues['dayText'] = event.target.dataset.day;
            this.thursdayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Friday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.fridayValues['fieldName'] = event.target.name;
            this.fridayValues['value'] = event.target.value;
            this.fridayValues['actionCode'] = actionCode;
            this.fridayValues['dayText'] = event.target.dataset.day;
            this.fridayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        } else if(event.target.dataset.day === 'Saturday') {
            if(Object.keys(this.storageInformation).length > 0 && 
                (
                    this.storageInformation.Sunday_Open_From__c ||
                    this.storageInformation.Sunday_Closed_At__c || 
                    this.storageInformation.Sunday_Unavailable_From__c || 
                    this.storageInformation.Sunday_Unavailable_To__c
                )) {
                    actionCode = 'U';
            }
            this.saturdayValues['fieldName'] = event.target.name;
            this.saturdayValues['value'] = event.target.value;
            this.saturdayValues['actionCode'] = actionCode;
            this.saturdayValues['dayText'] = event.target.dataset.day;
            this.saturdayValues['dayNumber'] = this.weekdayVsNumber[event.target.dataset.day];
        }
    }

    @api
    getData() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                    let value = (inputCmp.value) ? '2001-01-01T'+inputCmp.value.replace('.000Z', '')+'Z' : '2001-01-01T00:00:00Z';
                    if(inputCmp.name.includes('Sunday')) {
                        this.sundayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Monday')) {
                        this.mondayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Tuesday')) {
                        this.tuesdayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Wednesday')) {
                        this.wednesdayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Thursday')) {
                        this.thursdayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Friday')) {
                        this.fridayValues[inputCmp.name] = value;
                    } else if(inputCmp.name.includes('Saturday')) {
                        this.saturdayValues[inputCmp.name] = value;
                    }
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

        if(allValid) {
            return [
                JSON.parse(JSON.stringify(this.sundayValues)),
                JSON.parse(JSON.stringify(this.mondayValues)),
                JSON.parse(JSON.stringify(this.tuesdayValues)),
                JSON.parse(JSON.stringify(this.wednesdayValues)),
                JSON.parse(JSON.stringify(this.thursdayValues)),
                JSON.parse(JSON.stringify(this.fridayValues)),
                JSON.parse(JSON.stringify(this.saturdayValues))
            ];
        } else {
            return allValid;
        }
    }

    makeRelativeFieldsRequired(dayName) {
        var allInputs = this.template.querySelectorAll('lightning-input[data-day="'+dayName+'"]');
        var isRequireNeeded;
        var data = {};
        if(allInputs) {
            allInputs.forEach(element => {
                data[element.name] = element.value;
                if(element.value) {
                    isRequireNeeded = true;
                }
            });

            if(isRequireNeeded) {
                allInputs.forEach(element => {
                    element.required = true;
                    console.log(element.name, element.value);
                    if(element.name === dayName+'_Open_From__c' && (element.value > data[dayName+'_Closed_At__c'] || element.value < data[dayName+'Unavailable_From__c'])) {
                        element.setCustomValidity('Should be less than the hours of opertation to & unavailable hours from');
                    } else if(element.name === dayName+'_Closed_At__c' && (element.value < data[dayName+'_Open_From__c'] || element.value < data[dayName+'Unavailable_From__c'])) {
                        element.setCustomValidity('Should be greater than hours of operation from & unavailable hours to');
                    } else if(element.name === dayName+'_Unavailable_From__c' && (element.value < data[dayName+'_Open_From__c'] || element.value > data[dayName+'_Closed_At__c'])) {
                        element.setCustomValidity('Should be between Hours of operation from and hours of operation to');
                    } else if(element.name === dayName+'_Unavailable_From__c' && element.value > data[dayName+'Unavailable_To__c']) {
                        element.setCustomValidity('Should be less than the unavailable hours to');
                    } else if(element.name === dayName+'_Unavailable_To__c' && (element.value < data[dayName+'_Open_From__c'] || element.value > data[dayName+'_Closed_At__c'])) {
                        element.setCustomValidity('Should be between Hours of operation from and hours of operation to');
                    } else if(element.name === dayName+'_Unavailable_To__c' && element.value < data[dayName+'Unavailable_From__c']) {
                        element.setCustomValidity('Should be greater than the Unavailable hours from');
                    } else {
                        element.setCustomValidity('');
                    }
                });
            }
        }
    }
}