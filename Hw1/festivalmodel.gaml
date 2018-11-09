/**
* Name: festivalmodel
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model festival

global {
	int guests_init <- 10;
	int info_init<-1;
	int stores_init<-4;
	
	point infoPoint<-{50,50};
	int chance <- 100;
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
	int n <- rnd(100);
		
	reflex beIdle when: thirsty=false
	{
		do wander;
		if(rnd(chance)=1){
			//get thirsty
			thirsty<-true;
		}
	}
	reflex goToPoint when: thirsty=true and currentStore=nil
	{
		do goto target:infoPoint speed: 3.0;
		if(location distance_to(infoPoint)<2){
			
			currentStore<-storesGlobal[rnd(stores_init-1)]; 
			write "I am going to store at: "+currentStore + " name: "+ n;
		}
	
	}
	/*reflex atPoint when: thirsty=true and currentStore=nil{
		//if(myself.location){}
		ask info at_distance 7.1
		{
			myself.thirsty<-false; // TODO , fix this we want it to happen in store
			myself.currentStore<-storesGlobal[rnd(stores_init-1)]; // TODO , fix this we want it to select a random one
			write "I am going to store at: "+myself.currentStore + " name: "+ myself.n;
			
		}
		
	}*/
	// after we got the location of a store
	reflex goToStore when: thirsty=true and  currentStore!=nil{
		//write "guest going to store: " + currentStore;
		
		do goto target:currentStore speed: 3.0;
		if(location distance_to(currentStore)<2){
			thirsty<-false;
			currentStore<-nil;
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
