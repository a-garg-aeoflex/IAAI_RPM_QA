import { LightningElement, wire , api} from 'lwc';
import fetchNotesCategories from '@salesforce/apex/CRC_RPM_RequestHelper.fetchNotesCategories';
import addNote from '@salesforce/apex/RPM_APIController.RPM_AddUserNotes';
import { showErrorMessage,showSuccessMessage,validateFieldsAndGetData } from 'c/crc_util';

export default class Crc_addNotes extends LightningElement {
    notesCategoryOptions;
    disabled = true;
    note = {};
    @api recordId;
    @api notes = {};

    @wire(fetchNotesCategories, {})
    fetchNotesCategories ({error, data}) {
        if (error) {
            showErrorMessage(this, error);
        } else if (data) {
            this.notesCategoryOptions = data;
        }
    }

    handleInputChange(event) {
        if(event.target.name === 'CRC_Note_Category__c') {
            this.note['notecategory'] = event.target.value;
        } else if(event.target.name === 'Description') {
            this.note['description'] = event.target.value;
        }

        if(!this.note['notecategory'] || !this.note['description']) {
            this.disabled = true;
        } else {
            this.disabled = undefined;
        }
    }

    handleSave(){
        let data = validateFieldsAndGetData(this);
        data.data.Id = this.recordId;
        console.log(data);
        if(data.isValid) {
            this.isLoading = true;
            addNote({inputData : data.data})
            .then(result => {
                showSuccessMessage(this, 'Note saved successfully');
                this.isLoading = false;
            })
            .catch(error => {
                showErrorMessage(this, error);
            });
        }
    }
      

}