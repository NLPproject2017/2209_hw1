/**
* Name: stages
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model stages

/* Insert your model definition here */

global {
	
	int numberOfGuests<-2;
	int nrOfStages<-1;
	list<point> stage_locations;
	init {
		create Stage number: nrOfStages {
			add location to: stage_locations;
		}
		create Guest number: numberOfGuests {
			
			}
			
		}
		}
species Guest skills:[moving]{
	
	aspect base {
		draw circle(1) color: #blue ;
	}
}
species Stage {
	aspect base {
		draw square(5) color: #brown ;
	}
}
species Performer skills:[moving]{
	aspect base {

			draw circle(1) at:stage_locations[0] color: # green;
	}
}
experiment main type: gui {
	parameter "Number of Stages" var: nrOfStages min: 1 max: 10 category: "Stages" ;
	parameter "Number of Guests" var: numberOfGuests min: 1 max: 100 category: "Guests" ;
	output {
		display main_display {
			species Performer aspect: base ;
			species Stage aspect: base ;
			species Guest aspect: base ;
		
		}
	}
}