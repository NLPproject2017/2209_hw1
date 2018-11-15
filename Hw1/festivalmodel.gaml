/**
* Name: festivalmodel
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/
//testing 
model festival

global {
	int guests_init <- 1;
	int dumb_guests_init <-2;
	int info_init<-1;
	int stores_init<-1;
	
	point infoPoint<-{50,50};
	int chance <- 20;
	int anotherStoreChance<-2;
	list<point> storesGlobal;
	bool callingGuard <-false;
	bool light<-false; //light is turned on when info center wants the worker to come
	
	init {
		create guest number: guests_init ;
		create securityGuard number: 1 ;
		create dumbGuest number: dumb_guests_init;
		create store number: stores_init{
			point p <-{rnd(75),rnd(75)};
			location<-p;
			add location to:storesGlobal;
			foodAvailable <- 2; //--------------
  			drinkAvailable<-5; //--------------
  			n<-"Store "+rnd(stores_init); //---------
		}
		create info number: info_init
		{ 
  			location <- {50,50};
  			stores<-storesGlobal;
		}
		create festivalWorker number: 1;
		
}
species info{
	int size<-3;
	rgb color <-#red;
	list<point> stores;
	list<point> emptyStores;
	bool handled<-false;
	agent badAgentLocation;
	int badGuestNumber;
	
	/*reflex requestAWorker when: (length(emptyStores)>0)// and !handled{
	{
		light<-true;
		handled<-true;
	}*/

	
 aspect base {
		draw square(size) color: color ;
	}
}
species store{
	
	int size <-3;
	rgb color<-#green;
	int foodAvailable; //--------------
	int drinkAvailable; //--------------
	string n; //----------
	
	
	aspect base {
		draw square(size) color: color ;
	}
}

species securityGuard  skills: [moving]{
	
	int size <-3;
	rgb color<-#cyan;
	bool noAction <- true; //
	agent badAgentLocation;
	int badGuestNumber;

	reflex beIdle when: noAction and callingGuard = false and badAgentLocation = nil
	{
		do wander;
	}
	
	
	reflex goToInfoPoint when: callingGuard
	{
		
		do goto target:infoPoint speed: 3.0;
		
		if(location distance_to(infoPoint)<2){
			
			ask info at_distance 7.1
			{
				
				if (self.badAgentLocation !=nil){
					write "Bad Guest found. Going to Information Desc";
					
					myself.badAgentLocation <- self.badAgentLocation;
					myself.badGuestNumber <- self.badGuestNumber;
					callingGuard <-false;
				}
			}
			
		}
		
	}
	
	reflex catchAndKill when: badAgentLocation!= nil
	{
	
		do goto target:badAgentLocation speed: 3.0;
		
		if(location distance_to(badAgentLocation)<2){
			if(callingGuard){
			write "Got the location of bad guest. Going to kill now";
			}
			ask guest at_distance 3.1
			{
				if (myself.badGuestNumber = self.n){
					write "Guest number " + self.n + " killed"; 
					self.beingKilled <-true;
					
					myself.badAgentLocation<-nil;
					myself.badGuestNumber <- nil;
				}
			}
			
			ask dumbGuest at_distance 3.1
			{
				if (myself.badGuestNumber = self.n){
					write "Guest number " + self.n + " killed"; 
					self.beingKilled <-true;
					
					myself.badAgentLocation<-nil;
					myself.badGuestNumber <- nil;
				}
			}
		}
		
	}
	
	aspect base {
		draw cylinder(3.1,1)  color: color ;
	}
}

