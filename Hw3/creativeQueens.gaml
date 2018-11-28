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
			
			soundSystemVersion<-rnd(1,5);
			lightSystemVersion<-rnd(1,5);
			sizeOfStage<-rnd(10,20);
			pyroTechProbability<-rnd(1,3);
			reputation<-rnd(1,5);
			XFactor<-rnd(1,2);
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
					add ['Boring information, version 1',1] to:performersAtStage;
					add ['Boring information, version 2',1] to:performersAtStage;
				}
			
		}
		create Guest number: numberOfGuests {
			soundSystemVersionPreference<-rnd(1,3);
			lightSystemVersionPreference<-rnd(1,3);
			bandPreference<-rnd(1,3);
			pyroTechInterest<-rnd(1,3);
			reputationInterest<-rnd(1,3);
			XFactor<- rnd(1,3);
			mood<-rnd(1,2);
			myPreference<-soundSystemVersionPreference*lightSystemVersionPreference*bandPreference*pyroTechInterest*reputationInterest*rnd(1,3);
			
		}	
		}
		}
species Guest skills:[moving]{
	//bool blinking<-false;
	rgb mainColor<- #blue;
	//specs
	int soundSystemVersionPreference;
	int lightSystemVersionPreference;
	int bandPreference;
	int pyroTechInterest;
	int reputationInterest;
	int XFactor;
	int mood;
	
	int myPreference;
	
	bool bored<-true;
	string messageFromStage;
	
	//Stage with best match
	Stage currentTopChoice;
	int currentTopStageValue<-0;
	list<list> utilityValues;
	
	//mood 1 = wants to go to a performance
	reflex mood when: mood!=1{
		
		// feels like doing something else than go to a stage
		if(mood=2){
			do wander amplitude: 2;
			write name + ' in a BAD mood.. ';
			mainColor<-#yellow;
			}
			if(rnd(1,10)=1){
				write name + ' in a GOOD mood again!.. ';
				mood<-1; //we want to go to a performance again
				mainColor<-#blue;
			}
		}
		/*if(mood=3){
			if(rnd(1,30)){
				
		}
	}*/
	
	reflex acceptPerformanceFinishedWhenStageSaysSo when: messageFromStage='performance over'{
		write name + ' told by stage that the performance is over';
		messageFromStage<-'';
		bored<-true;
		
		}
	
	reflex askStagesAboutCurrentPerformances when: bored and init{ //start at like cycle 3 to make sure stages have something running
		// reset for next evaluation
		currentTopChoice<-nil;
		currentTopStageValue<-0;
		
		list<list> stageAndstageValues;
	
		write name+ ' PREFERENCE: ' + myPreference;
	
		
		ask Stage{
			//Option 1
			//write name + 'Asking stages about stageValues';
			//save values to later compare which is the closest one
			write 'adding stage value: ' +currentStageValue+' to stagevalues';
			add [self,self.currentStageValue] to: stageAndstageValues;
			
			
			//Option 2: for calculating individual utlity
			int repUtilityValue<- self.reputation*myself.reputationInterest;
			int soundUtilityValue<- self.soundSystemVersion*myself.soundSystemVersionPreference;
			int lightUtilityValue<-self.lightSystemVersion*myself.lightSystemVersionPreference;
			
			int pyroUtility<-self.pyroTechProbability*myself.pyroTechInterest;
			int utilityXFactor<-self.XFactor*myself.XFactor;
			//if(favBand)
			int bandUtilityValue<-myself.bandPreference;
			int calculatedUtilityValue<-(repUtilityValue+soundUtilityValue+lightUtilityValue+pyroUtility+utilityXFactor+bandUtilityValue)/6;
			add [self,calculatedUtilityValue] to: myself.utilityValues;
			
		}
		//compare values from stages (something wrong with getting the values from llooped list)
		
		//option 1
			//write ' starting evaluation ';
		int globalDiff<-0;
		Stage globalStage<-nil;
			
			loop stageAndStageValue over: stageAndstageValues{
				int diffTemp;
				Stage diffStage;
				write 'INSIDE CHECKING LOOP';
				int stageValue <-stageAndStageValue[1];
				write name + ' stage value in loop: ' + stageValue;
				Stage loopStage <-stageAndStageValue[0];
				//write ' DEBUG: STAGE CANNOT BE NULL, sValue: ' + sValue+ ' loopStage'+ loopStage;
		 		// compare which value is the closest one
		 		// find difference if my preference is a larger number than the stage value
				if(myPreference>stageValue){ 
					write '--myPref större';
					diffTemp<-myPreference-stageValue;
					diffStage<-loopStage;
				}
				// find difference if my preference is a smaller number than the stage value
				else if(myPreference<stageValue){ 
					write '--myPref mindre';
					diffTemp<-stageValue-myPreference;
					diffStage<-loopStage;
				}
				// om de e samma
				else{ 
					write '--myPref 0';
					diffTemp<-0;
					diffStage<-loopStage;
					
				}
				//---
				// if we didnt save a value to compare last value with yet
				if(globalDiff=0){
					write '**globaldiff orginal';
					globalDiff<-diffTemp;
					globalStage<-loopStage;//globalDiff<-sValue;
				}
				// Compare the current(diffTemp) and the last value(globalDiff)
				// larger value s further away, if globalDiff is further away, save diffTemp and stage
				if(globalDiff>diffTemp){
					write '**globaldiff större';
					write name + ' current loop stage was closer: ' + diffStage.name + ' value: ' + diffStage.currentStageValue;
					currentTopStageValue<-stageValue;  //diffTemp;//<- difftemp e en skillnad int ett värde
					currentTopChoice<-diffStage;
					globalDiff<-diffTemp;
					globalStage<-diffStage;
				}
				// otherwise current value is further away and globalTemp is my closest value
				else if(globalDiff<diffTemp){
					//TODO check
					write '**globaldiff mindre';
					write name + ' previous loop stage was closer: ' + globalStage.name + ' value: ' + globalDiff;
					currentTopChoice<-globalStage;
					currentTopStageValue<-globalDiff;
				}
				
				}
				globalDiff<-0;
				
				/*
				//Option 2
				int mostUtility<-0;
				Stage mostUtilityStage;
				loop utilityValue over: utilityValues{
					int currentValue<-utilityValue[1];
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
		write name + ' Going there now...';
		
	}
	// go to the stage with the performance I am most interested in
	reflex goToBestPerformance when: !bored{
		
		//write name + ' ' + currentTopChoice + ' fits my preferences better. Value: '+ currentTopStageValue;
		do goto target:currentTopChoice speed: 6.0;
		
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
		draw ''+myPreference at: location+{2,-2} color: #black;
	}
}
species Stage {
	//specs
	int soundSystemVersion<-0;
	int lightSystemVersion<-0;
	int sizeOfStage<-0;
	int pyroTechProbability<-0;
	int reputation<-0;
	int XFactor<-0;
	//also depends on band
	
	int currentStageValue<-0;//(soundSystemVersion*lightSystemVersion*sizeOfStage*pyroTechProbability*reputation*XFactor)/10;
	string currentPerformer;
	
	list<list> performersAtStage;
	bool onGoing<-false;
	
	aspect base {
		
		if(!onGoing){
			draw square(sizeOfStage) color: #brown ;
		}
		else{
			if(rnd(1,2)=2){
				draw square(sizeOfStage) color: #green ;
			}
		}
		draw name at: location+{2,-3} color:#black;
		draw ''+currentStageValue at: location color:#black;
		
	}
	
	//performances
	bool stageIdle<-true;
	bool newBandReady<-false;
	bool performanceOngoing<-false;
	
	reflex idleBetweenPerformances when: stageIdle{
		//write name + ' no performance at the moment';
		// reinstall system versions
		soundSystemVersion<-rnd(1,3);
		lightSystemVersion<-rnd(1,3);
		pyroTechProbability<-rnd(1,3);
		
		currentPerformer<-(performersAtStage[0])[0];
		//write name + ' next performer will be: '+currentPerformer;
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
		//write name + ' current band hype value: ' +(performersAtStage[0])[1];
			currentStageValue<-(soundSystemVersion*lightSystemVersion*sizeOfStage*pyroTechProbability*reputation*XFactor*currentBandHype)/10;
		
		write name + ' new band on stage! '+currentPerformer+ ' Sound system version: '+ soundSystemVersion+ ' Lisgt system version: '+ lightSystemVersion ;
		write name + ' NEW value: ' + currentStageValue;
		
		performanceOngoing<-true;
		//anounce current performance through list
		//add [location,currentPerformer,soundSystemVersion,lightSystemVersion]to: currentStagePerformances;
		
	}
	// run for a while then tell guests its over
	reflex activelyPlaying when: performanceOngoing{
		
		if(rnd(15)=1){
			performanceOngoing<-false;
			stageIdle<-true;
			//write name + ' performance finished';
			
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