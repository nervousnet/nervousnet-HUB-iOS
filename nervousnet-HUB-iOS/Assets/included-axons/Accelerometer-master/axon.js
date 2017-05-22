(function(){

	//call the UI page "home"
	App.load('home');
	
	setInterval(function(){
	
		$.getJSON( "http://localhost:8080/nervousnet-api/raw-sensor-data/Accelerometer", function( data ) {
                  
                  //the data field names need to match those given in the sensors?configration.json config
                  $("#first-row-value").html(truncate(data.accX));
                  $("#second-row-value").html(truncate(data.accY));
                  $("#third-row-value").html(truncate(data.accZ));
                  });
                
                
                }, 250);
	
 
 })();
 
 function truncate( stringFloat ) {
    var num = parseFloat(stringFloat);
    return num.toFixed(8);
}
