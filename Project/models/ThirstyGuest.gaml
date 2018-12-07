
model festival
import "main.gaml"

species guest skills: [moving] {
	float size <- 1.0 ;
	rgb color <- #blue;
	
	store storeList;
	
	point currentStore;
	point storeToGoTo;
	
	list<point> currentStores; //list of all stores guest knows of
	
	int chance <- 20;
	int anotherStoreChance<-2;
	int n <- rnd(100);

	bool thirsty <-false;
	bool hungry<-false;
	bool askAgain <- false;
	bool going <-false;
	bool knowAll <-false;
	bool storeEmpty<-false;
	bool hungryOrThirsty<-true;
	bool beingKilled<-false;
	
	//TRAVELED
	int movedDistance;
	float x1;
	float y1;
	float x2;
	float y2;
	point emptyStoreInfo;
	
	reflex die when: beingKilled  {
		do die ;
	}
		
	reflex beIdle when: !thirsty and !hungry
	{
		do wander;
		
		if(rnd(chance)=1){
			//get thirsty or hungry
			if(hungryOrThirsty){
				thirsty<-true;
				hungryOrThirsty<-false;
			}
			else{
				hungry<-true;
				hungryOrThirsty<-true;
			}
			
			if(knowAll=false){
				//possibly ask for a new store
				if((rnd(anotherStoreChance)=1) and (currentStore !=nil)){
					askAgain <- true;
					//write " askAgain "+askAgain +" name: "+n;
				}
			}
		}
	}
	reflex goToPoint when: ((hungry or thirsty) and currentStore=nil) or askAgain or storeEmpty
	{
		// calc distance traveled
		x1<-location.x;
		y1<-location.y;
		//------------------------
		do goto target:infoPoint speed: 3.0;
		
		if(location distance_to(infoPoint)<2){
			storeEmpty<-false;
			
			// TRAVELED
			x2<-location.x;
			y2<-location.y;
			float newDistance <-sqrt(((x2-x1)^2)+(y2-y1)^2);
			movedDistance <- movedDistance + newDistance;
			//write "Guest: "+n+" total distance traveled: "+movedDistance;
			
			ask info at_distance 7.1
			{
				// maybe move this to infopoint
				if (rnd(myself.chance+ 30)=5) //Randomly choosen as BadAgent
				{
					//write "Guest number: " + myself.n + " is declared as Bad Guest. Security Called.";
					callingGuard <- true;
					self.badAgentLocation <- myself;
					self.badGuestNumber <- myself.n;
				}
				
				if (myself.emptyStoreInfo!=nil){
					
					//to ignore duplicates
					if((!(self.emptyStores contains myself.emptyStoreInfo) and !self.busy)){
						remove myself.emptyStoreInfo from: self.stores;
						add myself.emptyStoreInfo to:self.emptyStores;
						//keeps adding duplicates of empty stores
						//write "Empty Store: " + myself.emptyStoreInfo+ " is reported and removed from Info store list, length: "+length(self.stores)+" emptyStores: "+length(self.emptyStores);
						myself.emptyStoreInfo<-nil;
					}
					
				}
				// get store location from point
				if(length(self.stores)>0){
					if(myself.askAgain){
				
						//write "asked for another store " +myself.askAgain;
						myself.currentStore<-self.stores[rnd(length(self.stores)-1)];  
					}	
					else{		
						myself.currentStore<-self.stores[rnd(length(self.stores)-1)];  
						//write " asked for first store";
						//write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
					}
				}
				else{
				 	//stop thirst and hunger when waiting.. dont really need				
					myself.thirsty <-false; 					
					myself.hungry <-false; 	
									
					//myself.askAgain<-false; 	
				}	
			}
			//remeber it
		
			//loop i from: 0 to: length(currentStores) -1 {
				if(currentStore != nil){
				//if we already know about all stores
				if((!(currentStores contains currentStore))){
					if(length(currentStores)<=stores_init){
						add currentStore to:currentStores;
					}
					}
				else{
					//write "already have that one";
					}
				}
				
				//write "number in guest list: "+ length(currentStores);
				//write "number of stores to choose from: " +length(storesGlobal);
				if(length(currentStores)=stores_init){
					knowAll <-true;
				}
				//write "my currentstores: "+currentStores[i];
			//}	
			askAgain<-false;
		}
	}
	// after we got the location of a store
	reflex goToStore when: (hungry or thirsty) and currentStore!=nil and !askAgain{
			
			if(storeToGoTo=nil){
				//pick a random store from known to go to
				storeToGoTo<-currentStores[rnd(length(currentStores)-1)];
			}
			// calc distance traveled
			x1<-location.x;
			y1<-location.y;
			//------------------------
			do goto target:storeToGoTo speed: 3.0;
			
			if(location distance_to(storeToGoTo)<2){
				//calc distance traveled
				x2<-location.x;
				y2<-location.y;
				float newDistance <-sqrt(((x2-x1)^2)+(y2-y1)^2);
				movedDistance <- movedDistance + newDistance;
				//write " guest: "+n+" moved: "+newDistance +" to store";
				//write "Guest: "+n+" total distance traveled: "+movedDistance;
				//------------------------
				ask store at_distance 2 //--------- added and edited ask
				{
				if(myself.thirsty){
					
					if(self.drinkAvailable>0){
						myself.thirsty<-false;
						// remove drink from store
						self.drinkAvailable <- self.drinkAvailable-1;
					
					}
					// only one person reports store empty
					else if(!self.alreadyReportedDrink){
						self.alreadyReportedDrink<-true;
						myself.storeEmpty<-true;
						myself.emptyStoreInfo<-self.location;
						myself.currentStore<-nil;
						//write "store was empty, going to report";
					}
					else{
						myself.currentStore<-nil;
						//write "store was empty, someone else already went to report";
					}
				}
				else{
					if(self.foodAvailable>0){
						// remove food from store
						self.foodAvailable <- self.foodAvailable-1;
						myself.hungry<-false;
					}
					// only one person reports store empty
					else if(!self.alreadyReportedFood){
						self.alreadyReportedFood<-true;
						myself.storeEmpty<-true;
						myself.emptyStoreInfo<-self.location;
						myself.currentStore<-nil;
						write "store was empty, going to report";
					}
					else{
						//myself.storeEmpty<-true;
						//myself.emptyStoreInfo<-self.location;
						myself.currentStore<-nil;
					}
				}
				}
				storeToGoTo<- nil;
			}
	}
	aspect base {
		draw circle(size) color: color ;
	}
} 
