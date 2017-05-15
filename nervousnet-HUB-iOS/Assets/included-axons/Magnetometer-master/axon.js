(function(){

	//call the UI page "home"
	App.load('home');
	
	setInterval(function(){
	
		$.getJSON( "http://localhost:8080/nervousnet-api/raw-sensor-data/Magnetometer", function( data ) {
                  
                  //the data field names need to match those given in the sensors?configration.json config
                  $("#first-row-value").html(truncate(data.x));
                  $("#second-row-value").html(truncate(data.y));
                  $("#third-row-value").html(truncate(data.z));
		});
		
		
	}, 1000);
	

})();
 
 function truncate( stringFloat ) {
    var num = parseFloat(stringFloat);
    return num.toFixed(8);
}
