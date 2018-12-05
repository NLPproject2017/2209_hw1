/**
* Name: infodesk
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model infodesk
import "main.gaml"

species info{
	int size<-3;
	rgb color <-#red;
	list<point> stores;
	list<point> emptyStores;
	
	agent badAgentLocation;
	int badGuestNumber;
	
	//request festivalworker to fill inventories when one is empty
	reflex requestFillStores when: !(length(emptyStores)=0){
		light<-true;
		write name + ' stores in need of supplies: '+emptyStores;
	}
	//request festivalworker to fill inventories when one is empty
	reflex noStoresNeed when: (length(emptyStores)=0){
		light<-false;
	}
	reflex allStoresEmpty when: length(emptyStores)=stores_init{
		write "Food And Drink are finished at stores. Please come back later."; 	
	}
	/*reflex requestAWorker when: (length(emptyStores)>0)// and !handled{
	{
		light<-true;
		handled<-true;
	}*/

	
 aspect base {
		draw square(size) color: color ;
	}
}

