model Grid

global {
	int number_of_queens <- 8;
	int grid_cell_counter <-1; 
	list queens_positions;
	//list<agent, collisionStatus> successMatrix;
	bool globalPositionCheck<-false;
	bool position_set <- false;
	int x_axis <- 0;
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
      		point temp_location;
      		cell call_location;
      		
      		//loop y over: number_of_queens-1 {
      			call_location <-cell grid_at {x_axis, 0};
      			temp_location<-(call_location).location;
      			write "Queen:" + name + " is placed at " +  "0:" + x_axis; 
      			x_axis <- x_axis + 1; 
      			
      		//}
      		
      		//point temp_location<-(cell grid_at {rnd(0,7),rnd(0,7)}).location;
      		/* 
      		loop while: !(position_set) {
      			if (queens_positions contains [temp_location, name]){
      			temp_location<-(cell grid_at {rnd(0,7),rnd(0,7)}).location;
      			} else{
      				position_set <-true;
      			}      			
      		}
      		*/
      		add [call_location, name] to: queens_positions;
      		location <-temp_location;
      		position_set <-true;
      		//queens_positions
      	}
      	    	
		}
	}

/*
 * 1. do some "fuction"/reflex to update pred/successor
 * 2. Checks if neghbour is collisionFree, then moves it
 * 2. else, asks predecessor to move and etc.
 * */
	
species Queen skills: [fipa, moving] {
	list<list> neighbour_position;
	bool askedToMove <- false;
	bool collision <-false;
	int myX <- location.x; //This should be grid value	
	int myY <- location.y;
	
	reflex move_to_new_position when: askedToMove {
		write name + ":I was aked to check my collision status and move my position";
		if(neighbour_position[0]=myX){ // or neighbour_positionY=myY){ 			
		//ask predecessor {
		//}
	}}
	
	reflex find_predecessor when: true{ 		 	} 	
	
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
    	list getQueenForPositionCheck <- queens_positions[queens_positions[0]];
    	string selectedQueen <- getQueenForPositionCheck[1];
    	
    	write "Selected queen list:" + getQueenForPositionCheck + " \n Queen element:"  + selectedQueen;
    	
    	// Checking Queen global position
    	/*
    	 	*   q (x, y)
    	 	*  loop where x=other queenx 
    	 	* loop where x=other queeny - this is assumption, always false
    	 	* 
    	 	*  	 
    	 	* */
    	
    	
    	ask Queen {
    		if (self.name = selectedQueen){
    			//write "Grid Asking " + self.name + " to check or move its position";
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