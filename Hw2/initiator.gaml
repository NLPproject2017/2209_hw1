/**
* Name: initiator
* Author: h
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model initiator

/* Insert your model definition here */

species Initiator skills: [fipa] {
	reflex send_request when: (time=1){
		Participant p<-Participant at 0;
		write 'send message';
		
		do start_conversation (to :: [p], protocol :: 'fipa-request',performative::'request',contents::['go sleeping']);
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
	species Participant skills: [fipa]{
		reflex reply_messages when: (!empty(requests)){
			message requestFromInitiator <-(requests at 0);
			
			do agree with: (message: requestFromInitiator, contents: ['I will']);
			
			write ' inform the initiator of the failure';
			do failure (message: requestFromInitiator, contents: ['The bed is broken']);
		}
	}
}