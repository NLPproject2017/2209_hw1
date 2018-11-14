/**
* Name: festivalmodel
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/
//testing 
model festival

global {
	int guests_init <- 10;
	int dumb_guests_init <-2;
	int info_init<-1;
	int stores_init<-1;
	
	point infoPoint<-{50,50};
	int chance <- 20;
	int anotherStoreChance<-2;
	list<point> storesGlobal;
	
	init {
		create guest number: guests_init ;
		create dumbGuest number: dumb_guests_init;
		create store number: stores_init{
			point p <-{rnd(75),rnd(75)};
			location<-p;
			add location to:storesGlobal;
			foodAvailable <- 10; //--------------
  			drinkAvailable<-20; //--------------
  			n<-"Store "+rnd(stores_init); //---------
		}
		create info number: info_init
		{ 
  			location <- {50,50};
  			stores<-storesGlobal;
		}
		
}
species info{
	int size<-3;
	rgb color <-#red;
	list<point> stores;

	
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
	
	bool storeEmpty<-false;
	
	bool hungryOrThirsty<-true;
		
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
	reflex goToPoint when: ((hungry or thirsty) and currentStore=nil) or askAgain //or storeEmpty
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
			//write " guest: "+n+" moved: "+newDistance +" to infoPoint";
			write "Guest: "+n+" total distance traveled: "+movedDistance;
			//------------------------
			
			ask info at_distance 7.1
			{
			if(myself.askAgain){
				write "asked for another store " +myself.askAgain;
				myself.currentStore<-self.stores[rnd(stores_init-1)];  
				
			}	
			else{		
				myself.currentStore<-self.stores[rnd(stores_init-1)];  
				write " asked for first store";
				write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
			}
			
			}
			//remeber it
		
			//loop i from: 0 to: length(currentStores) -1 {
				
				//if we already know about all stores
				if((!(currentStores contains currentStore))){
					if(length(currentStores)<=stores_init){
						add currentStore to:currentStores;
					}
					}
				else{
					write "already have that one";
				}
				write "number in guest list: "+ length(currentStores);
				write "number of stores to choose from: " +length(storesGlobal);
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
				//if(self.drinkAvailable>0){
					myself.thirsty<-false;
					// remove drink from store
					self.drinkAvailable <- self.drinkAvailable-1;
					
					write ""+myself.n+": went to store: " + myself.storeToGoTo+" to eat, there were: "+drinkAvailable+"drink left";
				
				/*else{
					myself.storeEmpty<-true;
					write "store was empty, going wandering";
					write "drink available" + self.drinkAvailable;
				}*/}
				else{
					// remove food from store
					self.foodAvailable <- self.foodAvailable-1;
					myself.hungry<-false;
					write ""+myself.n+": went to store: " + myself.storeToGoTo+" to eat, there were: "+foodAvailable+"food left";
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
	
	bool hungryOrThirsty<-true;
		
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
				myself.currentStore<-self.stores[rnd(stores_init-1)]; 
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
				ask store at_distance 2 //--------- added and edited ask
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
					}	
				myself.storeToGoTo<-nil;	
				myself.currentStore<-nil;
				}	
	}}
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
		}
	}
}
// add Shakhroms code
// add ask to guest (info and store)¨

//---- Creative

// add same kind of food and drink handling in uest as in dumb guest
// do something when food/ drink runs out