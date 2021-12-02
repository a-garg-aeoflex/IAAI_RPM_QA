({
    init : function(component, event, helper) {
        console.log('close');
        window.onbeforeunload = function (event){
           // 
           var path = window.location.pathname;
            var page = path.split("/").pop();
            console.log( 'page' + page );
            if(page !== 'exception'){
                localStorage.removeItem('info');
            }
        }
    }
})