model Grid

global {
	int number_of_queens <- 4;
	int grid_cell_counter <-1; 
	list queens_positions;
	//list<agent, collisionStatus> successMatrix;
	bool globalPositionCheck<-false;
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
	bool askedToMove <- false;
	bool collision <-false;
	
	reflex move_to_new_position when: askedToMove {
		write name + ":I was aked to check my collision status and move my position";
	}
	
	aspect base {
		draw triangle(2) color: #blue ;
}

}

grid cell width: 8 height: 8 neighbors: 4 {
	//bool is_obstacle <- flip(0.2);
	rgb color; 
	float grid_value;
	
	reflex update_color when: grid_cell_counter <= 64 {
		write name + " is created at locaiton: " + grid_x + ":" + grid_y;
    	color <- (grid_value = 1) ? #grey : #white;
    	    	
    	    	
    	write "grid_cell_counter=" + grid_cell_counter;
    	if (grid_cell_counter = 64){
    		globalPositionCheck <-true;
    		}
    	grid_cell_counter <- grid_cell_counter + 1;
    		
    	}
    	
    	
    reflex check_for_positions when: globalPositionCheck {
    	write "globalPositionCheck is called";
    	list getQueenForPositionCheck <- queens_positions[rnd(0, length(queens_positions)-1)];
    	string selectedQueen <- getQueenForPositionCheck[1];
    	
    	write "Random selected queen list:" + getQueenForPositionCheck + " \n Queen element:"  + selectedQueen;
    	
    	ask Queen {
    		if (self.name = selectedQueen){
    			write "Grid Asking " + self.name + " to check or move its position";
    			self.askedToMove <-true;
    		}
    	}
    	globalPositionCheck <-false;
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