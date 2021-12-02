import { LightningElement,track,api } from 'lwc';
const columns = [  {label: 'Action', type: 'custombutton',  typeAttributes:
{ label: { fieldName: 'actionLabel'}, title: 'Click to Edit', name: 'edit_status', iconName: 'utility:edit', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}},];


export default class FlowDataTable extends LightningElement {

    @track data = [];
    @track datacopy = [];
    @track columns = columns;
    @track tableLoadingState = true;
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track hideCheckboxColumn = true;
    @api inputAccounts;
    @api outputAccountId;
    @track hideDefaultActions = true;
    
    @api column01_icon
    @api column01_label;
    @api column01_fieldName;
    @api column01_type;
    @api column01_width;
    @api column01_align;

    @api column02_icon
    @api column02_label;
    @api column02_fieldName;
    @api column02_type;
    @api column02_width;
    @api column02_align;

    @api column03_icon;
    @api column03_label;
    @api column03_fieldName;
    @api column03_type;
    @api column03_width;
    @api column03_align;

    @api column04_icon;
    @api column04_label;
    @api column04_fieldName;
    @api column04_type;
    @api column04_width;
    @api column04_align;

    @api column05_icon;
    @api column05_label;
    @api column05_fieldName;
    @api column05_type;
    @api column05_width;
    @api column05_align;

    @api column06_icon;
    @api column06_label;
    @api column06_fieldName;
    @api column06_type;
    @api column06_width;
    @api column06_align;

    @api column07_icon;
    @api column07_label;
    @api column07_fieldName;
    @api column07_type;
    @api column07_width;
    @api column07_align;

    @api column08_icon;
    @api column08_label;
    @api column08_fieldName;
    @api column08_type;
    @api column08_width;
    @api column08_align;

    @api column09_icon;
    @api column09_label;
    @api column09_fieldName;
    @api column09_type;
    @api column09_width;
    @api column09_align;

    @api column10_icon;
    @api column10_label;
    @api column10_fieldName;
    @api column10_type;
    @api column10_width;
    @api column10_align;

    @api hideShow;
    @api singleSelection;
        
    @api keyField;
    @api showButtons;
    @track imageColumns = [];
    async connectedCallback() {
        this.init();
        //parse ththe Rich text area and only get the src of the image
       /* let accts =JSON.parse(JSON.stringify( this.inputAccounts));
        for (const index in accts) {
            let row = accts[index];
            //console.log(JSON.stringify(row));
            if ("Logo__c" in row) {
                let logo =row["Logo__c"];

                if(logo){
                    try{
                        console.log('logo: ' + JSON.stringify(logo));
                        logo = logo.replace(/amp;/g, "");
                        let match = logo.match(/<?src="(.*?)"/gi);
                        if(match){
                            const matches = match.map(element => element.replace('src="','').replace('"','')).join(';');
                            row["Logo__c"] =matches;
                        }
                    }catch(e) {
                        console.log('Error: ' +e.message);
                    }
                }
            }
        }
        this.data =accts;
        this.datacopy = accts;
        this.tableLoadingState = false;*/
    }
    parseImageColumns(){
        let accts =JSON.parse(JSON.stringify( this.inputAccounts));
        for (const index in accts) {
            let row = accts[index];
            //console.log(JSON.stringify(row));

           this.imageColumns.forEach(function (imageCol, index) {
              // console.log('imageCol: ' + imageCol);
              if (imageCol in row) {
                    let col =row[imageCol];
                   // console.log('col 1: ' + JSON.stringify(col));
                    if(col){
                        try{
                         
                            col = col.replace(/amp;/g, "");
                            col = col.split("; "); 
                            //console.log('col 2: ' +  JSON.stringify(col)); 
                            row[imageCol] = col;
                            //let match = col.match(/<?src="(.*?)"/gi);
                            //if(match){
                            //    const matches = match.map(element => element.replace('src="','').replace('"','')).join(';');
                            //    row[imageCol] =matches;
                           // }
                        }catch(e) {
                            console.log('Error: ' +e.message);
                        }
                    }
                }
            });
        }
        this.data =accts;
        this.datacopy = accts;
        this.tableLoadingState = false;
    }
    sortData(fieldName, sortDirection){
       let dat =JSON.parse(JSON.stringify(this.data));
       let key =(a) => a[fieldName]; 
       let reverse = sortDirection === 'asc' ? 1: -1;
       dat.sort((a,b) => {
           let valueA = key(a) ? key(a).toLowerCase() : '';
           let valueB = key(b) ? key(b).toLowerCase() : '';
           return reverse * ((valueA > valueB) - (valueB > valueA));
       });
       this.data = dat;
   }

   updateColumnSorting(event){
       this.sortedBy = event.detail.fieldName;
       this.sortedDirection = event.detail.sortDirection;
       this.sortData(this.sortedBy,this.sortedDirection);       
   }

