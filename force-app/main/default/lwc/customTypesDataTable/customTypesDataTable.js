import LightningDatatable from 'lightning/datatable';
import imageTableControl from './imageTableControl.html';
import buttonTableControl from './buttonTableControl.html';
import divTableControl from './divTableControl';
export default class SalesforceCodexDataTable extends LightningDatatable  {
    static customTypes = {
        image: {
            template: imageTableControl
        },
        custombutton: {
            template: buttonTableControl,
            typeAttributes: ['name','rowid','url'],
        },
        customdiv: {
            template: divTableControl
        },

    };   
   
   
}