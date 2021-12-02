import { LightningElement,api } from 'lwc';
import { showSuccessMessage, showErrorMessage} from 'c/crc_util';
import refreshFromRPM from '@salesforce/apex/RPM_APIController.refreshFromRPM';
    
export default class CRC_refreshFromRPM extends LightningElement {
   
        @api recordId;
        @api showSpinner = false;

         @api invoke() {
          this.showSpinner = false;
            refreshFromRPM({raId : this.recordId})
          .then(result => {
                this.showSpinner = !this.showSpinner;
                showSuccessMessage(this, 'Refresh Complete!');
           })
          .catch(error => {
              console.error(error);
              showErrorMessage(this);
              this.showSpinner = !this.showSpinner;
          })
      }
      
    
    }