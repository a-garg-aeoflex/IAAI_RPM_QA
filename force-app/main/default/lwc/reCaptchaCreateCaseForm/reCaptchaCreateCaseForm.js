import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_TYPE from '@salesforce/schema/Case.Case_Type__c';
import CASE_SUBTYPE from '@salesforce/schema/Case.Case_Subtype__c';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import CASE_PHONE from '@salesforce/schema/Case.ContactPhone';
import DESCRIPTION from '@salesforce/schema/Case.Description';
import EMAIL from '@salesforce/schema/Case.ContactEmail';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Submit from '@salesforce/label/c.Submit';
import Attachment from '@salesforce/label/c.Attachment';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import Back from '@salesforce/label/c.Back';

import AccountProspectFieldsSoql from '@salesforce/label/c.AccountProspectFieldsSoql';
import {
    NavigationMixin
} from 'lightning/navigation';
import getKnowledgeList from '@salesforce/apex/GoogleReCAPTCHAController.getKnowledgeArticleList';
import saveFile from '@salesforce/apex/GoogleReCAPTCHAController.saveFile';
import discriptionSearch from '@salesforce/apex/GoogleReCAPTCHAController.handleCheckBoxChange';
import createCommunityCase from '@salesforce/apex/GoogleReCAPTCHAController.createCommunityCase';
import uploadFiles from '@salesforce/apex/GoogleReCAPTCHAController.uploadFiles';
import IS_GUEST_USER from '@salesforce/user/isGuest';
import LANG from '@salesforce/i18n/lang';
import DIR from '@salesforce/i18n/dir';
import ContactMobile from '@salesforce/schema/Case.ContactMobile';

export default class reCaptchaCreateCaseForm extends NavigationMixin(LightningElement) {
    @track caseDescriptionValue = null;
    @track KnowledgeList;
    caseObject = CASE_OBJECT;
    lang = LANG;
    dir = DIR;
    isGuestUser = IS_GUEST_USER;
    uploadedFiles;
    @track myRecordId ='';
    @track CVObjId;
    @track filename ='upload file';
    label = {
        Submit,
        Attachment,SuccessMsg,Back
     };
     
    @track caseSuppliedName;
    @track caseSuppliedEmail;
    @track caseSuppliedPhone;
   @track caseDescription;
    @track CaseSubtype;
    @track CaseTypec;
    @track buyerId;

    isValidated1 = false;
    isValidated2 = false;
    isValidated3 = false;
    isValidated4 = false;
    isValidated5 = false;
    isValidated6 = false;
    isValidated7 = false;
    isGuestUser = IS_GUEST_USER;
    myFields = [CASE_OBJECT, CASE_TYPE, CASE_SUBTYPE, CASE_SUBJECT, CASE_PHONE, DESCRIPTION, EMAIL];

    @track _url = "";
    @track _height = "";
    @track data;
    @api areDetailsVisible = false;
    @track receivedMessage = '';
    @track caseRecordDet = {
        subject: CASE_SUBTYPE,
        phone: CASE_PHONE,
        Description: DESCRIPTION,
        Type: CASE_TYPE,
        caseSubtype: CASE_SUBTYPE
    };
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    selectedRecords;
    @track filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    
    @api
    get height() {
        return this._height;
    }
    set height(value) {
        this._height = value;
    }
    @api
    get urlareDetailsVisible() {
        return this.areDetailsVisible;
    }
    set urlareDetailsVisible(value) {
        this.areDetailsVisible = value;
    }
    @api
    getAddress() {
        return window.address;
    }

    @api
    getValue() {
        return window.data;
    }

