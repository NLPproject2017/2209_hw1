/**
* Name: securityGuard
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model securityGuard
import "main.gaml"

species securityGuard  skills: [moving]{
	
	int size <-3;
	rgb color<-#cyan;
	bool busy <- false; 
	guest badAgent<-nil;
	//int badGuestNumber;
	//criminals
	int energy<-100;
	bool chasingCriminal<-false;
	Criminal c;
	bool newAtWork;
	int fitnessLevel;
	float speed;
	bool patient;

	reflex beIdle when: !busy or !callingGuard and badAgent = nil
	{
		do wander;
	}
	reflex beBusy when: badAgent != nil{
		//write 'guard busy';
		busy<-true;
	}
	reflex dontBeBusy when: badAgent = nil{
		//write 'not busy';
		busy<-false;
	}
	
	
	reflex goToInfoPoint when: callingGuard and !busy
	{
		do goto target:infoPoint speed: speed;
	
	}
	
	reflex catchAndKill when: badAgent!= nil and busy
	{
		//write 'got info about bad guest, going to find him';
		do goto target:badAgent speed: speed;
		
		if(location distance_to(badAgent)<2){
			
			ask badAgent
			{
				// cant kill ppl in auctions or who are going to report an empty store
				if(!self.busyAuction or self.storeEmpty){
					write "Guest number " + self.name + " killed"; 
					if((!myself.patient and self.warnings=2) or (self.warnings>2)){
						self.alive <-false;	
					}
					else if(self.warnings<=3){
						self.warnings<-self.warnings+1;
					}
				}			
				
			}
			badAgent<-nil;
			busy<-false;
		}
	}
	// catching criminals, but only if we are not new at work or have a bad fitness level..
	reflex seeCriminal when: !empty(Criminal at_distance 20) and !busy and !newAtWork and fitnessLevel>50{
		write name + ' chasing a criminal!!';
		chasingCriminal<-true;
		busy<-true;
		c<-first(Criminal at_distance 20);
	}
	// kill criminal if we catch him
	reflex chaseCriminal when: chasingCriminal{
		do goto target:c speed: speed;
		if(location distance_to c< 2){
			ask c{
				self.alive<-false;
			}
			busy<-false;
			chasingCriminal<-false;
			c<-nil;
		}
	}
	
	aspect base {
		// viewing radius for criminals
		draw circle(20) color: #beige ;
		if(!newAtWork){
			draw cylinder(3.1,1)  color: color ;
			if(fitnessLevel<50){
				draw ' unfit ' + fitnessLevel at: location+{-2,5} color: #black;
			}
		}
		else{
			draw cylinder(3.1,1)  color: color ;
			draw ' New guy' color: #black;
			draw ' fit ' + fitnessLevel at: location+{-2,5} color: #black;
			
		}
		
		
	}
}
