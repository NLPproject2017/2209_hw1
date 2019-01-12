/**
* Name: infodesk
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model infodesk
import "main.gaml"

species info{
	int size<-3;
	rgb color <-#red;
	list<point> stores;
	list<point> emptyStores;
	bool busy<-false;
	
	int badGuestNumber;
	list badGuests;
	list employedWorkers;
	list<int> workerWarnings;
	
	//request festivalworker to fill inventories when one is empty
	reflex requestFillStores when: !(length(emptyStores)=0){
		light<-true;
		//write name + ' stores in need of supplies: '+emptyStores;
	}
	//request festivalworker to fill inventories when one is empty
	reflex noStoresNeed when: (length(emptyStores)=0){
		light<-false;
	}
	reflex allStoresEmpty when: length(emptyStores)=stores_init{
		write "Food And Drink are finished at stores. Please come back later."; 	
	}
	reflex guestsInViewingDistance when: !empty(guest at_distance 7) {
		// if we see a guest do something bad, call security
		list glist<-guest at_distance 7;
		loop g over: glist{
			ask g
			{
				// guests are red when they do something bad
				if(self.color=#red and !(myself.badGuests contains g)){
					callingGuard <- true;
					
					add g to: myself.badGuests;
				}
			}
		}
	}
	// give info to guard when he is close
	reflex giveGuestInfoToGuard when: !empty(securityGuard at_distance 2){
				
	list securitylist<-securityGuard at_distance 2;
		loop s over: securitylist{
			agent badGuest<-first(badGuests);
			ask s
			{		
					if(self.badAgent=nil){
						//write 'guests in list: '+ myself.badGuests;
						//write 'gave bad guestinfo to guard';
						self.badAgent<-badGuest;
					}	
			}
			remove badGuest from: badGuests;
			//write ' after remove, bad guests left in list: '+ badGuests;
		}
	}
	reflex badGuestsNeedHandling when: !empty(badGuests){
		callingGuard <- true;
	}
	reflex noBadGuestsNeedHandling when: empty(badGuests){
		callingGuard <- false;
	}
	
	reflex badWorker when: !empty(festivalWorker at_distance 3){ // when we see an agitated festival worker
	
		ask festivalWorker at_distance 1{
			if(self.Agitated){
				write 'AGITATED WORKER IN RANGE!!!!!!!!!!!!!';
				//write 'Number of employed workers: ' + length(festivalWorkers);
					int counter<-0;
					loop workerName over: myself.employedWorkers{
						
						//write '';
						//write 'self.customName ' + self.customName + ' VS ' + workerName;
						//write '';
						if(workerName=self.customName){ // if current worker in list is the agitated one
						write 'FOUND WORKER IN MY LIST!!!!!!!!!!!!!';
							//loop warnings over: workerWarnings{
							write ' counter: ' + counter + ' Value: ' + myself.workerWarnings[counter];
								if(myself.workerWarnings[counter]>=3){ // if it already received 3 warnings
								write '!!             FIRED WORKER               !!';
									self.alive<-false; // fire it
									myself.workerWarnings[counter]<--1; // i.e dead
								}
								else if(myself.workerWarnings[counter]<3 and myself.workerWarnings[counter]>=0){
									// give warning
									myself.workerWarnings[counter]<-myself.workerWarnings[counter]+1; // keep track myself
									self.receivedWarnings<-self.receivedWarnings+1;
									write 'GAVE WARNING TO WORKER!!!!!!!!!!!!';
								}
							//}
						}
						counter<-counter+1;
					}
				
			}
		}
	}
		
	/*reflex requestAWorker when: (length(emptyStores)>0)// and !handled{
	{
		light<-true;
		handled<-true;
	}*/

	
 aspect base {
		draw square(size) color: color ;
		point firstOne <-first(emptyStores);
		draw 'Empty stores: ' at: location+{-2,4} color: #black;
		
		//draw location at:  location+{2,-4} color: #black;
		int i<-0;
		loop tmpstore over: emptyStores{
			i<-i+2;
			point tempLoc <- location+{-2,4+i};
			draw ''+tmpstore at: tempLoc color: #black;
		}
		
	}
}

