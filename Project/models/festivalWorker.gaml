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
	
	reflex calledToInfo when:light and storeToGoTo = nil{
		
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				write name +" Info needed me!";
				//get first empty in list and remove it
				if (length(self.emptyStores)>0){
					//write "Number of empty stores = "+length(self.emptyStores);
					myself.storeToGoTo<-first(self.emptyStores);
					write 'Info said this store was empty: ' + myself.storeToGoTo;
					//light<-false;
				}
			}
		}
	}
	reflex goToStore when: storeToGoTo!=nil and light{
		do goto target:storeToGoTo speed: 3.0;
	
		if(location distance_to(storeToGoTo)<2){
			write name + " ... is going to Store to fill up supplies";
			ask store at_distance 2
			{ 
				self.foodAvailable<-5;
				self.drinkAvailable<-5;
				myself.delivered<-true;
			}
			storeToGoTo<-nil;
			delivered<-true;
			
			}
	}
	reflex reportToInfo when:delivered{
		do goto target:infoPoint speed: 3.0;
	
		if(location distance_to(infoPoint)<2){
			ask info at_distance 2
			{
				remove myself.storeToGoTo from: self.emptyStores;
				write name + ' removed myself.storeToGoTo' + myself.storeToGoTo;
				add myself.storeToGoTo to:self.stores;
				
				myself.storeToGoTo<-nil;
				myself.delivered<-false;
				
			}}
	
	}
	reflex idle when: !light{
		do wander;
		
	}
	
	aspect base {
		draw circle(size) color: color ;
	}
}