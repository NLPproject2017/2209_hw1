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

//import "stage.gaml"
//import "onemore.gaml"

global {
	//Thirsty guests, stores, infopoint, guard
	int guests_init <- 10;
	int info_init<-1;
	int stores_init<-4;
	int workers_init<-1;
	int auctioneers_init<-1;
	int participants_init<-1;
	
	point infoPoint<-{50,50};
	
	list<point> storesGlobal;
	bool callingGuard <-false;
	bool light<-false; //light is turned on when info center wants the worker to come
	
	//auctioneer
	list<list> thingsForSale<-[['Phone', 'Personal'],['TV', 'HouseholdItems'],['Car', 'HouseholdItems'],['Watch', 'Personal']];
	list<string> categories<-['Personal','HouseholdItems'];
	
	init {
		create guest number: guests_init{
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
		}
		create securityGuard number: 1 ;
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
		create festivalWorker number: workers_init{
			energyLevel<-100;
			energyRegeneration<-1;
		}
		create Auctioneer number: auctioneers_init {
			n<-'Auctioneer '+rnd(100);
			
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
		
		
}
}
experiment main type: gui {
	parameter "Guests: " var: guests_init min: 1 max: 100 category: "Guests" ;
	parameter "Stores: " var: stores_init min: 1 max: 10 category: "Stores" ;
	parameter "Workers: " var: workers_init min: 1 max: 10 category: "Workers" ;
	
	output {
		display main_display {
			species guest aspect: base ;
			species info aspect: base;
			species store aspect: base;
			species festivalWorker aspect: base;
			species securityGuard aspect: base;
			species Auctioneer aspect: base ;
			// make into guest
			//species Participant aspect: base ;
		}
	}
}


/*
 1. Create at least 5 different types of moving agents. 
 -guest, securityGuard, festivalworker, auctioneer
 2. Use at least 50 agents in your scenario. (Guest, Auctioneer, BadGuest, Security etc...)
 3. The agents have at least 1 different set of rules on how they interact with other types. (Security guard meeting bad person)
 - Guest: asks info for store locations, gets food and drink from stores // DONE
 - SecurityGuard: when interacting with a bad guest it will kill him and it can interract with the info centre // DONE
 - FestivalWorker: Interracts with the info centre and the stores // DONE
 - Auctioneer: interracts with guests and securityGuard
-  onemore, 

4. They also have at least 3 personal traits that affect these rules.(How hungry/thirsty they are, if they like band or speakers...)
 - Guest: hunger/thirst //DONE, interested to buy categories, chill/party person, (if they like theband/stage-specs)
 - SecurityGuard: fitness-level a slow guard wont catch the bad guests, patience-level the guard may give the guest a warning instead of killing him, energy-level if he gets tired he has to rest
 - FestivalWorker: energy-level if he gets tired he has to rest (DONE), if not busy will volonteer for stage work, aggitation, if it behaves badly it can get fired by the security guard
 - Auctioneer: merchant interest buys back some  things if it is interested, cash plan affects purchases and sales, depending on the generosity the min sell price can drop
-  onemore

 5. Have at least 2 different types of places where agents can meet, not including roaming (Bar, Stage...)
 - stores
 (- info centre)
 - stage
 6. Make the simulation run over a total of 3 days (e.g. 1 minute = 1 cycle) 
 7. Agent communicate with FIPA for long distance messaging but can use ask in close range. 
- for auctioneer
*/