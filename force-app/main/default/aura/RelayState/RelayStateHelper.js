({
    getURLParams: function(component,params){
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
   },
   saveStartURL: function(component,event){
       try{
            let paramlist = ['startURL'];
            let parms = this.getURLParams(component,paramlist);
            if ('startURL' in parms) {
                let relayState =parms['startURL'];
                if(relayState){
                relayState =relayState.replace('?language','');
                }
                localStorage.setItem('startURL',relayState); 
            }
        }
        catch(err) {
            console.log(err.message);
        }
   },
   getParams: function(component,params){

    let queryString ='';
    try{
        let sPageURL = decodeURIComponent(window.location.search.substring(1));
        let sURLVariables = sPageURL.split('&'); 
       // console.log(' sURLVariables' +  sURLVariables);
        let sParameterName;
        let foundInfo = false;
        for (let i = 0; i < sURLVariables.length; i++) {
            sURLVariables[i] =  sURLVariables[i].replace("amp;","");
            sParameterName = sURLVariables[i].split('=');
            console.log('sParameterName[0]: ' + sParameterName[0]);
            if(sParameterName[0] === 'language'){
                queryString =  sParameterName[0] + "=" +sParameterName[1].replace(":+[TimeZoneSidKey]","");
                //console.log('queryString ' + queryString);
            }else if(sParameterName[0] === 'info'){
                localStorage.setItem('info',sParameterName[1]);
                foundInfo = true; 
            }
        }
        
        let relayState =localStorage.getItem('startURL'); 
        let url='';
        if(foundInfo === true){
            if(relayState){
                url =  relayState + '?' + queryString;
             }
             else{
                url = "/HelpCommunity/s/?" + queryString;
             }
             window.location.replace(url );
        }
    }
    catch(err) {
       console.log(err.message);
      }
    },  
    saveAttributesAndRedirect: function(component,event){
        try{
            let relayState =localStorage.getItem('startURL'); 
            let mylist = ['language','info'];
            let parms = this.getParams(component,mylist);
        }
        catch(err) {
            console.log(err.message);
        }
    }
})