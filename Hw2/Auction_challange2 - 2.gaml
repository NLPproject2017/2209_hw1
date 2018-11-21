/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic

/* Insert your model definition here */
global {
	list<string> thingsForSale<-['Phone','TV','Car','Watch'];
	
	int timeInterval <- rnd(1000);
	int offerTime<-10;
	bool sold<-false;
	int numberOfParticipants<-2;
	int nrOfAuctioneersSealed<-1;
	init {
		create Auctioneer number: nrOfAuctioneersSealed {
			n<-'Auctioneer '+rnd(100);
		}
		create Participant number: numberOfParticipants {
			n<-'participant '+rnd(100);
		
			loop i over: thingsForSale{
			
				list willingBuyItem<- [i, 300+rnd(100)];
				add willingBuyItem to: interestedToBuyItems;
			}
		}
	}
}
species Auctioneer skills: [fipa, moving] {
	// set when created
	int numberOfPplResponded<-0;
	int numberOfPeopleProposed<-0;
	//int numberOfPeopleRejected<-0;
	
	string n;
	
	list<Participant> agreedBuyers;
	// format: item
	list<list> sellingItems<-[['Phone'],['TV'],['Car'],['Watch']];
	
	bool ToBeInformed<-false;
	bool informingInProgress<-false;
	bool auctionActive<-false;
	bool restart<-false;
	bool auctionClosed<-false;
	
	
	list auctionItem;
	string activeProposedItem;
	int activeProposedPrice;
	int minValueForItem;
	int newProposedPrice<-0;
	int priceDropRate <- 50;
	
	Participant winner;
	
	//sealed bid
	list<message> sealedBidProposals;
	message highestSealedBidOfferAndParticipant;
	int currentHighestBid<-0;
	int previousHighestBid<-nil;
	
	
	reflex beIdle when: auctionClosed
	{
		do wander;
	}
	// inform first participant of starting auction, see if it wants to join and all peers
	reflex inform_of_auction when: !auctionActive and !empty(sellingItems) and !informingInProgress{
		write 'Auctioneer: Auction starting!';
		Participant p<-Participant at 0;
	
		do start_conversation ( to : [p], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+n+' - wanna buy something?'] );
		loop i over: p.peers {
			do start_conversation ( to : [i], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+n+' - wanna buy something?'] );
			informingInProgress<-true;
		}
	}
	// save people who wanted to join
	reflex read_inform_message when: !(empty(informs)) and informingInProgress{
		write 'read_inform_message';
		loop a over: informs{
			numberOfPplResponded<-numberOfPplResponded+1;
			if(a.contents=['I accept']){
				add a.sender to: agreedBuyers;
			}
			write ''+ a.sender+ ' added to list of interested buyers: '; //+a.contents[1];
		}
		if(numberOfPplResponded=numberOfParticipants){
			write 'numberOfPplResponded: '+numberOfPplResponded;
			
			informingInProgress<-false;
			ToBeInformed<-true;
			auctionActive<-true;
		}
	}
	// start a conversation with all interested participants when auction is open
	reflex start_conversation when: ToBeInformed and !auctionClosed{
		write 'start_conversation';
		// if there are items left to sell
		if(length(sellingItems)!=0){
		
			if(length(sellingItems)!=0 and length(auctionItem) = 0){
				auctionItem<-first(sellingItems);
				//write "New actionItem: " + auctionItem;
			}
		
			activeProposedItem <- auctionItem[0];
			
			do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', 
				contents :: ["Selling:", activeProposedItem]];
		
			write '';
			write name + " Selling: " +activeProposedItem;
			ToBeInformed<-false;
		} else {
			write "Auction Closed! All Items Sold! Thanks for participation.";
			auctionClosed<-true;
		}
	}
	// accept bids from  participants when conversation was started
	reflex receive_propose_messages when: !empty(proposes) and !sold and !ToBeInformed{
		write 'receive_propose_messages';
		message proposalFromParticipant<- proposes at 0;
		message proposalFromWinningParticipant;
		
		loop p over: proposes {
			if (sellingItems contains auctionItem)
			{
				
				//save all bids from participants to later select highest
				//add p to: sealedBidProposals;
				
				numberOfPeopleProposed <-numberOfPeopleProposed + 1;
				write 'Bid received from: '+agent(p.sender).name + ' of:  ' + p.contents[1];
				
				//if no one placed a bid yet
				int newOffer <- p.contents[1];
				if(previousHighestBid=0){
					previousHighestBid<-newOffer;
					/*if(newOffer>previousHighestBid){
						
					}*/
				}
				
				//write 'previousHighestBid before checking new offer: '+previousHighestBid;
				/*if(highestSealedBidOfferAndParticipant=nil){
					highestSealedBidOfferAndParticipant<-p;
					currentHighestBid<-(highestSealedBidOfferAndParticipant.contents[1]);
				}*/
				
				currentHighestBid<-(highestSealedBidOfferAndParticipant.contents[1]);
				
				// if latest offer is highest yet, save it, and save second highest
				if ( newOffer > currentHighestBid) {
					previousHighestBid<-currentHighestBid;
					currentHighestBid<-newOffer;
				//DEBUG	//write '\t previous highest bid was: '+ highestSealedBidOfferAndParticipant.sender +' with bid: '+ currentHighestBid + ' new bid: '+ p.sender + ' made higher sealed bid offer, saving ' + newOffer;
					highestSealedBidOfferAndParticipant<-p;
				}
				else{
					if(newOffer>previousHighestBid){
						previousHighestBid<-newOffer;
					}
				//DEBUG	//write 'previous bid was higher, keeping old';
				
				write '2nd higest bid: ' + previousHighestBid;
				} 
					//write 'previousHighestBid after checking new offer: '+previousHighestBid;
			}
				//write 'numberOfPeopleProposed '+ numberOfPeopleProposed;
				//write 'length(agreedBuyers) '+ length(agreedBuyers);
				
				//If everyone responded, we have a winner
				if (numberOfPeopleProposed = length(agreedBuyers) and sellingItems contains auctionItem)
				{
					//write 'hello';
					write "Number of People proposed: " + numberOfPeopleProposed;
					write name+': '+highestSealedBidOfferAndParticipant.sender+ ' WINS! with highest bid of: '  + highestSealedBidOfferAndParticipant.contents[1];
					//remove 
					remove auctionItem from: sellingItems;
					
					//send agree to participant
					do accept_proposal with: (message: highestSealedBidOfferAndParticipant, contents: ['You win, cost: ',previousHighestBid]);
					
					// suggest next item in previous reflex
					auctionItem<-nil;
					ToBeInformed<-true;	
					highestSealedBidOfferAndParticipant<-nil;
					numberOfPeopleProposed<-0;
					currentHighestBid<-0;
					winner<-nil;
					previousHighestBid<-nil;
					//proposalFromWinningParticipant<-nil;	
					//winner<-highestSealedBidOfferAndParticipant.sender;
					sold<-true;
					
					//write name + " says: New Round! Selling " + activeProposedItem + " for price: " + 	newProposedPrice;
				}
				}
	}
	aspect base {
		draw circle(2) color: #yellow ;
	}
	}
	
	species Participant skills: [fipa]{
		string n;
		list<list> interestedToBuyItems;
		string proposedItem;
		
		int offerPrice;
		bool interestedInItem<-false;
		
		//tell auctioneer we are joining
		reflex respond_to_inform when: !empty(informs){
			write name  + " confirms participation";
			message informFromAuctioneer <-(informs at 0);
			
			do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
		}
		// make an offer on the item if we are interested
		reflex make_proposal when: !empty(cfps){
			message proposalFromAuctioneer<- cfps at 0; 
		
			proposedItem <- proposalFromAuctioneer.contents[1];
			//proposedPrice <- proposalFromAuctioneer.contents[3];
			
			loop interestItem over: interestedToBuyItems {
				if (interestItem[0] = proposedItem)
				{
					offerPrice <- interestItem[1];
					// make an offer	
					do propose with: [ message :: proposalFromAuctioneer, contents :: ['I offer: ', offerPrice]];
					//interestedInItem<-true;
				}
			}
			/*if(!interestedInItem){
				//do propose with: [ message :: proposalFromAuctioneer, contents :: ['I'm not interested]];
			}*/
			}
		reflex receive_accept_proposals when: !empty(accept_proposals) and sold{
			message m <- accept_proposals at 0;
		write name + " said: Hurray, I bought it! For 2nd highest offer price: "+m.contents[1];
		sold<-false;
	}
		aspect base {
		draw circle(1) color: #blue ;
	}
	}
	
experiment main type: gui {
	//parameter "Number of auctioneers Vickery" var: nrOfAuctioneersVickery min: 1 max: 10 category: "Auctioneers" ;
	parameter "Number of participants" var: numberOfParticipants min: 1 max: 100 category: "Participants" ;
	output {
		display main_display {
			species Auctioneer aspect: base ;
			species Participant aspect: base ;
		
		}
	}
}

