model Grid

global {
	init {    
		matrix data <- matrix([[1,0,1,0],[0,1,0,1],[1,0,1,0],[0,1,0,1]]);
		ask cell {
      		grid_value <- float(data[grid_x,grid_y]);
      		write data[grid_x,grid_y];
    }
		}
	}


grid cell width: 4 height: 4 neighbors: 4 {
	//bool is_obstacle <- flip(0.2);
	rgb color; 
	float grid_value;
	
	reflex update_color {
    	write grid_value;
    	color <- (grid_value = 1) ? #black : #white;
  }
	}


experiment goto_grid type: gui {
	output {
		display objects_display {
			grid cell lines: #black;

		}
	}
}