species guest skills: [moving] {
	float size <- 1.0 ;
	rgb color <- #blue;
	bool thirsty <-false;
	bool hungry<-false;
	store storeList;
	point currentStore;
	list<point> currentStores; //list of all stores guest knows of
	int n <- rnd(100);
	bool askAgain <- false;
	bool going <-false;
	point storeToGoTo;
	bool knowAll <-false;
	//traveled
	int movedDistance;
	float x1;
	float y1;
	float x2;
	float y2;
	point emptyStoreInfo;
	
	bool storeEmpty<-false;
	
	bool hungryOrThirsty<-true;
	
	bool beingKilled<-false;
	
	reflex die when: beingKilled  {
		do die ;
	}
		
	reflex beIdle when: thirsty=false
	{
		//write "went idle: "+n;
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
					write " askAgain "+askAgain +" name: "+n;
				}
			}
		}
	}
	// go to information to ask for first or more stores
	
	
	/*reflex goToInfoEmpty when: storeEmpty and thirsty{
		
		do goto target:infoPoint speed: 3.0;
		write " store empty--> going";
		if(location distance_to(infoPoint)<2){
			write " AGENT IS AT STORE";
			 storeEmpty<-false;
			}
		
	}*/
	reflex goToPoint when: ((hungry or thirsty) and currentStore=nil) or askAgain or storeEmpty
	{
		// calc distance traveled
		x1<-location.x;
		y1<-location.y;
		//------------------------
		do goto target:infoPoint speed: 3.0;
		
		if(location distance_to(infoPoint)<2){
			storeEmpty<-false;
			//calc distance traveled
			x2<-location.x;
			y2<-location.y;
			float newDistance <-sqrt(((x2-x1)^2)+(y2-y1)^2);
			movedDistance <- movedDistance + newDistance;
			//write " guest: "+n+" moved: "+newDistance +" to infoPoint";
			write "Guest: "+n+" total distance traveled: "+movedDistance;
			//------------------------
			
			ask info at_distance 7.1
			{
				if (rnd(chance+ 30)=5) //Randomly choosen as BadAgent
				{
					write "Guest number: " + myself.n + " is declared as Bad Guest. Security Called.";
					callingGuard <- true;
					self.badAgentLocation <- myself;
					self.badGuestNumber <- myself.n;
				}
				
				if (myself.emptyStoreInfo!=nil){
					
					//to ignore duplicates
					if((!(self.emptyStores contains myself.emptyStoreInfo))){
						remove myself.emptyStoreInfo from: self.stores;
						add myself.emptyStoreInfo to:self.emptyStores;
						//keeps adding duplicates of empty stores
						write "Empty Store: " + myself.emptyStoreInfo+ " is reported and removed from Info store list, length: "+length(self.stores)+" emptyStores: "+length(self.emptyStores);
						myself.emptyStoreInfo<-nil;
					}
					
				}
				// get store location from point
			if(length(self.stores)>0){
				if(myself.askAgain){
					write "SELF.STORES" + length(self.stores);
					write "asked for another store " +myself.askAgain;
					//has to be dynamic
					myself.currentStore<-self.stores[rnd(length(self.stores)-1)];  
				}	
				else{		
					myself.currentStore<-self.stores[rnd(length(self.stores)-1)];  
					write " asked for first store";
					write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
					}
			}
			else{
				 					
				write "Food And Drink are finished at stores. Please come back later."; 					
				myself.thirsty <-false; 					
				myself.hungry <-false; 	
				light<-true;				
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
					write "already have that one";
					}
				}
				
				write "number in guest list: "+ length(currentStores);
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
				write "Guest: "+n+" total distance traveled: "+movedDistance;
				//------------------------
				ask store at_distance 2 //--------- added and edited ask
				{
				if(myself.thirsty){
				if(self.drinkAvailable>0){
					myself.thirsty<-false;
					// remove drink from store
					self.drinkAvailable <- self.drinkAvailable-1;
					
					write ""+myself.n+": went to store: " + self.n+" to eat, there were: "+drinkAvailable+"drink left";
				}
				else{
					myself.storeEmpty<-true;
					myself.emptyStoreInfo<-self.location;
					myself.currentStore<-nil;
					write "store was empty, going wandering";
					write "drink available" + self.drinkAvailable;
				}}
				else{
					if(self.foodAvailable>0){
					// remove food from store
					self.foodAvailable <- self.foodAvailable-1;
					myself.hungry<-false;
					write ""+myself.n+": went to store: " + self.n+" to eat, there were: "+foodAvailable+"food left";
					}
					else{
						myself.storeEmpty<-true;
						myself.emptyStoreInfo<-self.location;
						myself.currentStore<-nil;
						
						write "store was empty, going wandering";
						write "food available" + self.foodAvailable;
					}
				}
				
				}
				storeToGoTo<- nil;
			}
	}
	/*reflex atStorePoint when:location=currentStore{
		currentStore<-nil;
	}
	//reflex reflex_name when: condition {...}*/
	aspect base {
		draw circle(size) color: color ;
	}
} 

