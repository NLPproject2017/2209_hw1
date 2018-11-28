model Grid

global {
	bool globalPositioning <-false;
	int number_of_queens <- 8;
	
	list grid_occupation; // [cell, queenName]
	list grid_occupied_cells;//[cell] only occupied cell info
	int grid_size <- 8;
	int grid_cell_counter <-1; 
	
	//[cell_of_queen, name, isCollided]
	list queens_positions;
	//list<agent, collisionStatus> successMatrix;
	bool globalPositionCheck<-false;
	bool position_set <- false;
	int x_axis <- 0;
	string lastCreatedQueen;
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
      		
      		//pred/succ set
      		predecessor <- lastCreatedQueen;
      		
      		lastCreatedQueen<-name;
      		
      		//loop y over: number_of_queens-1 {
      			call_location <-cell grid_at {x_axis, 0};
      			temp_location<-(call_location).location;
      			write "Queen:" + name + " is placed at " +  "0:" + x_axis; 
      			x_axis <- x_axis + 1; 
      		
      		//add [call_location, name] to: queens_positions;
      		add [call_location, name, predecessor, "to_be_updated"] to: queens_positions;
      		myCell <- call_location;
      		location <-temp_location;
      		position_set <-true;
      		
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
	string predecessor;
	string successor;
	bool askedToMove <- false;
	bool collision <-false;
	int myX <- location.x; //This should be grid value	
	int myY <- location.y;
	bool occupyCrossCells <-false;
	cell myCell;
	bool findAndMoveToLocation<-false;
	
	reflex move_to_new_position when: findAndMoveToLocation {
		write name + ":I was aked to check my collision status and move my position";
		//if(neighbour_position[0]=myX){ // or neighbour_positionY=myY){ 			
		//ask predecessor {
		//}
	 //}
	 
	 write "Finding place for it. Current position: " + myCell;
    			int gridX <-myCell.grid_x;
    			int loopGridY <-0;
    			bool isFound<-false;
	    		loop while:( loopGridY <= number_of_queens  - 1 and !isFound){
	    			cell cell_candidate <-cell grid_at {gridX, loopGridY};
	    			
	    			if (grid_occupied_cells contains cell_candidate)
	    			{
	    				write cell_candidate.name + "already occupied";
	    			}else{
	    				isFound <-true;
	    				write "Should exclude these: " + grid_occupied_cells;
	    				write cell_candidate.name + "Found for " + name;
	    				myCell <-cell_candidate;
	    				location <-cell_candidate.location;
	    				findAndMoveToLocation<-false;
	    				occupyCrossCells<-true;
	    			}
	    			loopGridY<-loopGridY + 1;
	    			//remove getQueenForPositionCheck from: queens_positions;
	    			//add [cell_candidate, selectedQueenName] to:queens_positions;
	    			//queens_positions[loopI][0]<-cell_candidate;
	    		}
	    		
	}
	
	reflex occupy_corossed_cells when: occupyCrossCells {
		occupyCrossCells<-false;
		location <-myCell.location;
		write name + "'s ccupy cell reflex called";
		//Occupy all related cells.
		    	int loopGridX <- 0;
		    	write "Currently: grid_occupied_cells" + grid_occupied_cells;
	    		loop while:( loopGridX <= number_of_queens  - 1){
	    			
	    			int loopGridY <- 0;
	    			
	    			loop while:( loopGridY <= number_of_queens  - 1){
	    				
	    				cell cell_to_occupy <-cell grid_at {loopGridX, loopGridY};
	    				
	    				if (grid_occupied_cells contains cell_to_occupy){
	    					//write cell_to_occupy.name  + " is ALREADY occupied";
	    				}
	    				else {
			    			// Occupay if in the same row 
			    			if (cell_to_occupy.grid_y = myCell.grid_y or
			    				cell_to_occupy.grid_x = myCell.grid_x or 
			    				cell_to_occupy.grid_x - myCell.grid_x = cell_to_occupy.grid_y - myCell.grid_y
			    			)
			    			{
			    				write cell_to_occupy.name  + " is now occupied by:" + name;
			    				add [cell_to_occupy, name] to: grid_occupation;
			    				add  cell_to_occupy to: grid_occupied_cells;
			    			}			
		    			}
		    			loopGridY <-loopGridY + 1;
	    			}
	    			loopGridX <-loopGridX + 1;
	    		}
	    		write "grid_occupied_cells:" + grid_occupied_cells;
	    		write "grid_occupation:" + grid_occupation; 
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
		write name + " is created at location: " + grid_x + ":" + grid_y;
    	color <- (grid_value = 1) ? #grey : #white;
    	
    	write "grid_cell_counter=" + grid_cell_counter;
    	if (grid_cell_counter = 64){
    		globalPositionCheck <-true;
    		}
    	grid_cell_counter <- grid_cell_counter + 1;
    		
    	}
    	
    	
//    reflex check_for_positions when: globalPositionCheck
//    {
//    	write queens_positions;
//    	globalPositionCheck <- false;
//    	write "globalPositionCheck is called";
//    	string selectedQueenName;
//    	bool selectedQueenCollided <- false; //keep global state ?
//    	int loopI <- 0;
//    	//Finding the next Collided queen
//    	write "Queen positions: " + queens_positions;
//    	loop while: (loopI <= length(queens_positions) - 1)
//    	{
//    		if (selectedQueenCollided)
//    		{
//    			break;
//    		}
//
//    		list getQueenForPositionCheck <- queens_positions[queens_positions[loopI]];
//    		//selectedQueenCollided <-false; // maybe get from queens_positions
//    		selectedQueenName <- getQueenForPositionCheck[1];
//    		cell selectedQueenCell <- getQueenForPositionCheck[0];
//    		write "Selected queen To Check:" + getQueenForPositionCheck + " \n Queen element:" + selectedQueenName;
//    		int loopJ <- 0;
//    		write length(queens_positions) - 1;
//    		loop while: (loopJ <= length(queens_positions) - 1)
//    		{
//    			cell otherQueen <- (queens_positions[loopJ])[0];
//    			write "OtherQueen :" + otherQueen;
//    			write "Comparing ->" + getQueenForPositionCheck + " against " + otherQueen;
//    			//row check
//    			if (selectedQueenCell != otherQueen and selectedQueenCell.grid_y = otherQueen.grid_y)
//    			{
//    				selectedQueenCollided <- true;
//    				write "RAW Collision->" + getQueenForPositionCheck + " with " + otherQueen;
//    				break;
//    			}
//    			//Column. It doesn't hit on  our setup.
//    			if (selectedQueenCell != otherQueen and selectedQueenCell.grid_x = otherQueen.grid_x)
//    			{
//    				selectedQueenCollided <- true;
//    				write "COLUMN Collision->" + getQueenForPositionCheck + " with " + otherQueen;
//    				break;
//    			}
//
//    			//DiagonalCheck. X1-x2 and y1-y2 should be same value;
//    			//Example cell 1,3, and cell 3,5
//    			if (selectedQueenCell != otherQueen and selectedQueenCell.grid_x - otherQueen.grid_x = selectedQueenCell.grid_y - otherQueen.grid_y)
//    			{
//    				selectedQueenCollided <- true;
//    				write "DIAGONAL Collision->" + getQueenForPositionCheck + " with " + otherQueen;
//    				break;
//    			}
//
//    			loopJ <- loopJ + 1;
//    			//write "j=" + j +" and LoopJ=" + loopJ + "\n length(queens_positions)-1=" + (length(queens_positions)-1);
//    		}
//
//    		loopJ <- 0;
//    		if (selectedQueenCollided)
//    		{
//    			ask Queen
//    			{
//    				if (self.name = selectedQueenName)
//    				{
//    				//write "Grid Asking " + self.name + " to check or move its position";
//    					self.askedToMove <- true;
//    				}
//
//    			}
//
//    			globalPositionCheck <- false;
//    		}
//
//    		loopI <- loopI + 1;
//    	}
//
//    }
//    
    reflex check_for_positions when: globalPositionCheck {
    	globalPositionCheck <-false;
    	
    	write "globalPositioning started is called";
    	write "Current Queens positions: " + queens_positions;
    	
    	string selectedQueenName;
    	bool selectedQueenCollided <-false;
    	
    	int loopI<-0;
    	loop while:( loopI <= length(queens_positions)-1){
    		
    		list getQueenForPositionCheck <-queens_positions[loopI];
	    	selectedQueenName <- getQueenForPositionCheck[1];
	    	cell selectedQueenCell <- getQueenForPositionCheck[0];
	    	
	    	write "Current itereation for: " + selectedQueenName;
	    	
	    	//For initial Queen only.
	    	if (loopI = 0){
	    		cell cell_location <-cell grid_at {0, 6};
	    		getQueenForPositionCheck[0] <-cell_location;
	    		selectedQueenCell <-cell_location;
	    		
		    	ask Queen {
		    		if (self.name = selectedQueenName){
		    			self.location <- selectedQueenCell.location;
		    			self.myCell <- selectedQueenCell;
		    			self.occupyCrossCells <-true;
		    			}
		    		}
		    	//remove getQueenForPositionCheck from: queens_positions;
	    		//add [selectedQueenCell, selectedQueenName] to:queens_positions;
		    	selectedQueenCell <- getQueenForPositionCheck[0];
		    	write "Selected queen:" + selectedQueenName + " at cell: " + selectedQueenCell;
		    	
// MOVED TO QUEEN	    	
//		    	//Occupy all related cells.
//		    	int loopGridX <- 0;
//	    		loop while:( loopGridX <= number_of_queens  - 1){
//	    			
//	    			int loopGridY <- 0;
//	    			
//	    			loop while:( loopGridY <= number_of_queens  - 1){
//	    				
//	    				cell cell_to_occupy <-cell grid_at {loopGridX, loopGridY};
//	    				
//	    				if (grid_occupied_cells contains cell_to_occupy){
//	    					//write cell_to_occupy.name  + " is ALREADY occupied";
//	    				}
//	    				else {
//			    			// Occupay if in the same row 
//			    			if (cell_to_occupy.grid_y = selectedQueenCell.grid_y or
//			    				cell_to_occupy.grid_x = selectedQueenCell.grid_x or 
//			    				cell_to_occupy.grid_x - selectedQueenCell.grid_x = cell_to_occupy.grid_y - selectedQueenCell.grid_y
//			    			)
//			    			{
//			    				write cell_to_occupy.name  + " is now occupied by:" + selectedQueenName;
//			    				add [cell_to_occupy, selectedQueenName] to: grid_occupation;
//			    				add  cell_to_occupy to: grid_occupied_cells;
//			    			}			
//		    			}
//		    			loopGridY <-loopGridY + 1;
//	    			}
//	    			loopGridX <-loopGridX + 1;
//	    		}
	    		
	    		//write "Queen " + selectedQueenName+ " occupied:" + grid_occupation;
	    		//write "all occupied cells so far: " + grid_occupied_cells;
    		}
    		//Next queens should be placed by checking previous occupied cells. 
    		else {
    			ask Queen {
			    			if (self.name = selectedQueenName){
			    			self.findAndMoveToLocation <-true;
			    			}
		    			}
    			/*
    			//Search for potential cell to place next queen.
    			write "Finding place for it. Current position: " + selectedQueenCell;
    			int gridX <-selectedQueenCell.grid_x;
    			int loopGridY <-0;
    			bool isFound<-false;
	    		loop while:( loopGridY <= number_of_queens  - 1 and !isFound){
	    			cell cell_candidate <-cell grid_at {gridX, loopGridY};
	    			
	    			if (grid_occupied_cells contains cell_candidate)
	    			{
	    				write cell_candidate.name + "already occupied";
	    			}else{
	    				isFound <-true;
	    				write "Should exclude these: " + grid_occupied_cells;
	    				write cell_candidate.name + "Found for " + selectedQueenName ;
	    				ask Queen {
			    			if (self.name = selectedQueenName){
			    			self.location <- cell_candidate.location;
			    			self.myCell <- cell_candidate;
		    				self.occupyCrossCells <-true;
			    			}
		    			}
	    			}
	    			loopGridY<-loopGridY + 1;
	    			//remove getQueenForPositionCheck from: queens_positions;
	    			//add [cell_candidate, selectedQueenName] to:queens_positions;
	    			//queens_positions[loopI][0]<-cell_candidate;
	    		}
	    		* 
	    		*/
	    			
    		} 
//	    		
	    	loopI <-loopI + 1;
    	}
    	write "queen positions: " + queens_positions;
    	write "Gridd occupation by Queens: " + grid_occupation;
	    write "all occupied cells so far: " + grid_occupied_cells;
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