   init(){
        // Column Settings
        let cols = new Array();
        for (let i=101; i < 111; i++) {
            let letIcon = '';       
            let colName = 'column'+i.toString().substring(1)+'_fieldName'; 
            let dataType = this['column'+i.toString().substring(1)+'_type'];
               if(this[colName]) {
                if (i.toString().substring(1) === '01') {
                    letIcon =this['column'+i.toString().substring(1)+'_icon']
                }
                let cellClass =  
                    this[dataType] == 'number'|| this[dataType] == 'currency' ? 
                	{
                		fieldName : this[colName] + 'class'
                	}
            		:
                    {};
                    
                let vEditable = this['column'+i.toString().substring(1)+'_editable'] == true;
            	if(dataType === 'custombutton'){
                    cols.push({
                        type:  'custombutton',
                        label: this['column'+i.toString().substring(1)+'_align'] ,
                        typeAttributes: 
                        {
                            iconName: '',                     
                            label: this[colName], 
                            name: this[colName], 
                            title: this['column'+i.toString().substring(1)+'_type'], 
                            initialWidth: this['column'+i.toString().substring(1)+'_width'], 
                            cellAttributes: {
                                alignment: 'center'                                                   	
                            }, 
                            variant: "brand",
                            disabled: false, 
                            value: 'test',
                            rowid:{fieldName:'Id'},
                            url: this['column'+i.toString().substring(1)+'_label']
                        }
                    });
                }else{
                    cols.push({
                        iconName: letIcon,
                        label: this['column'+i.toString().substring(1)+'_label'], 
                        fieldName: this[colName], 
                        type: this['column'+i.toString().substring(1)+'_type'], 
                        sortable: false, 
                        initialWidth: this['column'+i.toString().substring(1)+'_width'], 
                        cellAttributes: {
                            alignment: this['column'+i.toString().substring(1)+'_align'],
                            class: cellClass                        	
                        },
                        wrapText: true
                    });
                    if(dataType === 'image'){
                        this.imageColumns.push(this[colName]);
                    }     
                }                             
                                              
            }
        }       
        //console.log(JSON.stringify(this.imageColumns));   
        //console.log(JSON.stringify(cols));
        this.columns = cols;
        this.parseImageColumns();
   }
   
    //split apart each column into words and return if search filter matches
    filter(event) {
        let KEYCODE_BACKSPACE = 8;
        let keyCode = event.which || event.keyCode || 0;
        let element = this.template.querySelector("[data-Id='Search']");
        let filter =element.value;
         filter = filter.trim();      
        if(!filter){
            this.data = JSON.parse(JSON.stringify(this.datacopy));
        }else{
            let data = keyCode === KEYCODE_BACKSPACE ?JSON.parse(JSON.stringify(this.datacopy)):JSON.parse(JSON.stringify(this.data)),
            //let data = JSON.parse(JSON.stringify(this.data)),
            term =  filter,
            results = data, regex;
            try {
                regex = new RegExp(term, "i");
                function filterList(nameList) {
                        function escapeRegExp(s) {
                            return s.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
                        }
                        const words = filter
                            .split(/\s+/g)
                            .map(s => s.trim())
                            .filter(s => !!s);
                        const hasTrailingSpace = filter.endsWith(" ");
                        const searchRegex = new RegExp(
                            words
                            .map((word, i) => {
                                if (i + 1 === words.length && !hasTrailingSpace) {
                                return `(?=.*\\b${escapeRegExp(word)})`;
                                } else {
                                return `(?=.*\\b${escapeRegExp(word)}\\b)`;
                                }
                            })
                            .join("") + ".+",
                            "gi"
                        );
                        return data.filter(row => {
                            return (searchRegex.test(row[ nameList[0]]) || searchRegex.test(row[ nameList[1]]) || searchRegex.test(row[nameList[2]]) || searchRegex.test(row[ nameList[3]]) || searchRegex.test(row[ nameList[4]])|| searchRegex.test(row[ nameList[5]]));
                          // return (searchRegex.test(row[ nameList[0]]) );
                        });
                    }
                   
                    results = filterList( [this.column01_fieldName,this.column02_fieldName,this.column03_fieldName,this.column04_fieldName,this.column05_fieldName,this.column06_fieldName]);
                   
                    //console.log('results: ' + JSON.stringify(results));
            }catch(e) {
                console.log(e.message);
            }
            this.data = results;
        }
    }
    renderedCallback() {
       try{
            if (!this.hasRendered) {
                const style = document.createElement("style");
               style.innerText =
                  ".slds-th__action-button {display: none;} .slds-resizable__handle {display: none;}";
               
                this.template
                    .querySelector("c-custom-types-data-table")
                    .appendChild(style);
        
                this.hasRendered = true;
            }
        }
        catch(e){
            console.log('err: ' + e.message)
        }
    }
}