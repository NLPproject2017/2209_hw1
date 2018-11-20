/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic

/* Insert your model definition here */
global {
	list<list> thingsForSale<-[['Phone', 'Personal'],['TV', 'HouseholdItems'],['Car', 'HouseholdItems'],['Watch', 'Personal']];
	list<string> categories<-['Personal','HouseholdItems'];
	
	
	int timeInterval <- rnd(1000);
	int offerTime<-10;
	list<string> soldStatus;
	int numberOfParticipants<-2;
	int nrOfAuctioneersDutch<-2;
	init {
		create Auctioneer number: nrOfAuctioneersDutch {
			n<-'Auctioneer '+rnd(100);
			
			//loop i over: categories{
				int index <- rnd(1,2);
				add categories[index-1] to: selectCategories;
			//}
			
			sellingItems<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
			list<list> sellingItems_copy<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
			loop i over: sellingItems_copy{
				if (!(selectCategories contains i[3])){
					remove i from: sellingItems;
					}
				}
			
			write name + " categories:" + selectCategories + "Items:" + sellingItems;
			
		}
		create Participant number: numberOfParticipants {
			n<-'participant '+rnd(100);
			//for challenge part
			int index <- rnd(1,2);
			add categories[index-1] to: interestedCategories;
				
			loop i over: thingsForSale{
				if (interestedCategories contains i[1]){
					list willingBuyItem<- [i[0], 300];
					add willingBuyItem to: interestedToBuyItems;
				}
			}
			
			write name + " interested categories: "+ interestedCategories +" and willing to buy items:" + interestedToBuyItems;
			
			//for challenge
			//if(length(interestedToBuyItems)=0){
			//	add thingsForSale[rnd(2)] to: interestedToBuyItems;
			//}
			
		}
		}
}
species Auctioneer skills: [fipa, moving] {
	// set when created
	int numberOfPplResponded<-0;
	int numberOfPeopleProposed<-0;
	int numberOfPeopleRejected<-0;
	
	list<string> selectCategories;
	list<list> sellingItems;
	string n;
	
	list<Participant> agreedBuyers;
	// format: item, price, minPrice, category
	//list<list> sellingItems<-[['Phone', 400,200, "Personal"],['TV',600,400, "HouseholdItems"],['Car',500,200, "HouseholdItems"],['Watch',700,500, "Personal"]];
	
	bool ToBeInformed<-false;
	bool informingInProgress<-false;
	bool auctionActive<-false;
	bool restart<-false;
	bool auctionClosed<-false;
	bool sold <- false;
	
	
	list auctionItem;
	string activeProposedItem;
	int activeProposedPrice;
	int minValueForItem;
	int newProposedPrice<-0;
	int priceDropRate <- 50;
	
	Participant winner;
	
	reflex beIdle when: auctionClosed
	{
		do wander;
	}
	
	
	// inform first participant of starting auction, see if it wants to join
	reflex inform_of_auction when: !auctionActive and !empty(sellingItems) and !informingInProgress{
		write name + " informs about an auction!";
		Participant p<-Participant at 0;
		string category <-first(selectCategories);
	
		do start_conversation ( to : [p], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+name+' - wanna buy something on Category:', category] );
		loop i over: p.peers {
			do start_conversation ( to : [i], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+name+' - wanna buy something?', category] );
			informingInProgress<-true;
		}
	}
	reflex read_inform_message when: !(empty(informs)) and informingInProgress{
		//write 'Auctioneer: read_agree_message';
		
		loop a over: informs{
			numberOfPplResponded<-numberOfPplResponded+1;
			if(a.contents=['I accept']){
				add a.sender to: agreedBuyers;
				write  name + ': '+ a.sender+ ' added to list of interested buyers ';
			} else{
				write  name + ': '+ a.sender+ ' rejected participation.';
			}
			 //+a.contents[1];
		}
		if(numberOfPplResponded=numberOfParticipants){
			write 'numberOfPplResponded: '+numberOfPplResponded;
			if (length(agreedBuyers)!=0)
			{
				informingInProgress<-false;
				ToBeInformed<-true;
				auctionActive<-true;
			}
			else {
				write name + ":No people joined auction. Auction Closed!";
				informingInProgress<-false;
				auctionClosed<-true;
			}
		}
	}
	// start a conversation with all interested participants
	reflex start_conversation when: ToBeInformed and !auctionClosed{
		
		if(length(sellingItems)!=0){
			sold<-false;
			if(length(auctionItem) = 0){
				auctionItem<-first(sellingItems);
				//write  name + ": New Auction Item:" + auctionItem[0] + "for price:" + auctionItem[1] ;
			}
		
			minValueForItem <-auctionItem[2]; 
			activeProposedItem <- auctionItem[0];
			activeProposedPrice <- auctionItem[1];
			if(newProposedPrice != 0 and newProposedPrice >= minValueForItem){
			activeProposedPrice <- newProposedPrice;
			}		
		//Maybe always 50% discount is the min Value?
		 
			do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', 
				contents :: ["Selling:", activeProposedItem, " at Price", activeProposedPrice]];
		
			write name + " says: Selling " + activeProposedItem + " at Price: " + activeProposedPrice;
			
			ToBeInformed<-false;
		} else {
			write "Auction Closed! All Items Sold! Thanks for participation.";
			auctionClosed<-true;
		}
	}
	
	reflex receive_propose_messages when: !empty(proposes) and !sold and !ToBeInformed{
		//bool winnerfound<-false;
		loop p over: proposes {
			if (sellingItems contains auctionItem)
			{
				numberOfPeopleProposed <-numberOfPeopleProposed + 1;
				write agent(p.sender).name + ' says:  ' + p.contents;
				int participatPrice <- p.contents[1];
				if ( participatPrice >= activeProposedPrice and winner = nil) {
					write '\t' + name + ' sends a accept_proposal message to ' + p.sender;
					do accept_proposal with: [ message :: p, contents :: ['The ' + activeProposedItem + 'is yours.']];
					winner <- p.sender;
					//winnerfound<-true;
				} else {
					numberOfPeopleRejected<-numberOfPeopleRejected + 1;
					write '\t' + name + ' rejects proposal from ' + p.sender;
					do reject_proposal with: [ message :: p, contents :: ['Too low price or Too late! Not interested in your proposal for ' + activeProposedItem] ];
				
				}
			}
				
		}
		
				//If everyone responded, check if we have a winner, then end the auction for a item, else propose new price for current Item
				if (numberOfPeopleProposed = length(agreedBuyers) and sellingItems contains auctionItem)
				{
					write "Number of People proposed: " + numberOfPeopleProposed;
					write "Number of people rejected: " + numberOfPeopleRejected;
					if (numberOfPeopleRejected = numberOfPeopleProposed ){
						write "Everyone Rejected!";
						//numberOfPeopleProposed <-0;
						//numberOfPeopleRejected <-0;
						newProposedPrice <- activeProposedPrice - priceDropRate;
						if (newProposedPrice <= minValueForItem){
							remove auctionItem from: sellingItems;
							write "Price was below minimum value. Auction is terminated for Item" + activeProposedItem;
							sold <-true;
							auctionItem<-nil;
							ToBeInformed<-true;
							newProposedPrice<-0;
							winner <- nil;
						}else{
							ToBeInformed<-true;		
							write name + " says: New Round! Selling " + activeProposedItem + " for price: " + 	newProposedPrice;
							
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
					}
					
					numberOfPeopleProposed <-0;
					numberOfPeopleRejected <-0;
				}
	}
	
	// read received agrees
	reflex read_agree_message when: !(empty(agrees)){
		//write 'Auctioneer: read_agree_message';
		loop a over: agrees{
			//write ''+ a.sender+ ' added to list of interested buyers: '; //+a.contents[1];
		}
	}
	reflex read_fail_messages when: !(empty(failures)){
		loop a over: failures{
			write ''+ a.sender+ ' replied with failure: '; //+a.contents[1];
		}
	}
	aspect base {
		draw circle(2) color: #brown ;
	}
	}
	species Participant skills: [fipa]{
		string n;
		list<list> interestedToBuyItems;
		list<string> interestedCategories;
		//string category <-first(interestedCategories);
		string proposedItem;
		int proposedPrice;
		int willingPrice;
		bool sold<-false;
		
		reflex respond_to_inform when: !empty(informs){
			message informFromAuctioneer <-(informs at 0);
			//write 'informFromAuctioneer: '+ informFromAuctioneer;
			//later add, if interested in topic
			if (interestedCategories contains informFromAuctioneer.contents[1]){
				do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
				sold<-false;
			} else
			{
				do inform with: [message:: informFromAuctioneer, contents:: ['I reject, not in my interest']];
			}
		}
		reflex respond_to_proposal when: !empty(cfps){
			message proposalFromAuctioneer<- cfps at 0; 
		
			proposedItem <- proposalFromAuctioneer.contents[1];
			proposedPrice <- proposalFromAuctioneer.contents[3];
			
			loop interestItem over: interestedToBuyItems {
				if (interestItem[0] = proposedItem)
				{
					willingPrice <- interestItem[1];
				}
			}
				
			if (willingPrice>=proposedPrice){
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I agree to buy it for Price:', proposedPrice]];
			} 
			else{
				//TODO: we need to use Refuse, I gues. Then we have to handle refuse messages in Auctioneer as well.
				//do refuse with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy it. Willing To buy:', willingPrice]];
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy it. Willing To buy:', willingPrice]];
			}
		}
		
		reflex receive_accept_proposals when: !empty(accept_proposals) and !sold{
			loop a over: accept_proposals {
				write name + " said: Hurray, I bought item it from " + a.sender;
				remove a from:accept_proposals;
				sold<-true;
			}
	} 

		aspect base {
		draw circle(1) color: #blue ;
	}
	}
	
experiment main type: gui {
	parameter "Number of auctioneers(Dutch)" var: nrOfAuctioneersDutch min: 1 max: 10 category: "Auctioneers" ;
	parameter "Number of participants" var: numberOfParticipants min: 1 max: 100 category: "Participants" ;
	output {
		display main_display {
			species Auctioneer aspect: base ;
			species Participant aspect: base ;
		
		}
	}
}

