/*
 * Group 11: Shakhrom Rustamov, Henrietta Hellberg
 *  Asignement 3, Task 1 - NQueens problem.
 * 
 */
model Grid
global {
	//PLEASE SET QUEEN SIZE FOR NQueen Problem
	int number_of_queens <- 10;
	
	int grid_size <- number_of_queens * number_of_queens;
	int grid_cell_counter <-1; 
	int x_axis <- 0;
	matrix data;
	
	bool globalPositioning <-false;
	bool globalPositionCheck<-false;
	bool setQueenParameters <-false;
	
	list grid_occupation; // [cell, queenName]
	list grid_occupied_cells;//[cell] only occupied cell info
	list queens_positions;//[name, Placed/NotPlaced] Placed - when Queen position match all rules of the game
	list allQueens;//list<agent, collisionStatus> successMatrix;
	string lastCreatedQueen;
	
	init {    
		
		//
		list matrixData;
		int color_flip_column<-1;
		int color_flip_row<-1;
		int i <-1;
		loop while:( i <= number_of_queens) {
			color_flip_column <-color_flip_row;
			list rowMatrix;
			int j <-1;
			loop  while:( j <= number_of_queens){
				add color_flip_column to:rowMatrix;
				color_flip_column <- color_flip_column = 1 ? 0 : 1;
				
				j<-j+1;
			}
			write "row matrix: " + rowMatrix;
			add rowMatrix to:matrixData;
			color_flip_row <- color_flip_row = 1 ? 0 : 1;
			i<-i+1;
		}
		data <- matrix(matrixData);
		
		ask cell {
			bool is_obstacle <-flip(0.2);
      		grid_value <- float(data[grid_x,grid_y]);
      		//write data[grid_x,grid_y];
      		}
      	
      	create Queen number: number_of_queens {
      		point temp_location;
      		cell call_location;
  			
  			call_location <-cell grid_at {x_axis, 0};
  			temp_location<-(call_location).location;
  			write name + " is waiting to placed at " +  " at column:" + x_axis; 
  			x_axis <- x_axis + 1; 
  		
      		add [name, "NotPlaced"] to: queens_positions;
      		
      		myCell <- call_location;
      		myX <-call_location.grid_x;
      		myY<-call_location.grid_y;
      		location <-temp_location;
      	}
      	    	
		}
	}

	
species Queen skills: [fipa, moving] {
	int myX <- location.x; //This should be grid value	
	int myY <- location.y;

	string predecessor;
	string successor;

	cell myCell;
	cell myOldCell;
	list myOldMoves;

	bool askedToMove <- false;
	bool collision <-false;
	bool occupyCrossCells <-false;
	bool findAndMoveToLocation<-false;
	bool updatePosition<-false;
	bool isBusy<-false;
	bool askedByPredecessor <-false;

	list<list> neighbour_position;
	
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
				string currentPositionText <- (myCell = nil) ? nil: ("[" + myCell.grid_x + ":" + myCell.grid_y + "]");
				write name + ": Finding place for myself. My current position: " + myCell;
    			int gridX <-myX;
    			int loopGridY <-0;
    			bool isFound<-false;
    			
	    		loop while:( loopGridY <= number_of_queens  - 1 and !isFound){
	    			cell cell_candidate <-cell grid_at {gridX, loopGridY};
	    			
	    			//Checks all unsuccessfull old Cell moves and if still not found new, it should ask predecessor
	    			//if (grid_occupied_cells contains cell_candidate or cell_candidate=myOldCell)
	    			if (grid_occupied_cells contains cell_candidate or myOldMoves contains cell_candidate)
	    			{
	    				//write name: cell_candidate.name + "already occupied";
	    				if (myOldMoves contains cell_candidate)
	    				{
	    					//write name + ":It was my old cell! I can't choose it!";
	    				}
	    			}else{
	    				isFound <-true;
	    				write name + ": Found a place to move: " +cell_candidate + "[" + cell_candidate.grid_x + ":" + cell_candidate.grid_y + "]";
	    				
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
	    		write name + ": Already in safe spot at " + myCell;
	    				myCell <-myCell;
	    				location <-myCell.location;
	    				findAndMoveToLocation<-false;
	    				updatePosition<-false;
	    				occupyCrossCells<-true;
	    	}
	}
	
	reflex occupy_corossed_cells when: occupyCrossCells {
		location <-myCell.location;
		write name + ": booking same row, column and diagonal cells!";
		//Occupy all related cells.
    	int loopGridX <- 0;
    	//write "Currently: grid_occupied_cells" + grid_occupied_cells;
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
	    				write name + ": Confirming that there are available position for my successor to move!";
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
	    					write name + ": Replying to my successor - " + successor + ": I've moved, find your place";
	    					
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
//				    		write "DEBUG: Stuck at grid. Info: \n debugObj: " + debugObj + 
//				    		"\n successor=" + successor +
//				    		"\n updatePosition=" + updatePos +
//				    		"\n findPos=" + findPos +
//				    		"\n occupyCross=" + occupyCross;
	    						
	    				} 
	    		else{
    					//write "Quuens Global Position Status:"  + queens_positions;
						globalPositionCheck<-true;
	    		}
	    	
		}
		else {
			write name + ": No place is available for my successor to move, asking predecessor: "+ predecessor + " to update its position.";
			//Removing my cell occupation
			write name + ": Deleting my position data first";
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

grid cell width: number_of_queens height: number_of_queens neighbors: 4 {
	//bool is_obstacle <- flip(0.2);
	rgb color; 
	float grid_value;
	
	reflex update_color when: grid_cell_counter <= grid_size {
		color <- (grid_value = 1) ? #grey : #white;
    	if (grid_cell_counter = grid_size){
    		setQueenParameters <-true;
    		}
    	grid_cell_counter <- grid_cell_counter + 1;
    		
    	}

reflex set_queen_parameters when: setQueenParameters {
		//pred/succ set
    	int loopI<-0;
    	int maxLimit <- length(queens_positions)-1;
    	loop while:(loopI <= maxLimit){
    		string queenName <- queens_positions[loopI][0];
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
    		
    		//write "Set parameteres for " + queenName + " with successor: " + successorQueenName + " and predecessor: " + predecessorQueenName;  
    		
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
    	
    	
    	write "globalPositionCheck reflex started is called";
    	write "All Queens Status: " + queens_positions;
    	
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
    		write "All queens are placed accoring to rules!";
    		
    	}else{
    		write "Next Queen to be placed:" + selectedQueenName;
	    	ask Queen {
	    		if (self.name = selectedQueenName){
	    			self.findAndMoveToLocation <-true;
				}
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