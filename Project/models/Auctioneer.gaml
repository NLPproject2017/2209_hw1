/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic	
import "main.gaml"

species Auctioneer skills: [fipa, moving] {
	// set when created
	int numberOfPplResponded<-0;
	int numberOfPeopleProposed<-0;
	int numberOfPeopleRejected<-0;
	
	list<string> selectCategories;
	list<list> sellingItems;
	string n;
	
	list<guest> agreedBuyers;
	// format: item, price, minPrice, category
	//list<list> sellingItems<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
	
	bool ToBeInformed<-false;
	bool informingInProgress<-false;
	bool auctionActive<-false;
	bool restart<-false;
	bool auctionClosed<-false;
	bool sold <- false;
	bool startNew<-true;
	bool allArrived<-false;
	bool winnerfound<-false;
	
	
	list auctionItem;
	string activeProposedItem;
	int activeProposedPrice;
	int minValueForItem;
	int newProposedPrice<-0;
	int priceDropRate <- 50;
	
	Participant winner;
	
	reflex beIdle when: auctionClosed
	{
		write name + ' beIdle ';
		do wander;
		write name + ' Wandering between auctions';
		// randomly start a new auction
		int random <- rnd(0,20);
		write 'random ' + random;
		if(random=1){
			write name + 'Started NEW auction: informingInProgress'+ informingInProgress + ' auctionActive: '+auctionActive + 'sellingItems: '+ sellingItems;
			startNew<-true;
		}
	}
	
	
	// inform first participant of starting auction, see if it wants to join
	reflex inform_of_auction when: !auctionActive and !empty(sellingItems) and !informingInProgress and startNew{
		write name + 'Agreed buyers at start of auction: ' +length(agreedBuyers);
		//reset
		agreedBuyers<-nil;
		//reset
		allArrived<-false;
		winnerfound<-false;
		write 'inform_of_auction';
		write name + " informs about an auction! Selling: " + sellingItems + ' items ';
		
		auctionClosed<-false;
		auctionActive<-true;
		//guest p<-guest at 0;
		string category <-first(selectCategories);
	
		//do start_conversation ( to : [p], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+name+' - wanna buy something on Category:', category,location] );
		// go to read who wanted to join
		informingInProgress<-true;
		loop i over: guest{
			do start_conversation ( to : [i], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+name+' - wanna buy something?', category, location, 'start'] );
			
		}
		startNew<-false;
	}
	// trigger when guests arrive not woking
	reflex checkArrivedGuests when: !empty(guest at_distance 3) and !allArrived{
		//write 'checking arrivals ' + guest at_distance 4+'/'+length(agreedBuyers);
		if(length(guest at_distance 3)=length(agreedBuyers)){
			write 'alla arrived true';
			allArrived<-true;
		}
	}
	reflex read_inform_message when: !(empty(informs)) and informingInProgress{
		write '!!!read who wanted to join!!!';
		//write 'Auctioneer: read_agree_message';
		list savedInforms <-informs; // to empty
		if(length(savedInforms)>0){
		loop a over: savedInforms{
			numberOfPplResponded<-numberOfPplResponded+1;
			if(a.contents=['I accept']){
				add a.sender to: agreedBuyers;
				//write  name + ': '+ a.sender+ ' added to list of interested buyers ';
			} else{
				//write  name + ': '+ a.sender+ ' rejected participation.';
			}
			 //+a.contents[1];
		}
		
		}
		//write 'length(guest at_distance 3)' + length(guest at_distance 3);
		//write 'length(agreedBuyers)' + length(agreedBuyers);
		//write 'numberOfPplResponded: '+numberOfPplResponded;
			if (length(agreedBuyers)!=0)
			{
				write name +": "+ length(agreedBuyers) +' people joined auction';
				//informingInProgress<-false;
				// to go on to propose a price for the item
				ToBeInformed<-true;
				// auction is running
				auctionActive<-true;
			}
			else {
				write name + ":No people joined auction. Auction Closed!";
				//informingInProgress<-false;
				// then auction is canceled
				auctionClosed<-true;
				// and not active
				auctionActive<-false;
				informingInProgress<-false;
			}
			// reset, no one arrived yet
			allArrived<-false;
	}
	// start a conversation with all interested participants
	reflex start_conversation when: ToBeInformed and auctionActive and allArrived{
		// we are not informing of an auction, it has started
		informingInProgress<-false;
		// every round loops through
		
		if(length(sellingItems)!=0){
			// resel, nothing is sold yet
			sold<-false;
			
				// currently selling this item
				auctionItem<-first(sellingItems);
				
		
			minValueForItem <-auctionItem[2]; 
			activeProposedItem <- auctionItem[0];
			activeProposedPrice <- auctionItem[1];
			if(newProposedPrice != 0 and newProposedPrice >= minValueForItem){
				activeProposedPrice <- newProposedPrice;
			}		
		//Maybe always 50% discount is the min Value?
		 
			do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', 
				contents :: ["Selling:", activeProposedItem, " at Price", activeProposedPrice]];
			// sista den skriver.. and ppl dont come
			write name + " says: Selling " + activeProposedItem + " at Price: " + activeProposedPrice;
			// stopp proposing price and check what they offered
			ToBeInformed<-false;
		} else {
			write name + " says: Auction Closed! All Items Sold! Thanks for participation.";
			agreedBuyers<-nil;
			auctionClosed<-true;
			auctionActive<-false;
		}
	}
	
	// tog bort loopar
	reflex receive_propose_messages when: !empty(proposes) and !sold and !ToBeInformed{
		
		message m<-proposes at 0;
		list proposesSaved<-proposes;
		write name + 'receive_propose_messages';
		write name + ' propose-message: '+m;
	if (!(numberOfPeopleProposed = length(agreedBuyers) and sellingItems contains auctionItem))
				{
		//bool winnerfound<-false;
			if (sellingItems contains auctionItem)
			{
				numberOfPeopleProposed <-numberOfPeopleProposed + 1;
				//write agent(p.sender).name + ' says:  ' + p.contents;
				int participatPrice <- m.contents[1];
				if ( participatPrice >= activeProposedPrice and !winnerfound) {
					write '\t' + name + ' sends a accept_proposal message to ' + m.sender;
					do accept_proposal with: [ message :: m, contents :: ['The ' + activeProposedItem + 'is yours.', 'winner']];
					// don want to sell same thing again
					remove auctionItem from: sellingItems;
					string nameOfWinner<-m.contents[2];
					winner <- m.sender;
					// we found a winner for item
					winnerfound<-true;
					sold<-true;
					// so auction is no longer active
					auctionActive<-false;
					// and we close
					auctionClosed<-true;
					
					// notify winner
					//do accept_proposal with: [ message :: m, contents :: ['Too low price or Too late! Not interested in your proposal for ' + activeProposedItem, 'winner'] ];
					
				}
				if(winnerfound){
					loop rej over: reject_proposals{
						do reject_proposal with: [ message :: rej, contents :: ['winnerfound'] ];
					}//do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', 
				//contents :: ['winnerfound']];
				} else{
					write 'new round triggered...';
					numberOfPeopleRejected<-numberOfPeopleRejected + 1;
					write '\t' + name + ' rejects proposal from ' + m.sender;
					do reject_proposal with: [ message :: m, contents :: ['Too low price or Too late! Not interested in your proposal for ' + activeProposedItem, 'not sold yet'] ];
				
				}
				
			}

		}
		
				// if everyone proposed and item is still in list, it didnt sell, start new round!
				if (numberOfPeopleProposed = length(agreedBuyers) and sellingItems contains auctionItem)
				{
					//write "Number of People proposed: " + numberOfPeopleProposed;
					//write "Number of people rejected: " + numberOfPeopleRejected;
					// everyone rejected round
					if (numberOfPeopleRejected = numberOfPeopleProposed ){
						write "Everyone Rejected!";
						newProposedPrice <- activeProposedPrice - priceDropRate;
						// we dont want to sell too cheap, if so, abort
						
						if (newProposedPrice <= minValueForItem){
							//tooLow<-false;
							// notify people that they didnt win
							
							remove auctionItem from: sellingItems;
							write "Price was below minimum value. Auction is terminated for Item" +  activeProposedItem;
							sold <-true;
							auctionItem<-nil;
							auctionClosed<-true;
							auctionActive<-false;
							//ToBeInformed<-true;
							newProposedPrice<-0;
							winner <- nil;
							
								//do propose with: [ message :: g, contents :: ['Too low price or Too late! Not interested in your proposal for ' + activeProposedItem, 'auction over'] ];
						
							
						}else{
							// trigger a new round for same item if not too cheap
							ToBeInformed<-true;		
							write '';
							write name + " says: NEW Round!"; // Selling " + activeProposedItem + " for price: " + 	newProposedPrice;
						}
					}
					
					
					if (winner != nil){
						remove auctionItem from: sellingItems;
						write "Auction item " + auctionItem + " is sold. ";
						sold <-true;
						auctionItem<-nil;
						ToBeInformed<-true;
						newProposedPrice<-0;
						winner <- nil;
						// one item sold, close auction until next item up for sale
						auctionClosed<-true;
						auctionActive<-false;
					}
					numberOfPplResponded<-0;
					numberOfPeopleProposed <-0;
					numberOfPeopleRejected <-0;
				}
				else{
					// one round? item sold, close auction until next item up for sale
					//auctionClosed<-true;
				}
	}
	// read received agrees
	reflex read_agree_message when: !(empty(agrees)){
		write name +'read_agree_message';
		//write 'Auctioneer: read_agree_message';
		//loop a over: agrees{
			//write ''+ a.sender+ ' added to list of interested buyers: '; //+a.contents[1];
		//}
	}
	reflex read_fail_messages when: !(empty(failures)){
		write 'read_fail_messages';
		//loop a over: failures{
		//	write ''+ a.sender+ ' replied with failure: '; //+a.contents[1];
		//}
	}
	aspect base {
		draw circle(2) color: #brown ;
	}
	}

