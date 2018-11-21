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
	bool auctionClosed<-false;
	int numberOfParticipants<-2;
	int nrOfAuctioneersSealed<-1;
	init {
		create Auctioneer number: nrOfAuctioneersSealed {
			n<-'Auctioneer '+rnd(100);
			cash<-0;
		}
		create Participant number: numberOfParticipants {
			n<-'participant '+rnd(100);
			cash<-1000;
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
	
	list auctionItem;
	string activeProposedItem;
	int activeProposedPrice;
	int minValueForItem;
	int newProposedPrice<-0;
	int priceDropRate <- 50;
	
	Participant winner;
	
	//creative
	int cash;
	bool buyFromParticipant;
	int itemBuyingPrice;
	string itemBuying;
	bool acceptSellingProposals<-false;
	list<message> sellingProposals;
	bool restRT<-false;
	
	//sealed bid
	list<message> sealedBidProposals;
	message highestSealedBidOfferAndParticipant;
	int currentHighestBid<-0;
	
	
	//creative
	reflex read_selling_informs when: !empty(informs) and auctionClosed{
		write 'read_selling_informs';
		message inf <- informs at 0;
		
		if(inf.contents[0]= 'selling'){
				write name+': '+ inf.sender+ ' wants to sell me an item';
				buyFromParticipant<-true;
				itemBuying<-inf.contents[1];
				itemBuyingPrice<-inf.contents[2];
				//list of sellers
				add inf to: sellingProposals;
				acceptSellingProposals<-true;
			}
	}
	//creative
	reflex suggest_price_to_seller when: !empty(sellingProposals) and auctionClosed{
		write 'suggest_price_to_seller';
		message seller <-first(sellingProposals);
		remove seller from: sellingProposals;
		int sellingPrice <- seller.contents[2];
		string item<- seller.contents[1];
		list sellingItem <- [item,sellingPrice+100,sellingPrice];
		if(cash>sellingPrice){
			
			do accept_proposal with: [ message :: seller, contents :: ['I will buy your item',sellingPrice]];
		
			add item to:sellingItems;
			int newPrice<-sellingPrice+100;
			write 'accepting selling proposals from participants';
			write ' added ' + item + ' to auction house, now selling at: '+newPrice;
			write '';
			write name+' Cash: ' + cash;
			
		}
		else{
			write 'auction house could not afford item sold by seller';
		}
		restRT<-true;
	}
	
	reflex beIdle when: auctionClosed
	{
		do wander;
		
	}
	/*reflex restart_auctionwithnewitems when: restRT{
		write ' restarting ' + restRT;
		//to restart
		ToBeInformed<-false;
		auctionActive<-false;
		auctionClosed<-false;
		sold<-false;
		restRT<-false;
		numberOfPplResponded<-0;
		
	}*/
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
	
				currentHighestBid<-(highestSealedBidOfferAndParticipant.contents[1]);

				// if latest offer is highest yet, save it
				if ( newOffer > currentHighestBid) {
				//DEBUG	//write '\t previous highest bid was: '+ highestSealedBidOfferAndParticipant.sender +' with bid: '+ currentHighestBid + ' new bid: '+ p.sender + ' made higher sealed bid offer, saving ' + newOffer;
					highestSealedBidOfferAndParticipant<-p;
				}
				else{
				//DEBUG	//write 'previous bid was higher, keeping old';
				} 
			}	
				int participatPrice <- p.contents[1];
				//If everyone responded, we have a winner
				if (numberOfPeopleProposed = length(agreedBuyers) and sellingItems contains auctionItem)
				{
					//write 'hello';
					write "Number of People proposed: " + numberOfPeopleProposed;
					write name+ ' Winner: '+highestSealedBidOfferAndParticipant.sender+' '  + highestSealedBidOfferAndParticipant.contents[1];
					//remove 
					remove auctionItem from: sellingItems;
					
					//send agree to participant
					do accept_proposal with: [ message :: highestSealedBidOfferAndParticipant, contents :: [activeProposedItem, participatPrice]];
					
					//add new cash
					cash<-cash+participatPrice;
					// suggest next item in previous reflex
					auctionItem<-nil;
					ToBeInformed<-true;	
					highestSealedBidOfferAndParticipant<-nil;
					numberOfPeopleProposed<-0;
					currentHighestBid<-0;
					winner<-nil;
					
					sold<-true;
				}
				}
				// after the auction closed
				
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
		
		//creative
		int cash;
		list<string> itemsInInventory;
		bool puttingItemUpForAuction<-false;
		bool itemsInInventoryBool<-false;
		
		
		//creative
		reflex donate_item_to_auction when: !empty(itemsInInventory) and auctionClosed{
			puttingItemUpForAuction<-true;
			//itemsInInventoryBool<-false;
			string auctionThis<-first(itemsInInventory);
			remove auctionThis from: itemsInInventory;
			int sellingPrice <- 100+rnd(50);
			write name+' submitting '+auctionThis+' i previously bought to an auction';
			
			Auctioneer a <-Auctioneer at 0;
	
			do start_conversation ( to : [a], protocol : 'fipa-inform', performative : 'inform', contents : ['selling',auctionThis,sellingPrice] );
			//reject accept
			
		}
		//creative
		reflex receive_accept_proposals_auctionhouse_bought when: !empty(accept_proposals) and puttingItemUpForAuction{
			write name + ' old balance: ' + cash;
			message m <- accept_proposals at 0;
			int money<-m.contents[1];
			cash<-cash+money;
			write name + ': after' + m.sender +' bought my item, added ' + money +' to cash';
			write name + ' new balance: ' + cash;
			
			puttingItemUpForAuction<-false;
		}
		
		
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
					if(cash>offerPrice){
						// make an offer	
						do propose with: [ message :: proposalFromAuctioneer, contents :: ['I offer: ', offerPrice]];
						//interestedInItem<-true;
					}
					else{
						write name + ' I wanted to buy it, but I couldnt afford it :(';
						// make offer 0
						do propose with: [ message :: proposalFromAuctioneer, contents :: ['I offer: ', 0]];
					}
				}
			}
			/*if(!interestedInItem){
				//do propose with: [ message :: proposalFromAuctioneer, contents :: ['I'm not interested]];
			}*/
			}
		reflex receive_accept_proposals when: !empty(accept_proposals) and sold{
		write name + " said: Hurray, I bought it! ";
		write name+' Cash: ' + cash;
		
		message m <- accept_proposals at 0;
		int itemPrice <- m.contents[1];
		string item <- m.contents[0];
			
		cash<-cash-itemPrice;
		add item to: itemsInInventory;
		
		//reset
		sold<-false;
	}
		aspect base {
		draw circle(1) color: #blue ;
	}
	}
	
experiment main type: gui {
	parameter "Number of auctioneers(Dutch)" var: nrOfAuctioneersSealed min: 1 max: 10 category: "Auctioneers" ;
	parameter "Number of participants" var: numberOfParticipants min: 1 max: 100 category: "Participants" ;
	output {
		display main_display {
			species Auctioneer aspect: base ;
			species Participant aspect: base ;
		
		}
	}
}

