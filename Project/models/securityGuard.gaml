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
		do goto target:infoPoint speed: 3.0;
	
	}
	
	reflex catchAndKill when: badAgent!= nil and busy
	{
		//write 'got info about bad guest, going to find him';
		do goto target:badAgent speed: 3.0;
		
		if(location distance_to(badAgent)<2){
			
			ask badAgent
			{
				// cant kill ppl in auctions
				if(!self.busyAuction){
					write "Guest number " + self.name + " killed"; 
					self.alive <-false;	
				}			
				
			}
			badAgent<-nil;
			busy<-false;
		}
	}
	
	aspect base {
		draw cylinder(3.1,1)  color: color ;
	}
}
