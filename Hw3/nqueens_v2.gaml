model Grid

global {
	bool globalPositioning <-false;
	int number_of_queens <- 8;
	
	list grid_occupation; // [cell, queenName]
	list grid_occupied_cells;//[cell] only occupied cell info
	int grid_size <- number_of_queens;
	int grid_cell_counter <-1; 
	
	//[cell_of_queen, name, isCollided]
	list queens_positions;
	//list<agent, collisionStatus> successMatrix;
	bool globalPositionCheck<-false;
	bool setQueenParameters <-false;
	bool position_set <- false;
	int x_axis <- 0;
	string lastCreatedQueen;
	list allQueens;
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
      			write "Queen:" + name + " is waiting to placed at " +  " at column:" + x_axis; 
      			x_axis <- x_axis + 1; 
      		
      		//add [call_location, name] to: queens_positions;
      		//add [call_location, name, predecessor, "NotPlaced"] to: queens_positions;
      		add [name, "NotPlaced"] to: queens_positions;
      		
      		myCell <- call_location;
      		myX <-call_location.grid_x;
      		myY<-call_location.grid_y;
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
	bool updatePosition<-false;
	bool isBusy<-false;
	cell myOldCell;
	list myOldMoves;
	
	bool askedByPredecessor <-false;
	
	reflex update_to_new_position when: updatePosition and !isBusy{
		isBusy<-true;
	 	write name +": I was asked to update myPosition";
	 	myOldCell <- myCell;
	 	add myCell to:myOldMoves; 
	 	myCell <-nil;
	 	list grida_data_deleted;
	 	loop i over:grid_occupation {
	 		if (i[1]=name){
	 			remove i[0] from:grid_occupied_cells;
	 			add i to:grida_data_deleted;
	 		}
	 	}
	 	
	 	loop t over:grida_data_deleted {
	 		remove t from:grid_occupation;
	 	}
	 	
	 	//satei@kth.se
	 	updatePosition<-false;
	 	isBusy<-false;
	 	findAndMoveToLocation<-true;
	 
	}
	reflex find_and_move_to_new_position when: findAndMoveToLocation{
		write name + ": my successor:" + successor;
		write name + ": my predecessor:" + predecessor;
		write "findAndMoveToLocation is called";
		//Checking if my current position is OK?
		bool isMyPlaceSafe<-true;
				loop g over: grid_occupation {
					if (g[0] = myCell and g[1]!=name){
					isMyPlaceSafe<-false;
					}
				}
		if (myCell = nil)
		{
			isMyPlaceSafe<-false;
		}
		
		if (!isMyPlaceSafe){
				write "Finding place for it. Current position: " + myCell;
    			int gridX <-myX;
    			int loopGridY <-0;
    			bool isFound<-false;
    			
	    		loop while:( loopGridY <= number_of_queens  - 1 and !isFound){
	    			cell cell_candidate <-cell grid_at {gridX, loopGridY};
	    			//TODO: should check all unsuccessfull old Cell moves and if still not found new, it should ask predecessor
	    			//WHEN DOES IT Empty the Old Moves list??
	    			//if (grid_occupied_cells contains cell_candidate or cell_candidate=myOldCell)
	    			if (grid_occupied_cells contains cell_candidate or myOldMoves contains cell_candidate)
	    			{
	    				//write name: cell_candidate.name + "already occupied";
	    				if (myOldMoves contains cell_candidate)
	    				{
	    					write name + ":It was my old cell! I can't choose it!";
	    				}
	    			}else{
	    				isFound <-true;
	    				write name + ": Found a place to move: " +cell_candidate.name;
	    				
	    				myCell <-cell_candidate;
	    				location <-cell_candidate.location;
	    				findAndMoveToLocation<-false;
	    				updatePosition<-false;
	    				occupyCrossCells<-true;
	    			}
	    			loopGridY<-loopGridY + 1;
	    		}
	    		//If still not found, ask predecessor to find new place.
	    		if (!isFound )
	    		{	write name + ":No place found";
	    			if (predecessor!=nil){
	    				write "Asking Predecessor " + predecessor + " to move.";
		    			ask Queen {
			    			if (self.name = myself.predecessor){
				    			self.updatePosition <-true;
				    		}
			    		}
		    		}
		    		findAndMoveToLocation<-false;
	    		}
	    		
	    	}
	    	else {
	    		//Already in safe place
	    		write name + ": Already in safe spot" + myCell;
	    				myCell <-myCell;
	    				location <-myCell.location;
	    				findAndMoveToLocation<-false;
	    				updatePosition<-false;
	    				occupyCrossCells<-true;
	    	}
	}
	
	reflex occupy_corossed_cells when: occupyCrossCells {
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
	    				abs(cell_to_occupy.grid_x - myCell.grid_x) = abs(cell_to_occupy.grid_y - myCell.grid_y)
	    			)
	    			{
	    				//write cell_to_occupy.name  + " is now occupied by:" + name;
	    				add [cell_to_occupy, name] to: grid_occupation;
	    				add  cell_to_occupy to: grid_occupied_cells;
	    			}			
    			}
    			loopGridY <-loopGridY + 1;
			}
			loopGridX <-loopGridX + 1;
		}
		occupyCrossCells<-false;
		//Check if successor have any place left
		bool isAvailbleCellFoundForSuccessor<-true;
		if (myX<=number_of_queens-2){
			//successor is in next column. Check if it has any place to move. Otherwise, ask predecessor to move.
				int gridX <-myX+1;
				write name + ": Cheking available places for my successor Queen at column: " + gridX;
    			
    			int loopGridY <-0;
    			isAvailbleCellFoundForSuccessor<-false;
    			
	    		loop while:( loopGridY <= number_of_queens  - 1 and !isAvailbleCellFoundForSuccessor){
	    			cell cell_candidate <-cell grid_at {gridX, loopGridY};
	    			
	    			if (grid_occupied_cells contains cell_candidate)
	    			{
	    				isAvailbleCellFoundForSuccessor <-false;
	    				
	    			}else{
	    				isAvailbleCellFoundForSuccessor <-true;
	    				write name + ": there are available for successor to move !";
	    			}
	    			loopGridY<-loopGridY + 1;
	    		}
		}
		if (isAvailbleCellFoundForSuccessor){	
	    	int loopI<-0;
	    	loop while:(loopI <= length(queens_positions)-1){
	    		if (queens_positions[loopI][0]=name){
	    			queens_positions[loopI] <-[name, "Placed!"];
	    			break;
	    		}
	    		loopI<-loopI + 1;
	    	}
	    	if (successor!=nil){
	    					write name + ": Replying to successor: " + successor + ": I've moved, find your place";
	    					
	    					bool updatePos;
	    					bool findPos;
	    					string debugObj;
	    					bool occupyCross;
	    					
	    					ask Queen {
					    		if (self.name =  myself.successor){
					    			self.myOldMoves <- nil; 
					    			self.updatePosition <- true;
					    			
					    			updatePos <- self.updatePosition;
					    			findPos <- self.findAndMoveToLocation;
					    			occupyCross <- self.occupyCrossCells;
					    			debugObj <-self.name;
					    		}
				    		}
				    		write "DEBUG: Stuck at grid. Info: \n debugObj: " + debugObj + 
				    		"\n successor=" + successor +
				    		"\n updatePosition=" + updatePos +
				    		"\n findPos=" + findPos +
				    		"\n occupyCross=" + occupyCross;
	    						
	    				} 
	    		else{
    					write "Quuens Global Position Status:"  + queens_positions;
						globalPositionCheck<-true;
	    		}
	    	
		}
		else {
			write name + ":No place is available for successor to move, asking predecessor: "+ predecessor + "to update its position.";
			//Removing my cell occupation
			write name + ": Deleting my data first";
			myCell <-nil;
		 	list grida_data_tobe_deleted;
		 	loop i over:grid_occupation {
		 		if (i[1]=name){
		 			remove i[0] from:grid_occupied_cells;
		 			add i to:grida_data_tobe_deleted;
		 		}
		 	}
		 	
		 	loop t over:grida_data_tobe_deleted {
		 		remove t from:grid_occupation;
		 	}
		 	
		 		
			//No place is available for successor to move, asking predecessor to update its position.
			ask Queen {
	    		if (self.name = myself.predecessor){
	    			self.updatePosition <-true;
	    		}
    		}	
		}
		
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
		//write name + " is created at location: " + grid_x + ":" + grid_y;
    	color <- (grid_value = 1) ? #grey : #white;
    	
    	//write "grid_cell_counter=" + grid_cell_counter;
    	if (grid_cell_counter = 64){
    		setQueenParameters <-true;
    		}
    	grid_cell_counter <- grid_cell_counter + 1;
    		
    	}

