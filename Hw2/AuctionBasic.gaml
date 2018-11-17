/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic

/* Insert your model definition here */
global {
	list<list> thingsForSale<-['Phone','TV','Car','Watch'];
	
	int timeInterval <- rnd(1000);
	int offerTime<-10;
	bool sold;
	int nrOfParticipants<-2;
	init {
		create Auctioneer number: 1 ;
		create Participant number: nrOfParticipants {
			//for challenge part
			loop i over: thingsForSale{
				//if(rnd(2)=1){
					add i to: interestedToBuyItems;
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
	
	int sellPrice <-0;
	list<Participant> agreedBuyers;
	int numberOfPplResponded<-0;
	list<list> startAndMinValues<-[['Phone', 400,200],['TV',2000,1000],['Car',5000,4000],['Watch',1000,600]];
	
	bool informed<-false;
	bool informingInProgress<-false;
	bool auctionActive<-false;
	
	//message query <- queries at 0;
	
	int randNr<-0; // set when created
	string n<-'Auctioneer '+randNr;
	bool restart<-false;
	
	// inform first participant of starting auction, see if it wants to join
	reflex inform_of_auction when: !auctionActive and !empty(thingsForSale) and !informingInProgress{
		write 'Auctioneer: inform_of_auction';
		
		Participant p<-Participant at 0;
		//write 'p.peers:' +p.peers;
		//write 'p:' +p;
		
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
		if(numberOfPplResponded=nrOfParticipants){
			write 'numberOfPplResponded: '+numberOfPplResponded;
			informingInProgress<-false;
			informed<-true;
			
			auctionActive<-true;
		}
	}
	// start a conversation with all interested participants
	reflex start_conversation when: informed{
		string auctionItem;
		if(length(thingsForSale)!=0){
			auctionItem<-first(thingsForSale);
			//write 'auctionItem: ' + first(thingsForSale) + ' auctionItem' +auctionItem;
		}
		
		do start_conversation with: [ to :: list( agreedBuyers), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ["Selling: ", auctionItem] ];
		write "Selling: "+ auctionItem;
		informed<-false;
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
	
	
	/*reflex start_conversation when: time=10 and restart{
	restart<-false;
	  Participant p<-Participant at 0;
		do start_conversation (to :: [p], protocol :: 'fipa-request',performative::'request',contents::['selling books', 11]);
	}*/
	/*reflex anounce_Auction when: auctionActive{
		//add 'hello' to:queries;
		do inform with: [ message :: query, contents :: [ 'Auction now active at ' + n ] ];
	}
	reflex no_response when: empty(agrees) or empty(failures){
		
		restart<-true;
	}
	reflex read_agree_message when: !(empty(agrees)) {
		
		loop a over: agrees{
			write ''+ a.sender+ ' buys the books at: ' +a.contents[1];
			
			
			//restart<-true;
		}

	}
	// TODO fix failures
	reflex read_failiure_message when: !(empty(failures)){
		
		loop f over: failures{
			write 'failure message with content: '+(string(f.contents));
			
		}
}	*/
	/*reflex send_request when: (time=rnd(3)){
		// first participant
		Participant p<-Participant at 0;
		write 'Anouncing auction! ' ;
		
		//start a conversation with participant
		do start_conversation (to :: [p], protocol :: 'fipa-request',performative::'request',contents::['Auction anouncement']);
	}
	reflex read_agree_message when: !(empty(agrees)) {
		loop a over: agrees{
			write 'agree message with content' + string(a.contents);
			
		}
	}
	reflex read_failiure_message when: !(empty(failures)){
		loop f over: failures{
			write 'failure message with content: '+(string(f.contents));
			
		}
	}*/
	aspect base {
		draw circle(2) color: #brown ;
	}
	}
	species Participant skills: [fipa]{
		string n<-'participant '+rnd(100);
		list<list> interestedToBuyItems;
		
		reflex respond_to_inform when: !empty(informs){
			write 'Participant: respond_to_inform';
			message informFromAuctioneer <-(informs at 0);
			write 'informFromAuctioneer: '+ informFromAuctioneer;
			//later add, if interested in topic
			
			do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
			// testing
			//write 'I am interested in: ' + interestedToBuyItems;
			
		}
		reflex message_proposed_by_auctioneer when: !empty(cfps){
			message proposalFromAuctioneer<- cfps at 0;
					
		}
		
		/*reflex read_requests when: (!empty(requests)){
			write 'inform message with content: ';
		
			// read first request
			message requestFromAuctioneer <-(requests at 0);
			write requestFromAuctioneer.contents;
			string auctionItem<-requestFromAuctioneer.contents[0];
			int price <- requestFromAuctioneer.contents[1];
			int desiredPrice<-100;
			
			write 'auction item and price: '+auctionItem +' ' + price;
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
	//parameter "Initial auctioneer " var: numberOfAuc min: 1 max: 1000 category: "Guests" ;
	//parameter "Auction new offer time" var: timeInterval min: 1 max: 100 category: "time";
	output {
		display main_display {
			species Auctioneer aspect: base ;
			species Participant aspect: base ;
		
		}
	}
}

