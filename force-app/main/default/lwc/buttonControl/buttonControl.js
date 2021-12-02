import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class ButtonControl extends NavigationMixin(LightningElement) {
    @api fieldName;
    @api url;
    @api rowid;
    renderedCallback() {
        
          const style = document.createElement('style');  
          style.innerText = `.slds-button {
            border-radius: 0 !important;
            }`;
        this.template.querySelector('lightning-button').appendChild(style);
        // this.template.querySelector('lightning-combobox').appendChild(style);
      }
      handleClick(){
        /*  console.log('click ' + this.fieldName);
        let paramlist = ['firstname','lastname','email'];
        let parms =this.getURLParams(paramlist);
      let queryString = '';
        for (const property in parms) {
            let keyStorage =localStorage.getItem(property);
            if(keyStorage !== parms[property] && parms[property] !== ''){
                localStorage.setItem(property,parms[property]);    
            }
            queryString = queryString + "&" + property + "=" +localStorage.getItem(property);
            
        }
        console.log('querystring ' + queryString);*/
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: this.url + this.rowid,
                replace: true
            }
        });
       
      }
     /* getURLParams(params){
        try{
            let retVal = {};
            for (const element of  params) {                
                retVal[element] = '';
            }
            let sPageURL = decodeURIComponent(window.location.search.substring(1));
            let sURLVariables = sPageURL.split('&'); 
            let sParameterName;
            for (let i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if(params.includes(sParameterName[0])){
                    let parm = sParameterName[1] === undefined ? true : sParameterName[1];
                    retVal[sParameterName[0]] = sParameterName[1];
                }
         
            }
            return retVal;
        }
        catch(err) {
           console.log(err.message);
          }
    }*/
}