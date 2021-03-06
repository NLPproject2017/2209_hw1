/**
* Name: main
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model main
// first assignment
import "ThirstyGuest.gaml"
import "store.gaml"
import "festivalWorker.gaml"
import "securityGuard.gaml"
import "infodesk.gaml"
import "Auctioneer.gaml"
import "participant.gaml"
import "Criminal.gaml"

//import "stage.gaml"
//import "onemore.gaml"

global {
	//image stores
	file infoIMG <- image_file("../../images/info.png");
	
	//Thirsty guests, stores, infopoint, guard
	int guests_init <- 50;
	int info_init<-1;
	int stores_init<-4;
	int workers_init<-2;
	int auctioneers_init<-1;
	int participants_init<-1;
	int criminals_init<-1;
	
	point infoPoint<-{50,50};
	
	list<point> storesGlobal_init <- [{10,10}, {10,80}, {80,10}, {80,80}];
	list<point> storesGlobal; 
	bool callingGuard <-false;
	bool light<-false; //light is turned on when info center wants the worker to come
	
	//auctioneer
	list<list> thingsForSale<-[['Phone', 'Personal'],['TV', 'HouseholdItems'],['Car', 'HouseholdItems'],['Watch', 'Personal']];
	list<string> categories<-['Personal','HouseholdItems'];
	list festivalWorkers;
	
	
	//Monitor: 
	int nb_people_agitated_init<-0;
	int current_hour update: (cycle / 60) mod 24;
	int nb_people_agitated <- nb_people_agitated_init update: guest count (each.isAgitated);
	int nb_people_alive <-  guests_init update: guest count (each.alive);
	//int nb_people_not_infected <- nb_people - nb_infected_init update: nb_people - nb_people_infected;
	float agitation_rate update: nb_people_agitated/guests_init;
	
	
	init {
		
		create guest number: guests_init{
			//for challenge part
			int index <- rnd(1,2);
			starterBadChance<-rnd(70,100);
			add categories[index-1] to: interestedCategories;
			resilience <- rnd(1); // 0 is non-resilient 1 is resilient
			if(resilience){
				chance<-40; // less likely to get thirsty or hungry
			}
			else{
				chance <-20;
			}
			loop i over: thingsForSale{
				if (interestedCategories contains i[1]){
					list willingBuyItem<- [i[0], 200 + rnd(300)];
					add willingBuyItem to: interestedToBuyItems;
				}
			}
			//write name + " interested categories: "+ interestedCategories +" and willing to buy items:" + interestedToBuyItems;
		}
		create Criminal number: criminals_init{
			// some are faster than others
			speed<-rnd(4);
			if(rnd(1)=1){
				nice <- true;
				color<-#pink;
			}
			else{
				nice<-false;
				color<-#red;
			}
			strength <-rnd(100);
			if((strength<50)){
				weak<-true;
			}
			else{
				weak<-false;
			}
			
		}
		create securityGuard number: 1 {
			if(rnd(1)=1){
				newAtWork <- true;
				color<-#cyan;
			}
			else{
				newAtWork<-false;
				color<-#cyan;
			}
			fitnessLevel<-rnd(100);
			if(fitnessLevel<50){
				speed<-1.0;
			}
			else{
				speed<-3.0;
			}
			int patienceLevel<-rnd(2);
			if(patienceLevel=1){
				patient<-true;
			}
			else{
				patient<-false;
			}
			
		}
		create store number: stores_init{
			
			//point p <-{rnd(75),rnd(75)};
			point p <- first(storesGlobal_init);
			location<-p;
			remove location from:storesGlobal_init;
			add location to:storesGlobal;
			foodAvailable <- 10; //--------------
  			drinkAvailable<-15; //--------------
  			n<-"Store "+rnd(stores_init); //---------
		}
		
		create festivalWorker number: workers_init{
			customName<-rnd(1000);
			energyLevel<-rnd(50,100); // some people have less energy than others
			energyStartValue<-energyLevel; // to remember our energy after depletion
			energyRegeneration<-1; 
			int strength<-rnd(10);
			AgitationLevel<-rnd(100);
			add customName to: festivalWorkers; // save employees
			if(strength>6){
				strong<-true;
			}
			else{
				strong<-false;
			}
		}
		create info number: info_init
		{ 
			list createEmployedWorkers;
			loop i over: festivalWorkers{
				add 0 to: workerWarnings;
			}
			employedWorkers<-festivalWorkers;
  			location <- {50,50};
  			stores<-storesGlobal;
		}
		create Auctioneer number: auctioneers_init {
			n<-'Auctioneer '+rnd(100);
			
			generousity<-rnd(10);
			
			if(rnd(2)=1){
				charitable <- true;
			}
			
			if(rnd(2)=1){
				encouraging <- true;
			}
			
			int index <- rnd(1,2);
			add categories[index-1] to: selectCategories;
			
			sellingItems<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
			list<list> sellingItems_copy<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
			loop i over: sellingItems_copy{
				if (!(selectCategories contains i[3])){
					remove i from: sellingItems;
					}
				}
			//write name + " categories:" + selectCategories + "Items:" + sellingItems;
			
		}
		/*create Participant number: participants_init {
			//for challenge part
			int index <- rnd(1,2);
			add categories[index-1] to: interestedCategories;
				
			loop i over: thingsForSale{
				if (interestedCategories contains i[1]){
					list willingBuyItem<- [i[0], 200 + rnd(300)];
					add willingBuyItem to: interestedToBuyItems;
				}
			}
			//write name + " interested categories: "+ interestedCategories +" and willing to buy items:" + interestedToBuyItems;
		}*/
		
		//End the experiment after 3 days (1 minut = 1 cycle) = 4320
		
}
aspect base {
		draw ' Number of guests in field: ' + length(guest) at: {0,0} color: #purple size: 12;
	}
	
	reflex end_experiment when: cycle=4320{
		write "experiement ended";
		do pause;
		}
}
experiment main type: gui {
	parameter "Guests: " var: guests_init min: 1 max: 100 category: "Guests" ;
	parameter "Stores: " var: stores_init min: 1 max: 10 category: "Stores" ;
	parameter "Workers: " var: workers_init min: 1 max: 10 category: "Workers" ;
	
	output {
		
		monitor "Number of guests alive" value: nb_people_alive;
		monitor "Current hour" value: current_hour;
		monitor "Agitation rate" value: agitation_rate;
		
		
		display chart refresh:every(20) {
			chart "Monitoring of agitated guests over time:" type: series {
				//data "Numer of people Alive: " value: nb_people_alive color: #blue;
				//data "Numer of people agitated: " value: nb_people_agitated color: #green;
				data "Agitation rate" value: agitation_rate color: #red;
			}
			
//			chart "Monitoring of agitated guests over time:" type: series
//			{
//			//data "Numer of people Alive: " value: nb_people_alive color: #blue;
//			//data "Numer of people agitated: " value: nb_people_agitated color: #green;
//				data "Agitation rate" value: agitation_rate color: # red;
//			}
		}
		
//		display chart refresh:every(20) {
//			
//			chart "Monitoring of agitated guests over time:" type: series {
//				//data "Numer of people Alive: " value: nb_people_alive color: #blue;
//				//data "Numer of people agitated: " value: nb_people_agitated color: #green;
//				data "Agitation rate" value: agitation_rate color: #red;
//			}
//		}
			display main_display background:#white {
			
			species securityGuard aspect: base;
			species guest aspect: base ;
			species info aspect: base;
			species store aspect: base;
			species festivalWorker aspect: base;
			
			species Auctioneer aspect: base ;
			species Criminal aspect: base ;
			
			graphics "layer1" {
                draw 'Guests in field: '+length(guest) at:{5,5} color:#cornflowerblue;
                
            }
		}
	}
}