    @wire(getKnowledgeList, {lang :'$lang'})
    wiredKnowledgeArtic({
        data,
        error
        }) {
        if (data) {
            this.KnowledgeList = data;
            this.error = undefined;
            console.log(this.KnowledgeList);
        } else if (error) {
            this.error = error;
            this.KnowledgeList = undefined;
        }
    }
    @wire(discriptionSearch, {
        caseDescription: '$caseDescriptionValue', language :'$lang'
    })
    wiredKnowledgeArticles({
        data,
        error
        }) {
        if (data) {
            console.log("i am good");
            this.KnowledgeList = data;
            this.error = undefined;
            console.log(data);
            console.log(this.caseDescriptionValue);
            console.log(' console.log(data) ' + this.KnowledgeList);
        } else if (error) {
            this.error = error;
            this.KnowledgeList = undefined;
        }
    }
    // @wire(discriptionSearch) KnowledgeList; 
    handleChange(event) {
        console.log("You selected an DEScription: " + event.target.value);
        //this.caseDescriptionValue = event.target.value;
       // console.log("You selected an : " + caseDescriptionValue);
        console.log("test");
        const Dvalue = event.target.value;
        this.caseDescription = event.target.value;
        event.target.value;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { Dvalue }
        });
        console.log('fire the event');
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }
    handleSuppliedNameChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.caseSuppliedName = event.detail.value;
        console.log("You selected an caseSuppliedName: " + caseSuppliedName);
    }
    handleSuppliedEmailChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.caseSuppliedEmail = event.detail.value;
        console.log("You selected an caseSuppliedEmail: " + caseSuppliedEmail);
    }
    handleSuppliedPhoneChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.caseSuppliedPhone = event.detail.value;
        console.log("You selected an caseSuppliedPhone: " + caseSuppliedPhone);
    }
    handlecaseTypeChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.CaseTypec = event.detail.value;
        console.log("You selected an CaseTypec: " + CaseTypec);
    }
    handlecaseSubTypeChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.CaseSubtype = event.detail.value;
        console.log("You selected an CaseSubtype: " + CaseSubtype);
    }  
    handlecaseBuyerIdChange(event){
        console.log("You selected an Name: " + event.detail.value);
        this.buyerId = event.detail.value;
        console.log("You selected an buyerId: " + buyerId);
    }  
    handleCheckboxChange1() {
        // Get the labels of selected checkboxes
        const filters = Array.from(
            this.template.querySelectorAll('lightning-input'),
        )
            .filter(element => element.checked)
            .map(element => element.label);
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: { filters },
        });
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }
    

    /*createRecord(event) {

        console.log('yahoo');
        let objCase = { 'sobjectType': 'Case' ,'SuppliedEmail': this.caseSuppliedEmail,
        'suppliedName':this.caseSuppliedName,
         'suppliedPhone':this.caseSuppliedPhone,
         'Case_Type__c':this.CaseTypec,
        'Case_Subtype__c':this.CaseSubtype,
        'Buyer_ID__c':this.buyerId,'Description':this.caseDescriptionValue};
        objCase.Subject = 'create in community';
        objCase.SuppliedEmail = this.caseSuppliedEmail;
        
        

        console.log(objCase.suppliedName);


    /*createContactRecord({newRecord: objCase})
        .then(result => {
            this.recordId = result;
            console.log(result);
        })
        .catch(error => {
            console.log(error);
            this.error = error.message;
        });
        handleFileUploaded
    }*/
    @api recordId;
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.csv', '.xlsx'];
    }
    @track uploadedFileNames;
    handleUploadFinished(event) {
        console.log('yesy')
        // Get the list of uploaded files
         uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        console.log('uploadedFileNames '+uploadedFileNames);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' +this.uploadedFileNames,
                variant: 'success',
            }),
        );
        console.log('out')
    }

    listenMessage(msg) {
        window.data = msg.data;
        this.data = msg.data;
        this.receivedMessage = msg.data;
        if (this.data !== 'Unlock') {
            window.address = msg.data
            console.log(window.address);
            this.areDetailsVisible = true;
            console.log('ua');
            if (this.receivedMessage === "Google reCAPTCHA expired.") {
                this.template.querySelector('[data-id="submitcase"]').className = 'hide';
            } else {
                this.template.querySelector('[data-id="submitcase"]').className = 'show';
            }
            console.log('ua1');
        }
        console.log('ua2');
        console.log('ua3');
        console.log('data', this.receivedMessage);
        console.log('----', this.areDetailsVisible);
    }
   /* validateFields() {
        console.log('element.reportValidity();');
        this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
            element.reportValidity();
            console.log('element.reportValidity(); ' + element.reportValidity());
        });
        this.template.querySelector('lightning-record-edit-form').submit();
    }*/
    onSubmitHandler(event) {

        console.log("isValidated" + this.isValidated1);
        console.log("test.succesfully");
        // validateFields()
        console.log("Lang "+this.lang);
        console.log("Lang "+this.dir);
        console.log("isValidated" + this.isValidated1);
        this.isValidated1 = this.template.querySelector('[data-id="SuppliedName"]').reportValidity();
        //this.caseSuppliedName = this.template.querySelector('[data-id="SuppliedName"]').value();
        this.isValidated2 = this.template.querySelector('[data-id="SuppliedEmail"]').reportValidity();
        //this.caseSuppliedEmail = this.template.querySelector('[data-id="SuppliedEmail"]').value();
        this.isValidated3 = this.template.querySelector('[data-id="SuppliedPhone"]').reportValidity();
       // this.caseSuppliedPhone = this.template.querySelector('[data-id="SuppliedPhone"]').value();
        
        
        this.isValidated5 = this.template.querySelector('[data-id="Description"]').reportValidity();
       // this.caseDescription = this.template.querySelector('[data-id="Description"]').value();
        
        this.isValidated6 = this.template.querySelector('[data-id="CaseTypec"]').reportValidity();
        //this.CaseTypec = this.template.querySelector('[data-id="CaseTypec"]').value();
        
        this.isValidated7 = this.template.querySelector('[data-id="CaseSubtypec"]').reportValidity();
        //this.CaseSubtype = this.template.querySelector('[data-id="CaseSubtypec"]').value();
        //this.buyerId =  this.template.querySelector('[data-id="buyerId"]').value();
        console.log('caseSuppliedName ');
        console.log('caseSuppliedName '+this.caseSuppliedEmail);
        console.log('caseSuppliedEmail '+this.caseSuppliedName);
        console.log('caseSuppliedPhone '+this.caseSuppliedPhone);
        console.log('caseDescription '+this.caseDescriptionValue);
        console.log('CaseTypec '+this.CaseTypec);
        console.log('buyerId '+this.buyerId);
        console.log('CaseTypec '+this.CaseTypec);
        

        
        console.log('isValidated' + this.isValidated1);
        if (this.isValidated1 && this.isValidated2 && 
            this.isValidated3 &&  
            this.isValidated5 && this.isValidated6 && this.isValidated7) {
            this.template.querySelector('[data-id="createcase"]').className = 'hide';
            this.template.querySelector('[data-id="back"]').className = 'show';
            /*let objCase = { 'sobjectType': 'Case' ,
                            'SuppliedEmail':''+ this.caseSuppliedEmail+'',
                            'suppliedName':''+ this.caseSuppliedName+'',
                            'suppliedPhone': ''+this.caseSuppliedPhone+'',
                            'Case_Type__c': ''+this.CaseTypec+'',
                            'Case_Subtype__c':''+ this.CaseSubtype+'',
                            'Buyer_ID__c': ''+this.buyerId+'',
                            'Description': ''+this.caseDescriptionValue+''};
                console.log('objCase '+objCase);*/
                console.log('in add');
                createCommunityCase({'strSuppliedName': this.caseSuppliedName,
                'strSuppliedEmail' : this.caseSuppliedEmail,
                'strSuppliedPhone':this.caseSuppliedPhone,
                'strCaseType': this.CaseTypec,
                'strCaseSubType' : this.CaseSubtype,
                'BuyerId':this.buyerId,
                'isGuestUser' : this.isGuestUser,
                'strDescription':this.caseDescription,
                'files' :this.filesUploaded

                
            })
                .then(result => {
                    this.recordId = result;
                    console.log('0000000000 '+result);
                    })
                    .catch(error => {
                        
                        this.error = error;
                        console.log('errorerrorerrorerror '+error);
                    });
           // this.template.querySelector('lightning-record-edit-form').submit();
        }
        // this.template.querySelector('[data-id="back"]').className='show';
        // this.template.querySelector('lightning-record-edit-form').submit();


    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id)
        this.template.querySelector('[data-id="createcase"]').className = 'hide';
        this.template.querySelector('[data-id="back"]').className = 'show';
    }
    navigateToWebPage(event) {
        console.log('enter')
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/s/get-help'
            }
        });
        console.log('exit')
    }
    connectedCallback() {
        console.log(" start connectedCallback");
        if (window.addEventListener) {
            window.addEventListener("message", this.listenMessage.bind(this));
            console.log('---')
        } else {
            window.attachEvent("onmessage", this.listenMessage);

        }
        getKnowledgeList();
        console.log(" end connectedCallback");
    }















    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.file = event.target.files
            this.fileName = event.target.files.name;
            console.log('fileName '+fileName);
        }
    }

    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded;
       if (this.file.size > this.MAX_FILE_SIZE) {
            console.log('File Size is to long');
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            // call the uploadProcess method 
            this.saveToFile();
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile() {
        saveFile({ idParent: this.recordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
        .then(result => {
            window.console.log('result ====> ' +result.Id);
            // refreshing the datatable
            this.CVObjId = result.Id;
           

            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.UploadFile = 'File Uploaded Successfully';
            this.isTrue = true;
            this.showLoadingSpinner = false;

            // Showing Success message after file insert
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' - Uploaded Successfully!!!',
                    variant: 'success',
                }),
            );

        })
        .catch(error => {
            // Showing errors if any while inserting the files
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
    
    // Getting releated files of the current record
    getRelatedFiles() {
        releatedFiles({idParent: this.recordId})
        .then(data => {
            this.data = data;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    // Getting selected rows to perform any action
    getSelectedRecords(event) {
        let conDocIds;
        const selectedRows = event.detail.selectedRows;
        conDocIds = new Set();
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            conDocIds.add(selectedRows[i].ContentDocumentId);
        }

        this.selectedRecords = Array.from(conDocIds).join(',');

        window.console.log('selectedRecords =====> '+this.selectedRecords);
    }

    

    handleFileUploaded(event) {
        console.log('handleFileUploaded ');
        if (event.target.files.length > 0) {
            let files = [];
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
        console.log('handleFileUploaded out');
    }

    attachFiles(event){
       
        uploadFiles({files: this.filesUploaded})
            .then(result => {
                console.log('attachFiles')
                result.forEach(function(Item) {
                    console.log(Item.Title );
                    myRecordId += Item.Title ;
                });
                    this.showToastMessage('Success',this.myRecordId+'Files uploaded', 'success');
                              
               
            })
            .catch(error => {
                this.showToastMessage('Error','Error uploading files', 'error');
            });
            console.log('attachFiles out');
    }
    
    
    
    
    showToastMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

}