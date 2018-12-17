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
	string nameOfWinner;
	bool oneWinnerSelected<-false;
	int notifiedMinusAccepted<-0;
	
	reflex beIdle when: auctionClosed
	{
		// tell people that auction is now closed
		// after rejecting or accepting everyone when a winner is found, tell people that the auction is over
	 	// including winner even if it already left anyway
		loop i over: agreedBuyers{
			ask i{
				write name + 'asked i to leave';
				//remove a from:accept_proposals;
				self.sold<-true;
				// auction ended
				self.busyAuction<-false;
				self.atAuction<-false;
			}
		}
		write name + ' beIdle ';
		do wander;
		write name + ' Wandering between auctions';
		// randomly start a new auction
		int random <- rnd(0,50); // should be a time not random
		write 'random ' + random;
		if(random=1){
			//write name + 'Started NEW auction: informingInProgress'+ informingInProgress + ' auctionActive: '+auctionActive + 'sellingItems: '+ sellingItems;
			// a new one will start when conditions are met.. like new items are available
			startNew<-true;
		}
	}
	
	
	// inform first participant of starting auction, see if it wants to join
	reflex inform_of_auction when: !auctionActive and !empty(sellingItems) and !informingInProgress and startNew{
		//write name + 'Agreed buyers last auction: ' +length(agreedBuyers);
		//reset
		agreedBuyers<-nil;
		//reset
		allArrived<-false;
		winnerfound<-false;
		winner<-nil;
		oneWinnerSelected<-false;
		notifiedMinusAccepted<-0;
		write 'inform_of_auction';
		write name + " informs about an auction! Selling: " + sellingItems + ' items ';
		
		auctionClosed<-false;
		auctionActive<-true;
		string category <-first(selectCategories);
	
		// go to read who wanted to join
		informingInProgress<-true;
		loop i over: guest{
			do start_conversation ( to : [i], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+name+' - wanna buy something?', category, location, 'start'] );
			
		}
		startNew<-false;
	}
	// trigger when guests arrive not woking
	reflex checkArrivedGuests when: !empty(guest at_distance 3) and !allArrived{
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
			} else{
				//write  name + ': '+ a.sender+ ' rejected participation.';
			}
		}
		
		}
			if (length(agreedBuyers)!=0)
			{
				write name +": "+ length(agreedBuyers) +' people joined auction';
				// to go on to propose a price for the item
				ToBeInformed<-true;
				// auction is running
				auctionActive<-true;
			}
			else {
				write name + ":No people joined auction. Auction Closed!";
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
			// if we didnt sell the item yet
			if (sellingItems contains auctionItem)
			{
				numberOfPeopleProposed <-numberOfPeopleProposed + 1;
				//write agent(p.sender).name + ' says:  ' + p.contents;
				int participatPrice <- m.contents[1];
				// if no winner yet
				if ( participatPrice >= activeProposedPrice and !winnerfound) {
					// save winner until last
					winner <- m;
					write '\t' + name + ' sends a accept_proposal message to ' +winner ;
					do accept_proposal with: [ message :: m, contents :: ['The ' + activeProposedItem + 'is yours.', 'winner']];
					// don want to sell same thing again
					remove auctionItem from: sellingItems;
					nameOfWinner<-m.contents[2];
					
					write name + ' saved winnername ' + nameOfWinner;
					// we found a winner for item
					winnerfound<-true;
					sold<-true;
					// so auction is no longer active
					auctionActive<-false;
					// and we close
					auctionClosed<-true;
					
				}
				write name + 'before we should only send to losers winner= ' + nameOfWinner + ' current person ' + m.contents[2];
				// even if first proposal is not winner needs to reject correctly
				write name + ' winnerfound and m.contents[3] = cant buy ' + (m.contents[3] = 'cant buy' + ' winnerfound ' + winnerfound);
				// go through all but skip winner and send last
				if(m.contents[3] = 'I buy' and !oneWinnerSelected){
					oneWinnerSelected<-true;
					// we skip
				}
				
				else{
					// reject everyone else
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
							//winner <- nil; // winner needs to be saved for next lap
							// cant be accept message...  everyone was alrady rejected
							
							loop i over: agreedBuyers{
								ask i{
									write name + 'asked i to leave';
									//remove a from:accept_proposals;
									self.sold<-true;
									// auction ended
									self.busyAuction<-false;
									self.atAuction<-false;
									}
								}
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
						// one item sold, close auction until next item up for sale
						auctionClosed<-true;
						auctionActive<-false;
					}
					numberOfPplResponded<-0;
					numberOfPeopleProposed <-0;
					numberOfPeopleRejected <-0;
				}
	}
	// read received agrees
	reflex read_agree_message when: !(empty(agrees)){
		write name +'read_agree_message';
	}
	reflex read_fail_messages when: !(empty(failures)){
		write 'read_fail_messages';
	}
	aspect base {
		draw circle(2) color: #brown ;
	}
	}

