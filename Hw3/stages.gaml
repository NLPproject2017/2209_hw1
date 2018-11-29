/**
* Name: stages
* Author: Henrietta
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model stages

/* Insert your model definition here */

global {
	bool init<-false;
	
	int numberOfGuests<-2;
	int nrOfStages<-4;
	int numberOfPerformers<-nrOfStages;
	//float waitStep <- 15 #mn;
	
	list<list> performances<- [['Rock Brothers',0.3],['Made in iron',0.1],['Sellby & co',0.1],['Hippie carousel',0.3],['Ricky', 0.2],['Information',0.1],['Rock legends',0.3]];
	//location, band
	list<list> currentStagePerformances;
	//list<point> stage_locations;
	list<point> stages;
	
	init {
		create Stage number: nrOfStages {
			location<-{rnd(1,100),rnd(1,100)};
			//add location to: stage_locations;
			add location to: stages;
			
			soundSystemVersion<-rnd(0.1,0.3);
			lightSystemVersion<-rnd(0.1,0.3);
			sizeOfStage<-rnd(5,7);
			pyroTechProbability<-rnd(0.1,0.3);
			reputation<-rnd(0.1,0.3);
			XFactor<-rnd(0.1,0.3);
			//xFactor<-rnd(3);
			
			list<list> performers;
			loop i over: performances{
				
				if(rnd(2)=1){
					//list performanceAtI<-performances[i];
					add i to:performersAtStage;
					//write name + ' will feature '+ i;
				}
				
			}
			//if we were unlucky and no performers wanted to play at the stage
			if (length(performersAtStage)<2){
					//write ' .. and Boring info 1&2';
					add ['Boring information, version 1',0.1] to:performersAtStage;
					add ['Boring information, version 2',0.1] to:performersAtStage;
				}
			
		}
		create Guest number: numberOfGuests {
			soundSystemVersionPreference<-rnd(0.1,0.8);
			lightSystemVersionPreference<-rnd(0.1,0.8);
			bandPreference<-rnd(0.1,0.9);
			pyroTechInterest<-rnd(0.1,0.8);
			reputationInterest<-rnd(0.1,0.8);
			XFactor<- rnd(0.1,0.8);
			mood<-rnd(1,3);
			//myPreference<-soundSystemVersionPreference*lightSystemVersionPreference*bandPreference*pyroTechInterest*reputationInterest*rnd(1,3);
			
		}	
		}
		}
