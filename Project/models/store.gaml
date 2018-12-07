/**
* Name: store
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model store
import "main.gaml"
species store{
	string n; 
	int size <-3;
	rgb color<-#green;
	
	int foodAvailable; 
	int drinkAvailable; 
	
	bool alreadyReportedFood<-false;
	bool alreadyReportedDrink<-false;
	
	reflex outOfone when: foodAvailable=0 and !(drinkAvailable=0) or drinkAvailable=0 and !(foodAvailable=0){
		color<-#orange;
	}
	reflex outOfFoodAndDrink when: foodAvailable=0 and drinkAvailable=0{
		color<-#red;
	}
	reflex restockedInventory when: !(foodAvailable=0){
		color<-#green;
		// someone is reporting to info that the store was empty
		alreadyReportedFood<-false;
	}
	reflex restockedInventory when: !(drinkAvailable=0){
		color<-#green;
		// someone is reporting to info that the store was empty
		alreadyReportedDrink<-false;
	}
	aspect base {
		draw square(size) color: color ;
		draw 'location'+ location at: location+{2,-4} color: #black;
		draw ' Food: '+foodAvailable+ ' Drink: '+drinkAvailable at: location+{2,-2} color: #black;
		
	}
}

