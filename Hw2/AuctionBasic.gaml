/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic

/* Insert your model definition here */
global {
	int timeInterval <- rnd(1000);
	int offerTime<-10;
	bool sold;
	init {
		create Auctioneer number: 1 ;
		create Participant number: 2 ;
		}
}
species Auctioneer skills: [fipa] {
	list<string> thingForSale<-['Apple','Pear','Orange'];
	bool auctionActive<-true;
	
	//message query <- queries at 0;
	
	int randNr<-0; // set when created
	string n<-'Auctioneer '+randNr;
	bool restart<-false;
	
	reflex start_conversation when: time=10 and restart{
	restart<-false;
	  Participant p<-Participant at 0;
		do start_conversation (to :: [p], protocol :: 'fipa-request',performative::'request',contents::['selling books', 11]);
	}
	/*reflex anounce_Auction when: auctionActive{
		//add 'hello' to:queries;
		do inform with: [ message :: query, contents :: [ 'Auction now active at ' + n ] ];
	}*/
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
}	
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
		string n<-'Henri';
		reflex read_requests when: (!empty(requests)){
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
		}
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