species Guest skills:[moving]{
	//bool blinking<-false;
	rgb mainColor<- #blue;
	//specs
	float soundSystemVersionPreference;
	float lightSystemVersionPreference;
	float bandPreference;
	float pyroTechInterest;
	float reputationInterest;
	float XFactor;
	int mood;
	
	//int myPreference;
	
	bool bored<-true;
	string messageFromStage;
	
	//Stage with best match
	Stage currentTopChoice;
	float currentTopStageValue<-0;
	list<list> utilityValues;
	
	reflex acceptPerformanceFinishedWhenStageSaysSo when: messageFromStage='performance over'{
		write name + ' ÖÖÖÖÖ told by stage that the performance is over';
		messageFromStage<-'';
		currentTopChoice<-nil;
		currentTopStageValue<-0;
		bored<-true;
		
		
		}
	
	reflex askStagesAboutCurrentPerformances when: bored and init{ //start at like cycle 3 to make sure stages have something running
		// reset for next evaluation
		currentTopChoice<-nil;
		currentTopStageValue<-0;
		utilityValues<-nil;
		
		ask Stage{
			
			//Option 2: for calculating individual utlity
			float repUtilityValue<- self.reputation*myself.reputationInterest;
			float soundUtilityValue<- self.soundSystemVersion*myself.soundSystemVersionPreference;
			float lightUtilityValue<-self.lightSystemVersion*myself.lightSystemVersionPreference;
			
			float pyroUtility<-self.pyroTechProbability*myself.pyroTechInterest;
			float utilityXFactor<-self.XFactor*myself.XFactor;
			//if(favBand)
			float bandUtilityValue<-myself.bandPreference;
			float calculatedUtilityValue<-(repUtilityValue+soundUtilityValue+lightUtilityValue+pyroUtility+utilityXFactor+bandUtilityValue);
			add [self,calculatedUtilityValue] to: myself.utilityValues;
			
		}		
				//Option 2
				float mostUtility<-0;
				Stage mostUtilityStage;
				loop utilityValue over: utilityValues{
					float currentValue<-utilityValue[1];
					Stage currentStage<-utilityValue[0];
					// first round
					if(mostUtility=0){
						mostUtility<-utilityValue[1];
						mostUtilityStage<-utilityValue[0];
					}
					// if new one has a higher utility replace
					if(mostUtility<currentValue){
						mostUtility<-currentValue;
						mostUtilityStage<-currentStage;
					}
					//else keep old
					write name + ' Stage: ' + currentStage + ' utilityValue: ' + currentValue;
				}
				currentTopStageValue<-mostUtility; 
				currentTopChoice<-mostUtilityStage;
				
				
				write name + ' Stage: ' + currentTopChoice.name + ' was my prefered option. Value was highest: ' + currentTopStageValue;
				
		//go to performance
		bored<-false;
		
		write name + ' Going there now...';
		
	}
	// go to the stage with the performance I am most interested in
	reflex goToBestPerformance when: !bored{
		
		//write name + ' ' + currentTopChoice + ' fits my preferences better. Value: '+ currentTopStageValue;
		do goto target:currentTopChoice speed: 10.0;
	}
	
	aspect base {
		if(bored){
			draw circle(3) color: #blue ;
		}
		else{
			if(rnd(3)=1){
				draw circle(3) color: #blue ;
			}
			else{
				draw circle(3) color: #red ;
			}
		}
		draw ''+name at: location+{2,-2} color: #black;
	}
}
species Stage {
	//specs
	float soundSystemVersion<-0;
	float lightSystemVersion<-0;
	int sizeOfStage<-0;
	float pyroTechProbability<-0;
	float reputation<-0;
	float XFactor<-0;
	//also depends on band
	
	float currentStageValue<-0;//(soundSystemVersion*lightSystemVersion*sizeOfStage*pyroTechProbability*reputation*XFactor)/10;
	string currentPerformer;
	
	list<list> performersAtStage;
	bool onGoing<-false;
	
	aspect base {
		draw square(sizeOfStage) color: #green ;
		draw name at: location+{2,-3} color:#black;
		//option 1
		//draw ''+currentStageValue at: location color:#black;
		
	}
	
	//performances
	bool stageIdle<-true;
	bool newBandReady<-false;
	bool performanceOngoing<-false;
	
	reflex idleBetweenPerformances when: stageIdle{
		//write name + ' no performance at the moment';
		// reinstall system versions
		soundSystemVersion<-rnd(0.1,0.8);
		lightSystemVersion<-rnd(0.1,0.5);
		pyroTechProbability<-rnd(0.1,0.8);
		//int sizeOfStage<-0;
		reputation<-rnd(0.1,0.3);
		XFactor<-rnd(0.1,0.3);
		
		currentPerformer<-(performersAtStage[0])[0];
		//write name + ' next performer will be: '+currentPerformer;
		// loop performances
		remove currentPerformer from: performersAtStage;
		add currentPerformer to: performersAtStage;
		
		//wait a few seconds
		//----
		if(rnd(1,15)=1){
		newBandReady<-true;
		stageIdle<-false;
}
		
	}
	
	// select a new performance
	reflex newBandOnStage when:newBandReady{
		newBandReady<-false;
		//at least one active stage
		init<-true;

		//calculate current stage value
		float currentBandHype<-(performersAtStage[0])[1];
		
		write name + ' new band on stage! '+currentPerformer+ ' Sound system version: '+ soundSystemVersion+ ' Lisgt system version: '+ lightSystemVersion ;
		//write name + ' NEW value: ' + currentStageValue;
		
		performanceOngoing<-true;
		
	}
	// run for a while then tell guests its over
	reflex activelyPlaying when: performanceOngoing{
		list<Guest> guestsAtStage <- (Guest at_distance 2);
		if(!empty(guestsAtStage)){
			write name + ' Playing now! guests listening ' +guestsAtStage;
		}
		if(rnd(15)=1){
			performanceOngoing<-false;
			stageIdle<-true;
			//write name + ' performance finished';
			
			// tell all guests that it is over
			ask guestsAtStage{
				
				self.messageFromStage<-'performance over';
				}
			}
		}
	}


experiment main type: gui {
	parameter "Number of Stages" var: nrOfStages min: 1 max: 10 category: "Stages" ;
	parameter "Number of Guests" var: numberOfGuests min: 1 max: 100 category: "Guests" ;
	output {
		display main_display {
			//species Performer aspect: base ;
			species Stage aspect: base ;
			species Guest aspect: base ;
		
		}
	}
}