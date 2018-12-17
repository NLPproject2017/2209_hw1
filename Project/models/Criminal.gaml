/**
* Name: CriminalBlob
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model Criminal
import 'main.gaml'
//import 'ThirstyGuest.gaml'

species Criminal skills:[moving]{
	float speed;
	bool alive<-true;
	bool nice;
	rgb color;
	int strength;
	bool weak; 
	
	// will be still at start otherwise
	reflex walk when: empty(securityGuard at_distance 2){
		do wander speed: speed;
	}
	reflex run when: !empty(securityGuard at_distance 18){
		write name + 'panicing...!!';
		do wander speed: speed*3 amplitude: 1;
	}
	reflex badInfluence when: !empty(guest at_distance 3){
		// bad influence on guests
		
		loop g over: guest at_distance 3{
			ask g{
				write self.name + ' ' + myself.name + ' makes me a bad person.. >:D';
				self.color<-#red;
			}
		}
	}
	reflex robStore when: !empty(store at_distance 3) and !nice{
		// bad influence on guests
		
		loop s over: store at_distance 3{
			ask s{
				write self.name + ' ' + myself.name + ' robbed me D:';
				// if not weak take all
				if(!myself.weak){
					self.drinkAvailable<-0;
					self.foodAvailable<-0;
				}
				else{
					self.drinkAvailable<-self.drinkAvailable-1;
					self.foodAvailable<-self.foodAvailable-1;
				}
				
			}
		}
	}
	reflex die when: !alive  {
		write 'Guest: ' + name + 'I died';
		do die ;
	}
	aspect base {
		draw circle(3) color: color ;
		
		if(!nice){
			draw 'CRIMINAL' at: location+{0,0} color: #black;
		}
		else{
			draw 'nice CRIMINAL' at: location+{0,0} color: #black;
			
		}
		if(weak){
			draw ' weak ' + strength at: location+{-2,5} color: #black;
		}
	}
}


