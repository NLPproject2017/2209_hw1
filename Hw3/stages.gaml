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
	
	int numberOfGuests<-1;
	int nrOfStages<-2;
	int numberOfPerformers<-nrOfStages;
	//float waitStep <- 15 #mn;
	
	list<list> performances<- [['Rock Brothers',3],['Made in iron',1],['Sellby & co',1],['Hippie carousel',3],['Ricky', 2],['Information',1],['Rock legends',3]];
	//location, band
	list<list> currentStagePerformances;
	//list<point> stage_locations;
	list<point> stages;
	
	init {
		create Stage number: nrOfStages {
			location<-{rnd(1,100),rnd(1,100)};
			//add location to: stage_locations;
			add location to: stages;
			
			soundSystemVersion<-rnd(1,3);
			lightSystemVersion<-rnd(1,3);
			//xFactor<-rnd(3);
			
			list<list> performers;
			loop i over: performances{
				
				//list performer<-i;
				if(rnd(2)=1){
					//list performanceAtI<-performances[i];
					add i to:performersAtStage;
					write name + ' will feature '+ i;
				}
				
			}
			
		}
		create Guest number: numberOfGuests {
			soundSystemVersionPreference<-rnd(1,3);
			lightSystemVersionPreference<-rnd(1,3);
			bandPreference<-rnd(1,3);
			myPreference<-soundSystemVersionPreference*lightSystemVersionPreference*bandPreference;
			
		}	
		}
		}
