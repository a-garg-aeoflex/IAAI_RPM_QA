import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class ChatButton extends  NavigationMixin(LightningElement) {
    @api buttonURLOne;
    @api buttonNameOne;
    @api buttonURLTwo;
    @api buttonNameTwo ='';
    @api incomingVar01;
    @api outgoingVar01;
    handleClick(event) {
        let queryString = '';
        try{
            if(this.incomingVar01){
                let parms =this.getURLParams([this.incomingVar01]);
                for (const property in parms) {
                    let keyStorage =localStorage.getItem(property);
                    if(keyStorage !== parms[property] && parms[property] !== ''){
                        localStorage.setItem(property,parms[property]);    
                    }
                    queryString = "?" + this.outgoingVar01 + "=" +localStorage.getItem(property);
                    
                }
            }
            if(event.target.dataset.id ==='buttonNameOne' || event.target.dataset.id === 'buttonNameOneOne'){
                let url = queryString === '' ?this.buttonURLOne : this.buttonURLOne + queryString;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url:  url
                    }
                    },
                    true
                );
            }
            if(event.target.dataset.id ==='buttonNameTwo'){
                let url = queryString === '' ?this.buttonURLTwo : this.buttonURLTwo + queryString;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: url
                    }
                    },
                    true
                );
            }
        }
        catch(err) {
            console.log(err.message);        
        }  
    }
    get isOneButton(){
        return this.buttonNameTwo.trim() === '';
    }
    getURLParams(params){
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
    }
   
}