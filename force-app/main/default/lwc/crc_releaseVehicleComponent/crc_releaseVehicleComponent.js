import { LightningElement,api,wire } from 'lwc';
import releaseVehicleMethod from '@salesforce/apex/CRC_ReleaseAssignmentController.releaseVehicleCheck';
import releaseVehicle from '@salesforce/apex/CRC_ReleaseAssignmentController.releaseVehicle';
import ANTICIPATED_RELEASE_DATETIME from '@salesforce/schema/Case.CRC_Anticipated_Release_Date_Time__c';
import EARLIEST_AVAILALBE_DATETIME from '@salesforce/schema/Case.CRC_Earliest_Available_Pickup__c';
import CHARGES_CLEARED from '@salesforce/schema/Case.CRC_Charges_Cleared__c';
import PICKUP_LOCATION_TYPE from '@salesforce/schema/Case.CRC_Pickup_Location_Type__c';
import { showErrorMessage,showSuccessMessage,validateFieldsAndGetData } from 'c/crc_util';
import { getRecord } from 'lightning/uiRecordApi';
export default class Crc_releaseVehicleComponent extends LightningElement {
    @api recordId;
	isLoading = false;
    visibleModal = false;
    releaseVehicleObject = {};               
    Anticipated_Release_Date_Time;          
    Earliest_Available_Pickup;     
    Charges_Cleared;    
    Pickup_Location_Type;
    @api invoke() {
			this.init();
	}

    init() {
        releaseVehicleMethod({recId: this.recordId})
			.then(result => {
				if (result) {
					if(this.Earliest_Available_Pickup == null){
						showErrorMessage(this,'Please populate Earliest Available Pickup datetime.');    
					}else if(this.Charges_Cleared != true && this.Pickup_Location_Type != 'Residential'){
						showErrorMessage(this,'Charges not Cleared.');  
					}else{
						this.visibleModal = true;
					}
				
				}
			})
			.catch(error => {
				showErrorMessage(this,error);               
			});
    }
     onCancel(params) {
        this.visibleModal = false;
    }


    onSave(params) {
       let response = validateFieldsAndGetData(this);
	   if(response.isValid) {
	
        releaseVehicle({recId: this.recordId, request : response.data})
			.then(result => {
				if (result.STATUS_CODE == 'REJECT') {
					this.visibleModal = false;
					showErrorMessage(this,result.REJECT_REASON_DESCRIPTION);
				}

				if(result.STATUS_CODE == 'ACCEPT'){
					showSuccessMessage(this,'Record Saved Successfully');
					this.visibleModal = false;
				}
			})
			.catch(error => {
				showErrorMessage(this,error);
			});
    }
  }


  @wire(getRecord, { recordId: '$recordId', fields: [ANTICIPATED_RELEASE_DATETIME,EARLIEST_AVAILALBE_DATETIME,CHARGES_CLEARED,PICKUP_LOCATION_TYPE]})
    getRecord ({error, data}) {
        if (error) {
        } else if (data) {
			this.caseRecord = data;
			this.Anticipated_Release_Date_Time = data.fields.CRC_Anticipated_Release_Date_Time__c.value;
			this.Earliest_Available_Pickup =  data.fields.CRC_Earliest_Available_Pickup__c.value;
			this.Charges_Cleared = data.fields.CRC_Charges_Cleared__c.value;
			this.Pickup_Location_Type = data.fields.CRC_Pickup_Location_Type__c.value;
        }
    }

}