({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    updateEditedValues: function(cmp, drafts) {
        var keyField = cmp.get("v.keyField");
        var data = cmp.get("v.mydata");

        // apply drafts to mydata
        data = data.map(item => {
            let draft = drafts.find(d => d[keyField] == item[keyField]);

            if (draft != undefined) {
                let fieldNames = Object.keys(draft);
                fieldNames.forEach(el => item[el] = draft[el]);
            }

            return item;
        });

        cmp.set("v.mydata", data);
    },
    getURLParams: function(component,params){
        console.log('getParms');
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
                console.log('param ' + sParameterName[0] + ' : ' +sParameterName[1]  + 'includes' +params.includes(sParameterName[0]));
                if(params.includes(sParameterName[0])){
                    let parm = sParameterName[1] === undefined ? true : sParameterName[1];
                    retVal[sParameterName[0]] = sParameterName[1];
                }
         
            }
            console.log('obj ' + JSON.stringify( retVal));
            return retVal;
        }
        catch(err) {
           console.log(err.message);
          }
    }
})