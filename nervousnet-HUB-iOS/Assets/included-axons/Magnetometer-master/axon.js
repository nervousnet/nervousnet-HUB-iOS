(function(){

	//call the UI page "home"
	App.load('home');
	
	setInterval(function(){
	
		$.getJSON( "http://localhost:8080/nervousnet-api/raw-sensor-data/Magnetometer", function( data ) {
                  
                  //the data field names need to match those given in the sensors?configration.json config
                  $("#first-row-value").html(data.x);
                  $("#second-row-value").html(data.y);
                  $("#third-row-value").html(data.z);
		});
		
		
	}, 1000);
	

})();