species dumbGuest skills: [moving] {
	float size <- 1.0 ;
	rgb color <- #orange;
	bool thirsty <-false;
	bool hungry<-false;
	store storeList;
	point currentStore;
	int n <- rnd(-10);
	point storeToGoTo;
	//traveled
	int movedDistance;
	float x1;
	float y1;
	float x2;
	float y2;
	point emptyStoreInfo;
	bool storeEmpty;
	
	bool hungryOrThirsty<-true;
	
	bool beingKilled<-false;
	
	reflex die when: beingKilled  {
		do die ;
	}
		
	reflex beIdle when: hungry=false and thirsty=false
	{
		//write "went idle: "+n;
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
		}
	}
	// go to information to ask for store
	reflex goToPoint when: ((hungry or thirsty) and currentStore=nil)
	{
		// calc distance traveled
		x1<-location.x;
		y1<-location.y;
		//------------------------
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			//calc distance traveled
			x2<-location.x;
			y2<-location.y;
			float newDistance <-sqrt(((x2-x1)^2)+(y2-y1)^2);
			movedDistance <- movedDistance + newDistance;
			//write "Dumb guest: "+n+" moved: "+newDistance +" to infoPoint";
			write "DumbGuest: "+n+" total distance traveled: "+movedDistance;
			//------------------------
			ask info at_distance 7.1
			{
				if (rnd(chance + 30) =5) //Randomly choosen as BadAgent
				{
					write "Guest number: " + myself.n + " is declared as Bad Guest. Security Called.";
					callingGuard <- true;
					self.badAgentLocation <- myself;
					self.badGuestNumber <- myself.n;
				}
				if (myself.emptyStoreInfo!=nil){
						//to ignore duplicates
					if((!(self.emptyStores contains myself.emptyStoreInfo))){
						write "stores length "+ length(stores);
						remove myself.emptyStoreInfo from: self.stores;
						
						add myself.emptyStoreInfo to:self.emptyStores;
						//keeps adding duplicates of empty stores
						write "Empty Store: " + myself.emptyStoreInfo+ " is reported and removed from Info store list, length: "+length(stores)+" emptyStores: "+length(emptyStores);
						myself.emptyStoreInfo<-nil;
					}
					}
				if(length(self.stores)>0){
					write "currentStore: "+myself.currentStore+" length stores: "+length(stores);
					int rand <-rnd(length(self.stores)-1);
					myself.currentStore<-self.stores[rand]; 
					//write "all stores are empty. waiting in Info Desc";
				}
				else{ 					
					write "Food And Drink are finished at stores. Please come back later."; 					
					myself.thirsty <-false; 					
					myself.hungry <-false;
					light<-true; 					
					//myself.askAgain<-false; 	
				}	
				write " asked for store";
				write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
		}
	}
	}
	// after we got the location of a store
	reflex goToStore when: (hungry or thirsty) and currentStore!=nil{
			
			if(storeToGoTo=nil){
				//pick a random store from known to go to
				storeToGoTo<-currentStore;
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
				//write " Dumb guest: "+n+" moved: "+newDistance +" to store";
				write "DumbGuest: "+n+ " total distance traveled: "+movedDistance;
				//------------------------
			/* ask store at_distance 2 //--------- added and edited ask
				{
					
					if(myself.thirsty){
						myself.thirsty<-false;
						self.drinkAvailable <-self.drinkAvailable-1;
						write ""+myself.n+": went to store: " + myself.storeToGoTo+" to drink, there were: "+drinkAvailable+" drinks left";
						}
					else{
						myself.hungry<-false;
						self.foodAvailable <-self.foodAvailable-1;
						write ""+myself.n+": went to store: " + myself.storeToGoTo+" to eat, there were: "+foodAvailable+"food left";
					}*/
					ask store at_distance 2 //--------- added and edited ask
				{
					
					if(myself.thirsty){
						if(self.drinkAvailable>0){
						myself.thirsty<-false;
						self.drinkAvailable <-self.drinkAvailable-1;
						write ""+myself.n+": went to store: " + myself.storeToGoTo+" to drink, there were: "+drinkAvailable+" drinks left";
						}
						else{
							
							myself.emptyStoreInfo<-self.location;
							myself.currentStore<-nil;
							myself.storeEmpty<-true;
							
							write "store was empty, going wandering";
							write "drink NOT available!";
						}
					}
					else{
					if(self.foodAvailable>0){
					// remove food from store
						self.foodAvailable <- self.foodAvailable-1;
						myself.hungry<-false;
						write ""+myself.n+": went to store: " + self.n+" to eat, there were: "+foodAvailable+"food left";
					}
					else{
						myself.emptyStoreInfo<-self.location;
							myself.currentStore<-nil;
							myself.storeEmpty<-true;
						write "store was empty, going wandering";
						write "food NOT available!";
						}
						
					}		
				myself.storeToGoTo<-nil;	
				myself.currentStore<-nil;
				}	
	}}
	aspect base {
		draw circle(size) color: color ;
	}
}
species festivalWorker skills: [moving]{
	float size <- 2.0 ;
	rgb color <- #purple;
	point storeToGoTo<-nil;
	bool delivered<-false;
	
	reflex calledToInfo when:light and storeToGoTo = nil{
		
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				write "WORKER is called by Info!";
				//get first empty in list and remove it
				if (length(self.emptyStores)>0){
					write "Number of empty stores = "+length(self.emptyStores);
					myself.storeToGoTo<-first(self.emptyStores);
					write "Going to store "+ myself.storeToGoTo + " to Fill Inventory";
					//remove myself.storeToGoTo from: self.emptyStores;
					//add myself.storeToGoTo to: self.stores;
					self.handled<-false;
					//light<-false;
				}
			}
		}
	}
	reflex goToStore when: storeToGoTo!=nil and light{
		do goto target:storeToGoTo speed: 3.0;
	
		if(location distance_to(storeToGoTo)<2){
			write "Worker is going to Store to fill up supplies";
			ask store at_distance 2
			{ 
				self.foodAvailable<-3;
				self.drinkAvailable<-3;
			}
			storeToGoTo<-nil;
			delivered<-true;
			
			}
	}
	reflex reportToInfo when:delivered{
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				add myself.storeToGoTo to:self.stores;
				remove myself.storeToGoTo from: self.emptyStores;
				 myself.storeToGoTo<-nil;
				myself.delivered<-false;
				light<-false;
			}}
	

	}
	reflex idle when: !light{
		do wander;
		
	}
	
	aspect base {
		draw circle(size) color: color ;
	}
}
}
experiment main type: gui {
	parameter "Initial number of guests: " var: guests_init min: 1 max: 1000 category: "Guests" ;
	parameter "Initial number of dumb guests: " var: dumb_guests_init min: 1 max: 1000 category: "Guests" ;
	output {
		display main_display {
			species guest aspect: base ;
			species info aspect: base;
			species store aspect: base;
			species dumbGuest aspect: base;
			species festivalWorker aspect: base;
			species securityGuard aspect: base;
		}
	}
}
// add Shakhroms code
// add ask to guest (info and store)¨

//---- Creative

// add same kind of food and drink handling in uest as in dumb guest
// do something when food/ drink runs out