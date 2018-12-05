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
	bool noAction <- true; //
	agent badAgentLocation;
	int badGuestNumber;

	reflex beIdle when: noAction and callingGuard = false and badAgentLocation = nil
	{
		do wander;
	}
	
	
	reflex goToInfoPoint when: callingGuard
	{
		
		do goto target:infoPoint speed: 3.0;
		
		if(location distance_to(infoPoint)<2){
			
			ask info at_distance 7.1
			{
				
				if (self.badAgentLocation !=nil){
					write "Bad Guest found. Going to Information Desc";
					
					myself.badAgentLocation <- self.badAgentLocation;
					myself.badGuestNumber <- self.badGuestNumber;
					callingGuard <-false;
				}
			}
			
		}
		
	}
	
	reflex catchAndKill when: badAgentLocation!= nil
	{
	
		do goto target:badAgentLocation speed: 3.0;
		
		if(location distance_to(badAgentLocation)<2){
			if(callingGuard){
			write "Got the location of bad guest. Going to kill now";
			}
			ask guest at_distance 3.1
			{
				if (myself.badGuestNumber = self.n){
					write "Guest number " + self.n + " killed"; 
					self.beingKilled <-true;
					
					myself.badAgentLocation<-nil;
					myself.badGuestNumber <- nil;
				}
			}
			
		}
		
	}
	
	aspect base {
		draw cylinder(3.1,1)  color: color ;
	}
}
