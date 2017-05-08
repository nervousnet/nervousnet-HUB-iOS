(function(){

	//call the UI page "home"
	App.load('home');
	
	setInterval(function(){
	
		$.getJSON( "http://localhost:8080/nervousnet-api/raw-sensor-data/Accelerometer", function( data ) {
                  
                  //the data field names need to match those given in the sensors?configration.json config
                  $("#first-row-value").html(data.accX);
                  $("#second-row-value").html(data.accY);
                  $("#third-row-value").html(data.accZ);
			
		});
		
		
	}, 1000);
	

})();
