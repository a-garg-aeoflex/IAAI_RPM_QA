import { LightningElement, api, wire } from 'lwc';
import fetchRecords from '@salesforce/apex/RelatedListController.fetchRecords'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

export default class ParentToChildRelatedList extends LightningElement { 

    @api recordId;
		@api fieldsList;
		
    showSpinner;
    columns;
    data;
    partnerContactsCount = 0;
		lastRecordId = '';
		loadMoreStatus;
		needMoreRecords;
		
		@wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            if(this.fieldsList) {
								let tempFields = [];
								tempFields = this.fieldsList.split(',');
								let invalidFields = [];
								let tempColumns = [];
								tempFields.forEach(field => {
										if(!data.fields.hasOwnProperty(field.trim())) {
												invalidFields.push(field);
										}	else {
												tempColumns.push({label : data.fields[field].label, fieldName : data.fields[field].apiName, hideDefaultActions: true});
										}
								});

								if(invalidFields.length > 0) {
										this.dispatchEvent(new ShowToastEvent({
												message: 'Following fields seems invalid on Parent Contact Related list, please check - '+invalidFields.join(', '),
												variant: 'error'
										}));
								} else {
										this.columns = tempColumns;
										this.doInit();
								}
						}
        } else if (error) {
						this.dispatchEvent(new ShowToastEvent({
								message: error.body.message,
								variant: 'error'
						}));
        }
    }

    doInit() {
				this.showSpinner = true;
				fetchRecords({partnerId : this.recordId, fields : this.fieldsList, lastRecordId : this.lastRecordId})
				.then(result => {
						if(result) {
								this.data = result;
								this.partnerContactsCount = result.length;
								if(result.length === 20) {
										this.needMoreRecords = true;
								} else {
										this.needMoreRecords = false;
								}
								this.lastRecordId = result[0].Id;
						}
						this.showSpinner = false;
				})
				.catch(error => {
						this.dispatchEvent(new ShowToastEvent({
								message: error.body.message,
								variant: 'error'
						}));
						this.showSpinner = false;
				});
    }
		
		loadMoreData(event) {
				if(this.needMoreRecords) {
						//Display a spinner to signal that data is being loaded
						event.target.isLoading = true;
						//Display "Loading" when more data is being loaded
						this.loadMoreStatus = 'Loading';
						fetchRecords({partnerId : this.recordId, fields : this.fieldsList, lastRecordId : this.lastRecordId})
						.then(result => {
								if(result) {
										let newData = this.data;
										let updatedData = newData.concat(result);
										this.data = updatedData;
										this.partnerContactsCount = result.length;
										if(result.length === 20) {
												this.needMoreRecords = true;
										} else {
												this.needMoreRecords = false;
										}
										this.lastRecordId = result[0];
										this.loadMoreStatus = '';
										event.target.isLoading = false;
								} else {
										event.target.isLoading = false;
										event.target.enableInfiniteLoading = false;
										this.loadMoreStatus = 'No more data to load';
								}
								this.showSpinner = false;
						})
						.catch(error => {
								this.loadMoreStatus = '';
								event.target.enableInfiniteLoading = false;
								this.showSpinner = false;
								this.dispatchEvent(new ShowToastEvent({
										message: error.body.message,
										variant: 'error'
								}));
						});
				}
		}
}