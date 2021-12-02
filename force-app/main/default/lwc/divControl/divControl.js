import { LightningElement,api } from 'lwc';

export default class ButtonControl extends LightningElement {
   @api value;
   handleClick(event){
       //console.log('click3');
       try{
       event.target.classList.toggle('line-clamp');
       //event.target.classList.toggle('divHeigth');
       }
       catch(e){
           console.log('err: ' + e.message);
       }
       /*if(event.target.hasClass("slds-truncate")){
            event.target.classList.remove("slds-truncate")
            event.target.classList.remove("divHeigth");
       }else{
            event.target.classList.add("slds-truncate")
            event.target.classList.add("divHeigth");
       }*/
   }
}