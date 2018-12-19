
model festival
import "main.gaml"

species guest skills: [fipa,moving] {
	//Participant
	list<list> interestedToBuyItems;
	list<string> interestedCategories;
	string proposedItem;
	int proposedPrice;
	int willingPrice;
	bool sold<-false;
	
	bool goingToAuction<-false;
	bool atAuction<-false;
	point auctionLocation<-nil;
	//flyttar ihop guest och participant
	//---
	float size <- 1.0 ;
	rgb color<-#blue;
	
	store storeList;
	
	point currentStore;
	point storeToGoTo;
	
	list<point> currentStores; //list of all stores guest knows of
	
	int chance <- 20;
	int anotherStoreChance<-2;
	int n <- rnd(100);
	int warnings<-0;
	int badChance <-70;

	bool thirsty <-false;
	bool hungry<-false;
	bool askAgain <- false;
	bool going <-false;
	bool knowAll <-false;
	bool storeEmpty<-false;
	bool hungryOrThirsty<-true;
	bool alive<-true;
	bool isPushed<-false;
	bool isAgitated<-false;
	bool alreadyAgitated<-false;
	
	bool busyFOOD<-false; // controls so that not two different events can happen at the same time, auctions/go to a store
	bool busyAuction <- false;
	//TRAVELED
	int movedDistance;
	float x1;
	float y1;
	float x2;
	float y2;
	point emptyStoreInfo;
	
	reflex die when: !alive  {
		write 'Guest: ' + name + 'I died';
		do die ;
	}
		
	reflex beIdle when: !thirsty and !hungry and !busyAuction
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
	reflex randomlyBeBad{
		// if info sees me i will be killed by guard
		if (rnd(chance+ badChance)=5)
		{					
			color<-#red;
		}
		else if(color=#green and !busyAuction){
			color<-#blue;
			busyFOOD<-true;
		}
		else if(busyAuction){
			color<-#green;
		}
	}
	// RELATED TO interactions at the info centre
	// if pushed get agitated and increase how likely we are to go bad
	reflex getAgitated when: isPushed and !alreadyAgitated{
		isAgitated<-true;
		isPushed<-false;
	}
	reflex agitated when: isAgitated{
		
		if(!alreadyAgitated){
			badChance<-5;
			color<-#cyan;
			alreadyAgitated<-true;
		}
		// stop being agitated after a random amount of time
		if(rnd(50)=25){
			isAgitated<-false;
			color<-#blue;
			alreadyAgitated<-false;
			badChance<-70;
		}
	}
	//reflex gotBadInfluence when: 
	// RELATED TO HUNGER/THIRST
	reflex notHungryThirstyAnymore when: !hungry and !thirsty and !busyAuction{
		busyFOOD<-false;
	}
	reflex goToPoint when: (((hungry or thirsty) and currentStore=nil) or askAgain or storeEmpty) and !busyAuction
	{
		busyFOOD<-true;
		// hunger/Thirst color
		color<-#blue;
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
			
			// interact with other guests if they are there // push them if you are bad
			if(!empty(guest at_distance 10)){ //and color=#red){
				loop g over: guest at_distance 10{
					//useElbows
					ask g{
						if(!self.isPushed){
							write self.name + ' PUSHED ' + myself.name;
							self.isPushed<-true;
							myself.isPushed<-true;
						}
					}
				}
			}
			
			ask info at_distance 7.1
			{
				
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
	reflex goToStore when: (hungry or thirsty) and currentStore!=nil and !askAgain and !busyAuction{
			
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
	// RELATED TO AUCTIONS
	// triggered when auction was canceled because of low price
	/*reflex auctionAnouncements when: !empty(informs) and atAuction{
		message informFromAuctioneer <-(informs at 0);
		if(informFromAuctioneer.contents[3]='start'){
		write name +'auctionAnouncements';
		sold<-true;
				// auction ended
				atAuction<-false;
				busyAuction<-false;
				write name + 'left auction';
	}
	
	}*/
	reflex joinOrNot when: !empty(informs) and !goingToAuction and !busyAuction{
		write name +'joinOrNot';
		message informFromAuctioneer <-(informs at 0);
		if(informFromAuctioneer.contents[3]='start'){
			sold<-false;
			busyAuction<-true;
			
			
			if (interestedCategories contains informFromAuctioneer.contents[1]){
				busyFOOD<-false;
				write name +'1. respond_to_inform: joining';
				do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
				
				// save to go, we are interested
				auctionLocation <- informFromAuctioneer.contents[2];
				//write " Location " + auctionLocation;
				goingToAuction<-true;
				// if not busy, can do other things
			} else
			{
					write name +'1. respond_to_inform: NOT joining';
				do inform with: [message:: informFromAuctioneer, contents:: ['I reject, not in my interest']];
				//busy with auction stuff
				
				busyAuction<-false;
			}	
		}
		
		}
		reflex goToAuction when: goingToAuction and !busyFOOD{
			write name + ' 1.2 going to auction';
			do goto target:auctionLocation speed: 3;
			if(location distance_to auctionLocation<3){
				//write name + ' 1.3 Arrived at auction';
				goingToAuction<-false;
				atAuction<-true;
			}
		}
		reflex respond_to_proposal when: !empty(cfps) and atAuction and !busyFOOD{
			write name + 'responded to proposal of price to buy item';
			message proposalFromAuctioneer<- cfps at 0;
			
			proposedItem <- proposalFromAuctioneer.contents[1];
			proposedPrice <- proposalFromAuctioneer.contents[3];
			if(!(proposedItem='auction over')){

			loop interestItem over: interestedToBuyItems {
				if (interestItem[0] = proposedItem)
				{
					
					willingPrice <- interestItem[1];
					write name + "I'm interested in that item for price: "+ willingPrice;
				}
			}
				// it does this twice and gets out of sync...
			if (willingPrice>=proposedPrice){
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I agree to buy it ' + proposedItem + ' from ' +proposalFromAuctioneer.sender + '  for Price:', proposedPrice, name, 'I buy']];
				write name + "I will buy it for that price!";
			} 
			else{
				//do refuse with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy it. Willing To buy:', willingPrice]];
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy ' + proposedItem + ' from ' +proposalFromAuctioneer.sender + '. Willing To buy it for:', willingPrice, name, 'cant buy']];
				write name + "That is too much...";
			}
		}else{
			sold<-true;
					// auction ended
					busyAuction<-false;
					atAuction<-false;
					write name + 'left auction price too low';
		}
		}
		
		reflex receive_accept_proposals when: !empty(accept_proposals) and !sold and !busyFOOD and busyAuction{
			message m <-accept_proposals at 0; // needs to be emptied
			string contentsOne <- m.contents[1];
			write name + '!receive_accept_proposals';
			write name + '! ' +contentsOne ;
			if(contentsOne='winner'){
				write name + " said: Hurray, I bought item it from " + m.sender;
				//remove a from:accept_proposals;
				sold<-true;
				// auction ended
				atAuction<-false;
				busyAuction<-false;
				write name + 'left auction';
			}
			/*else if(contentsOne=nil){
				write name + " said: ok, no one got it" + m.sender;
					//remove a from:accept_proposals;
					sold<-true;
					// auction ended
					busyAuction<-false;
					atAuction<-false;
					write name + 'left auction';
			}*/
		}
		reflex receive_reject_proposals when: !empty(reject_proposals) and busyAuction{
			message m <-reject_proposals at 0; // needs to be emptied
			string contentZero <-m.contents[0];
			write name + '!receive_reject_proposals ' +contentZero ;
			
			if(contentZero='winnerfound'){
				write name + " said: Someone else bought it.. leaving " + m.sender;
				//remove a from:accept_proposals;
				sold<-true;
				// auction ended
				atAuction<-false;
				busyAuction<-false;
				write name + 'left auction';
			}
				if( contentZero= 'not sold yet'){
					write name + ' OK, waiting for next round...';
					/*write name + " said: I didn't get it.. maybe next time" + m.sender;
					//remove a from:accept_proposals;
					sold<-true;
					// auction ended
					busyAuction<-false;
					atAuction<-false;
					write name + 'left auction';*/
				}
			
		}
	aspect base {
		
			draw circle(size) color: color ;
		
		draw ' !: ' + warnings at: location+{-2,5} color: #black;
	}
} 
