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
	int info_init<-1;
	int stores_init<-4;
	
	point infoPoint<-{50,50};
	int chance <- 20;
	int anotherStoreChance<-2;
	list<point> storesGlobal;
	
	init {
		create guest number: guests_init ;
		create info number: info_init
		{ 
  			location <- {50,50};
  			
		}
	
		create store number: stores_init{
			point p <-{rnd(50),rnd(50)};
			location<-p;
			add location to:storesGlobal;
		}
		
}
species info{
	int size<-3;
	rgb color <-#red;
	list<point> stores <- storesGlobal;
	
 aspect base {
		draw square(size) color: color ;
	}
}
species store{
	int size <-3;
	rgb color<-#green;
	aspect base {
		draw square(size) color: color ;
	}
}
species guest skills: [moving] {
	float size <- 1.0 ;
	rgb color <- #blue;
	bool thirsty <-false;
	store storeList;
	point currentStore;
	list<point> currentStores; //list of all stores guest knows of
	int n <- rnd(100);
	bool askAgain <- false;
	bool going <-false;
	point storeToGoTo;
		
	reflex beIdle when: thirsty=false
	{
		//write "went idle: "+n;
		do wander;
		
		if(rnd(chance)=1){
			//get thirsty
			thirsty<-true;
			going<-false;
			//possibly ask for a new store
			if((rnd(anotherStoreChance)=1) and currentStore !=nil){
				askAgain <- true;
				write " askAgain "+askAgain +" name: "+n;
			}
		}
		
	
	}
	// go to information to ask for first or more stores
	reflex goToPoint when: (thirsty=true and currentStore=nil) or askAgain
	{
		
		do goto target:infoPoint speed: 3.0;
		
		if(location distance_to(infoPoint)<2){
			
			if(askAgain){
				write "asked for another store " +askAgain;
				currentStore<-storesGlobal[rnd(stores_init-1)]; 
				
			}	
			else{		
				currentStore<-storesGlobal[rnd(stores_init-1)]; 
				write " asked for first store";
				write "I am going to store at: "+currentStore + " name: "+ n;
			}
			//remeber it
		
			loop i from: 0 to: length(currentStores) -1 {
				
				if((!(currentStores contains currentStore))){
					if(length(currentStores)<stores_init){
						add currentStore to:currentStores;
					}
				}
				
				else{
					write "already have that one";
				}
				write "number in guest list: "+ length(currentStores);
				write "number of stores to choose from: " +length(storesGlobal);
				//write "my currentstores: "+currentStores[i];
			}
			
			
			askAgain<-false;
		}
		
	
	}
	
	/*reflex goAskForAnother when: thirsty=true and currentStore!=nil and (rnd(anotherStoreChance)=1)
	{
		
	}*/
	/*reflex atPoint when: thirsty=true and currentStore=nil{
		//if(myself.location){}
		ask info at_distance 7.1
		{
			myself.thirsty<-false; // TODO , fix this we want it to happen in store
			myself.currentStore<-storesGlobal[rnd(stores_init-1)]; // TODO , fix this we want it to select a random one
			write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
			
		}
		
	}*/// gets confused and goes towards different points since it triggers several 
	// after we got the location of a store
	reflex goToStore when: thirsty=true and currentStore!=nil and !askAgain{
			
			if(storeToGoTo=nil){
				//pick a random store from known to go to
				storeToGoTo<-currentStores[rnd(length(currentStores)-1)];
			}
			
			do goto target:storeToGoTo speed: 3.0;
			if(location distance_to(storeToGoTo)<2){
				thirsty<-false;
				write ""+n+": went to store: " + storeToGoTo;	
				storeToGoTo<-nil;
				
				
			}
		
		
		
	}
		
	
	/*reflex atStorePoint when:location=currentStore{
		currentStore<-nil;
	}
	//reflex reflex_name when: condition {...}*/
	aspect base {
		draw circle(size) color: color ;
	}
} }



experiment main type: gui {
	parameter "Initial number of preys: " var: guests_init min: 1 max: 1000 category: "Prey" ;
	output {
		display main_display {
			species guest aspect: base ;
			species info aspect: base;
			species store aspect: base;
		}
	}
}
//
