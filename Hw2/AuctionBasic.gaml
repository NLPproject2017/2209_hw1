/**
* Name: AuctionBasic
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model AuctionBasic

/* Insert your model definition here */
global {
	init {
		create Auctioneer number: 1 ;
		create Participant number: 2 ;
		}
}
species Auctioneer skills: [fipa] {
	list<string> thingForSale<-['Apple','Pear','Orange'];
	
	reflex send_request when: (time=rnd(3)){
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
	}
	aspect base {
		draw circle(2) color: #brown ;
	}
	}
	species Participant skills: [fipa]{
		
		reflex reply_messages when: (!empty(requests)){
			// read first request
			message requestFromAuctioneer <-(requests at 0);
			
			do agree with: (message: requestFromAuctioneer, contents: ['OK! comming...']);
			//send partisipant to auction
			//do goto...
			
			//write ' inform the initiator of the failure';
			//do failure (message: requestFromInitiator, contents: ['The bed is broken']);
		}
		aspect base {
		draw circle(1) color: #blue ;
	}
	}
	

experiment main type: gui {
	//parameter "Initial auctioneer " var: numberOfAuc min: 1 max: 1000 category: "Guests" ;
	//parameter "Initial number of dumb guests: " var: dumb_guests_init min: 1 max: 1000 category: "Guests" ;
	output {
		display main_display {
			species Auctioneer aspect: base ;
			species Participant aspect: base ;
		
		}
	}
}

