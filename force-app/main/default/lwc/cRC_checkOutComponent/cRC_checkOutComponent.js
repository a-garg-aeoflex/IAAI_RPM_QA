import {LightningElement, api} from 'lwc';
import checkInCheckOutMethod from '@salesforce/apex/CRC_ReleaseAssignmentController.checkInCheckOutMethod';
import { showSuccessMessage, showErrorMessage} from 'c/crc_util';
export default class CRC_checkInComponent extends LightningElement {
	@api recordId;
	@api isLoading = false;

	@api invoke() {
		checkInCheckOutMethod({recId: this.recordId, operation: 'checkOut'})
			.then((result) => {
					this.isLoading = !this.isLoading;
					showSuccessMessage(this, 'Check Out and Refresh Successful');
			})
			.catch((error) => {
				showErrorMessage(this, error);
				this.isLoading = !this.isLoading;
			});
	}
}