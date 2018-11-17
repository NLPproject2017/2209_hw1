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
	int nrOfAuctioneersDutch<-1;
	init {
		create Auctioneer number: nrOfAuctioneersDutch {
			n<-'Auctioneer '+rnd(100);
		}
		create Participant number: numberOfParticipants {
			n<-'participant '+rnd(100);
			//for challenge part
			loop i over: thingsForSale{
				//if(rnd(2)=1){
				list willingBuyItem<- [i, 400];
				add willingBuyItem to: interestedToBuyItems;
				//}
			}
			//for challenge
			//if(length(interestedToBuyItems)=0){
			//	add thingsForSale[rnd(2)] to: interestedToBuyItems;
			//}
			
		}
		}
}
species Auctioneer skills: [fipa] {
	// set when created
	int numberOfPplResponded<-0;
	string n;
	
	list<Participant> agreedBuyers;
	// format: item, price, minPrice
	list<list> sellingItems<-[['Phone', 400,200],['TV',2000,1000],['Car',5000,4000],['Watch',1000,600]];
	
	bool informed<-false;
	bool informingInProgress<-false;
	bool auctionActive<-false;
	bool restart<-false;
	
	list auctionItem;
	string activeProposedItem;
	int activeProposedPrice;
	int minValueForItem;
	
	
	// inform first participant of starting auction, see if it wants to join
	reflex inform_of_auction when: !auctionActive and !empty(sellingItems) and !informingInProgress{
		write 'Auctioneer: inform_of_auction';
		Participant p<-Participant at 0;
	
		do start_conversation ( to : [p], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+n+' - wanna buy something?'] );
		loop i over: p.peers {
			do start_conversation ( to : [i], protocol : 'fipa-inform', performative : 'inform', contents : ['Auction open at: '+n+' - wanna buy something?'] );
			informingInProgress<-true;
		}
	}
	reflex read_inform_message when: !(empty(informs)) and informingInProgress{
		write 'Auctioneer: read_agree_message';
		
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
			informed<-true;
			auctionActive<-true;
		}
	}
	// start a conversation with all interested participants
	reflex start_conversation when: informed{
		
		if(length(sellingItems)!=0){
			auctionItem<-first(sellingItems);
		}
		activeProposedItem <- string(auctionItem[0]);		
		activeProposedPrice <- auctionItem[1];
		minValueForItem <-auctionItem[2]; //Maybe always 50% discount is the min Value?
		 
		do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', 
			contents :: ["Selling:", activeProposedItem, " at Price", activeProposedPrice]
		];
		
		write "Selling: "+ auctionItem;
		informed<-false;
	}
	
	reflex receive_propose_messages when: !empty(proposes) and !sold {
		//write name + ' receives propose messages';
		
		loop p over: proposes {
			if (sellingItems contains auctionItem)
			{
				write name + ' receives a propose message from ' + agent(p.sender).name + ' with content ' + p.contents;
				int participatPrice <- p.contents[1];
				if ( participatPrice >= activeProposedPrice) {
					write '\t' + name + ' sends a accept_proposal message to ' + p.sender;
					do accept_proposal with: [ message :: p, contents :: ['The ' + activeProposedItem + 'is yours.']];
					remove auctionItem from: sellingItems;
					write "auction item:" + auctionItem + " is sold. " + "Things to sell:" + sellingItems;
					
				} else {
					write '\t' + name + ' sends a reject_proposal message to ' + p.sender;
					do reject_proposal with: [ message :: p, contents :: ['Too low price! Not interested in your proposal for ' + activeProposedItem] ];
				}
			}
		}
	}
	
	// read received agrees
	reflex read_agree_message when: !(empty(agrees)){
		write 'Auctioneer: read_agree_message';
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
		string proposedItem;
		int proposedPrice;
		int willingPrice;
		
		reflex respond_to_inform when: !empty(informs){
			write 'Participant: respond_to_inform';
			message informFromAuctioneer <-(informs at 0);
			write 'informFromAuctioneer: '+ informFromAuctioneer;
			//later add, if interested in topic
			
			do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
			// testing
			//write 'I am interested in: ' + interestedToBuyItems;
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
				
			if (willingPrice<=proposedPrice){
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I agree to buy it for Price:', proposedPrice]];
			} 
			else{
				do refuse with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy it. Willing To buy:', willingPrice]];
			}
		}
		
		reflex receive_accept_proposals when: !empty(accept_proposals) and !sold {
		write name + " said: Hurray, I bought it! ";
		sold <-true;
	} 
	
			
		
	/*
			if( auctionItem='selling books'){
				// TODO fix failures
				if(price>=desiredPrice){
					do failure (message: requestFromAuctioneer, contents: ['Too expencive, I cant afford it']);
				}
				else{
					do agree with: [message:: requestFromAuctioneer, contents:: ['I agree, I want to buy the book!', price]];
				}

				//do goto target:Auctioneer speed: 3.0;
				//send partisipant to auction
				//do goto...
			}
			//write ' inform the initiator of the failure';
			//do failure (message: requestFromInitiator, contents: ['The bed is broken']);
		}*/
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

