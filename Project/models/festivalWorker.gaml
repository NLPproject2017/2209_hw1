/**
* Name: festivalWorker
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model festivalWorker
import "main.gaml"
species festivalWorker skills: [moving]{
	float size <- 2.0 ;
	rgb color <- #purple;
	point storeToGoTo<-nil;
	bool delivered<-false;
	bool rest<-false;
	bool strong;
	int energyLevel;
	int energyRegeneration;
	
	
	reflex calledToInfo when:light and storeToGoTo = nil and !rest{
		//write 'energy -1 called to info';
		energyLevel<-energyLevel-1;
		
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				if(!self.busy){
					self.busy<-true;
					//write name +" Info needed me!";
					//get first empty in list and remove it
					if (length(self.emptyStores)>0){
						//write "Number of empty stores = "+length(self.emptyStores);
						myself.storeToGoTo<-first(self.emptyStores);
						//write 'stores in infos store list '+self.stores;
						//write 'stores in empty list before remove '+ self.emptyStores;
						remove myself.storeToGoTo from: self.emptyStores;
						//write 'removed myself.storeToGoTo from empty stores'+ myself.storeToGoTo;
						//write name + ' removed myself.storeToGoTo' + myself.storeToGoTo;
						add myself.storeToGoTo to:self.stores;
						//write 'Info said this store was empty: ' + myself.storeToGoTo;
			
				}
				
				}
				self.busy<-false;
			}
		}
	}
	reflex goToStore when: storeToGoTo!=nil and !delivered and !rest{
		//write 'energy -1 gotostore';
		if(energyLevel>=1){
			energyLevel<-energyLevel-1;
		}
		do goto target:storeToGoTo speed: 3.0;
	
		if(location distance_to(storeToGoTo)<2){
			//write name + " ... is going to Store to fill up supplies";
			ask store at_distance 2
			{ 
				if(!myself.strong){
					self.foodAvailable<-3;
					self.drinkAvailable<-3;
					myself.delivered<-true;	
				}
				else{
					self.foodAvailable<-10;
					self.drinkAvailable<-10;
					myself.delivered<-true;	
				}
			}
			storeToGoTo<-nil;
			delivered<-true;
			
			}
	}
	reflex reportToInfo when:delivered and !rest{
		//write 'energy -1 report';
		if(energyLevel>=1){
			energyLevel<-energyLevel-1;
		}
		do goto target:infoPoint speed: 3.0;
		
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				// move to other list
				
				//myself.storeToGoTo<-nil;
				myself.delivered<-false;
				//myself.energyLevel<-myself.energyLevel-5;
				
			}}
	
	}
	reflex idle when: (!light and !delivered and storeToGoTo=nil) or rest{
		//write 'rest ' + rest;
		do wander;
		if(rest){
			// rest and increase energy level
			energyLevel<-energyLevel+energyRegeneration;
			if(energyLevel>=100){
				energyLevel<-100;
				//write 'FULLY RESTED, REST FALSE';
				rest<-false;
			}
		
		}
	}
	reflex goIdleToRest when:energyLevel<=0{
		//write 'REST TRUE triggered';
		rest<-true;
	}
	
	aspect base {
		draw circle(size) color: color ;
		if(strong){
			draw ' Strong ' at: location+{-2,5} color: #black;
		}
		else{
			draw ' Weak ' at: location+{-2,5} color: #black;
		}
		if(storeToGoTo!=nil){
			draw 'To: '+ storeToGoTo at: location+{2,-4} color: #black;
		}
		if(energyLevel>50){ draw 'Energy level:  '+energyLevel at: location+{2,-2} color: #green;}
		else{
			draw 'Energy level:  '+energyLevel at: location+{2,-2} color: #red;
		}
		if(rest){
			color<-#gray;
		}
		else{
			color<-#purple;
		}
		
	}
}