/*
 1. Create at least 5 different types of moving agents. 
 -guest, securityGuard, festivalworker, auctioneer, Criminal
 2. Use at least 50 agents in your scenario. (Guest, Auctioneer, BadGuest, Security etc...)
 3. The agents have at least 1 different set of rules on how they interact with other types. (Security guard meeting bad person)
 - Guest: asks info for store locations, gets food and drink from stores // DONE can be bad depending on different factors (ex criminal) // DONE
 - SecurityGuard: when interacting with a bad guest it will kill him (or warn) and it can interract with the info centre // DONE
 - FestivalWorker: Interracts with the info centre and the stores // DONE
 - Auctioneer: interracts with guests and securityGuard // DONE
-  Criminal, has bad influence on guests // DONE and interracts with security guard // DONE 

4. They also have at least 3 personal traits that affect these rules.(How hungry/thirsty they are, if they like band or speakers...)
 - Guest: hunger/thirst //DONE, interested to buy categories, //DONE chill/party person, (if they like theband/stage-specs) <- dont know about this.. // TODO
 - SecurityGuard: (if newguy) doesnt want to decide for itself, doesnt chase criminals // DONE fitness-level a slow guard wont catch the bad guests // DONE , patience-level the guard may give the guest a warning instead of killing him // DONE
 - FestivalWorker: (energetic ?)energy-level if he gets tired he has to rest (DONE), can fill with more (strong) // TODO and change, aggitation, if it behaves badly it can get fired by the security guard // TODO
 - Auctioneer: merchant interest buys back some  things if it is interested // TODO, cash plan affects purchases and sales, // TODO depending on the generosity the min sell price can drop (subtracts more or less when dropping price)// DONE  TODO ( might want to rethink these too)
-  Criminal, if nice will only have bad influence on guests not rob stores // DONE if weak, will only rob what it can carry // DONE one more thing //TODO

 5. Have at least 2 different types of places where agents can meet, not including roaming (Bar, Stage...)
 - stores // DONE
 (- info centre) // DONE
 - stage // if we use this.. // TODO
 6. Make the simulation run over a total of 3 days (e.g. 1 minute = 1 cycle) // TODO and fix so that everything has a good rate.. (i.e nt everyone is killed by guard hour 1)
 7. Agent communicate with FIPA for long distance messaging but can use ask in close range. // DONE
- for auctioneer
*/