species Guest skills:[moving]{
	bool atPerformance<-false;
	//specs
	int soundSystemVersionPreference;
	int lightSystemVersionPreference;
	int bandPreference;
	int myPreference;
	
	bool bored<-true;
	string messageFromStage;
	
	//Stage with best match
	Stage currentTopChoice;
	int currentTopStageValue<-0;
	
	reflex acceptPerformanceFinishedWhenStageSaysSo when: messageFromStage='performance over'{
		write name + ' told by stage that the performance is over';
		bored<-true;
		
		}
	
	reflex askStagesAboutCurrentPerformances when: bored and init{
		// reset for next evaluation
		currentTopChoice<-nil;
		currentTopStageValue<-0;
		
		list<list> stageAndstageValues;
		
		write ' soundSystemVersionPreference ' + soundSystemVersionPreference;
		write ' lightSystemVersionPreference ' + lightSystemVersionPreference;
		write ' bandPreference '+bandPreference;
		write 'myPreference ' + myPreference;
		
		int counter <- 1;
		int globalDiff<-0;
		Stage globalStage<-nil;
		
		ask Stage{
			write 'looping stages';
			//save values to later compare which is the closest one
			add [self,self.currentStageValue] to: stageAndstageValues;
		}
		//compare values from stages (something wrong with getting the values from llooped list)
		if(counter = length(stages)){
			int diffTemp;
			Stage diffStage;
			loop stageAndStageValue over: stageAndstageValues{
		 		// compare which value is the closest one
				if(myPreference>stageAndStageValue[1]){ // 10/12
					diffTemp<-myPreference-stageAndStageValue[1];
					diffStage<-stageAndStageValue[0];
				}
				else if(myPreference<stageAndStageValue[1]){ // 10/8
					diffTemp<-stageAndStageValue[1]-myPreference;
					diffStage<-stageAndStageValue[0];
				}
				else{ // om de e samma
					diffTemp<-0;
					diffStage<-stageAndStageValue[0];
				}
				if(globalDiff=0){
					globalDiff<-diffTemp;
					globalDiff<-stageAndStageValue[1];
				}
				// larger value s further away
				if(globalDiff>diffTemp){
					currentTopStageValue<-diffTemp;
					write ' diffstage was smaller';
					currentTopChoice<-diffStage;
					write ' '+ diffStage+' with value: '+ diffTemp+ ' was closer';
				}
				else{
					write ' diffstage was larger stage: ' ;
					currentTopChoice<-globalStage;
					currentTopStageValue<-globalDiff;
					write ' '+ globalStage + ' with value: ' + globalDiff + ' was closer';
				}
				}
				}
				/* 
				//write 'stages length: '+length(stages);
				//what performance is going on at your stage?
				if(myself.currentTopStageValue=0){
					myself.currentTopStageValue<-self.currentStageValue;
					//write '2: myself.currentTopStageValue' + myself.currentTopStageValue;
					myself.currentTopChoice<-self;
				}
				else{
					// if the value I have is closer to my preference keep it otherwise change
					int temp<-myself.myPreference/self.currentStageValue; //the closer to my preference the larger the temp/the smaller the temp
					// if checked value is larger the closest temp will be the larger one 10/11 vs 10/15
					if(self.currentStageValue >myself.myPreference){
						
					}
					// if checked value is smaller the closest temp will be the smaller one 10/9 vs 10/3
					if(self.currentStageValue <myself.myPreference){
						if(temp > myself.currentTopStageValue){
							myself.currentTopStageValue<- temp;
							myself.currentTopChoice<-self;
						}
					}
					// if checked value is smaller the closest temp will be the smaller one 10/5 vs 10/2
					if(temp < myself.currentTopStageValue){
						myself.currentTopStageValue<- temp;
						myself.currentTopChoice<-self;
					}
				}
				
			}*/	
		//}
		//write name + ' Stage: '+currentTopChoice.name +' matched my preferences the best.';
		//write 'StageValue: ' + currentTopChoice.currentStageValue+ ' myValue '+myPreference;
		//go to performance
		bored<-false;
		
	}
	// go to the stage with the performance I am most interested in
	reflex goToBestPerformance when: !bored{
		//write name + ' Going there now...';
		
		do goto target:currentTopChoice speed: 6.0;
		
	}
	
	aspect base {
		draw circle(1) color: #blue ;
	}
}
species Stage {
	//specs
	int soundSystemVersion;
	int lightSystemVersion;
	int xFactor;
	
	int currentStageValue;
	string currentPerformer;
	
	list<list> performersAtStage;
	
	aspect base {
		draw square(5) color: #brown ;
	}
	
	//performances
	bool stageIdle<-true;
	bool newBandReady<-false;
	bool performanceOngoing<-false;
	
	reflex idleBetweenPerformances when: stageIdle{
		write name + ' no performance at the moment';
		// reinstall system versions
		soundSystemVersion<-rnd(1,3);
		lightSystemVersion<-rnd(1,3);
		
		currentPerformer<-(performersAtStage[0])[0];
		write name + ' next performer will be: '+currentPerformer;
		// loop performances
		remove currentPerformer from: performersAtStage;
		add currentPerformer to: performersAtStage;
		
		//wait a few seconds
		//----
		newBandReady<-true;
		stageIdle<-false;
		
	}
	
	// select a new performance
	reflex newBandOnStage when:newBandReady{
		newBandReady<-false;
		//at least one active stage
		init<-true;
		
		//calculate current stage value
		int currentBandHype<-(performersAtStage[0])[1];
		write name + ' current band hype value: ' +(performersAtStage[0])[1];
			currentStageValue<-soundSystemVersion*lightSystemVersion*currentBandHype;
		
		write name + ' new band on stage! '+currentPerformer+ ' Sound system version: '+ soundSystemVersion+ ' Lisgt system version: '+ lightSystemVersion ;
		write name + ' value: ' + currentStageValue;
		
		performanceOngoing<-true;
		//anounce current performance through list
		//add [location,currentPerformer,soundSystemVersion,lightSystemVersion]to: currentStagePerformances;
		
	}
	// run for a while then tell guests its over
	reflex activelyPlaying when: performanceOngoing{
		if(rnd(20)=1){
			performanceOngoing<-false;
			stageIdle<-true;
			write name + ' performance finished';
			
			//its finished
			ask Guest at_distance 2{
				
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