reflex set_queen_parameters when: setQueenParameters {
	//pred/succ set
    	write "Debug queens_positions = " + queens_positions;
    	int loopI<-0;
    	int maxLimit <- length(queens_positions)-1;
    	loop while:(loopI <= maxLimit){
    		string queenName <- queens_positions[loopI][0];
    		write queenName;
    		string successorQueenName;
    		string predecessorQueenName;
    		
    		if(loopI!=0){
    			int temp<-loopI-1;
    			predecessorQueenName <- queens_positions[temp][0];
    		}
    		
    		if(loopI!=maxLimit){
    			int temp<-loopI+1;
    			successorQueenName <- queens_positions[temp][0];
    		}
    		
    		write "Set parameteres for " + queenName + " with successor: " + successorQueenName + " and predecessor: " + predecessorQueenName;  
    		
			ask Queen {
			if (self.name = queenName){
				self.successor <- successorQueenName;
				self.predecessor <- predecessorQueenName;
				
				}
			}
    		loopI<-loopI + 1;
    	}
    	setQueenParameters <-false;
    	globalPositionCheck <-true;

}    	
    	
reflex check_for_positions when: globalPositionCheck {
    	
    	
    	write "globalPositioning started is called";
    	write "Current Queens positions: " + queens_positions;
    	
    	string selectedQueenName;
    	bool selectedQueenCollided <-false;
    	
    	
    	int loopI<-0;
    	loop while:(loopI <= length(queens_positions)-1 and selectedQueenName = nil){
    		list getQueenForPositionCheck <-queens_positions[loopI];
    		if (getQueenForPositionCheck[1]="NotPlaced"){
    			selectedQueenName <-getQueenForPositionCheck[0];
    			break;
    		}
    		loopI<-loopI + 1;
    	}
    	
    	if (selectedQueenName = nil)
    	{
    		write "All queens are placed!";
    	}else{
    		write "Next Queen to be placed:" + selectedQueenName;
	    	ask Queen {
	    		if (self.name = selectedQueenName){
	    			self.findAndMoveToLocation <-true;
				}
			}	
    	}

    	globalPositionCheck <-false;
    	//write "queen positions: " + queens_positions;
    	//write "Grid occupation by Queens: " + grid_occupation;
	    //write "all occupied cells so far: " + grid_occupied_cells;
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