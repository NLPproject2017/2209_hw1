model Grid

global {
	int number_of_queens <- 4;
	list<point, string> queens_positions;
	bool position_set <- false;
	init {    
		matrix data <- matrix([[1,0,1,0,1,0,1,0],[0,1,0,1,0,1,0,1],[1,0,1,0,1,0,1,0],[0,1,0,1,0,1,0,1],
							   [1,0,1,0,1,0,1,0],[0,1,0,1,0,1,0,1],[1,0,1,0,1,0,1,0],[0,1,0,1,0,1,0,1]]);
		
		ask cell {
			bool is_obstacle <-flip(0.2);
      		grid_value <- float(data[grid_x,grid_y]);
      		write data[grid_x,grid_y];
      		}
      	
      	create Queen number: number_of_queens {
      		//location <- data[1 + rnd(1,6) ,1 + rnd(1,6)];
      		position_set <- false;
      		point temp_location<-(cell grid_at {rnd(0,7),rnd(0,7)}).location;
      		
      		loop while: !(position_set) {
      			if (queens_positions contains [temp_location, name]){
      			temp_location<-(cell grid_at {rnd(0,7),rnd(0,7)}).location;
      			} else{
      				position_set <-true;
      			}      			
      		}
      		add [temp_location, name] to: queens_positions;
      		location <-temp_location;
      		
      		//queens_positions
      	}
      	    	
		}
	}
	
species Queen skills: [fipa, moving] {
	list<list> neighbour_position;
	
	
	aspect base {
		draw triangle(2) color: #blue ;
}

}

grid cell width: 8 height: 8 neighbors: 4 {
	//bool is_obstacle <- flip(0.2);
	rgb color; 
	float grid_value;
	
	reflex update_color {
    	write grid_value;
    	color <- (grid_value = 1) ? #grey : #white;
    	}
	}


experiment goto_grid type: gui {
	output {
		display objects_display {
			grid cell lines: #black;
			species Queen aspect: base;
			}
		}
	}