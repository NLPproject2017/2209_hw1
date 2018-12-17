model participant
import "main.gaml"

species Participant skills: [fipa,moving]{
	
		list<list> interestedToBuyItems;
		list<string> interestedCategories;
		//string category <-first(interestedCategories);
		string proposedItem;
		int proposedPrice;
		int willingPrice;
		bool sold<-false;
		bool busy<-false;
		bool goingToAuction<-false;
		bool atAuction<-false;
		point auctionLocation<-nil;
		
		reflex respond_to_inform when: !empty(informs) and !goingToAuction and !busy{
			message informFromAuctioneer <-(informs at 0);
			
			if (interestedCategories contains informFromAuctioneer.contents[1]){
				do inform with: [message:: informFromAuctioneer, contents:: ['I accept']];
				sold<-false;
				// save to go, we are interested
				auctionLocation <- informFromAuctioneer.contents[2];
				goingToAuction<-true;
				busy<-true;
				// if not busy, can do other things
			} else
			{
				do inform with: [message:: informFromAuctioneer, contents:: ['I reject, not in my interest']];
			}
		}
		reflex goToAuction when: goingToAuction{
			write name + ' going to auction';
			do goto target:auctionLocation speed: 3;
			if(location distance_to auctionLocation<1){
				goingToAuction<-false;
				atAuction<-true;
			}
		}
		reflex respond_to_proposal when: !empty(cfps) and atAuction{
			message proposalFromAuctioneer<- cfps at 0; 
		
			proposedItem <- proposalFromAuctioneer.contents[1];
			proposedPrice <- proposalFromAuctioneer.contents[3];
			
			loop interestItem over: interestedToBuyItems {
				if (interestItem[0] = proposedItem)
				{
					willingPrice <- interestItem[1];
				}
			}
				
			if (willingPrice>=proposedPrice){
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I agree to buy ' + proposedItem + ' from ' +proposalFromAuctioneer.sender + '  for Price:', proposedPrice]];
			} 
			else{
				//TODO: we need to use Refuse, I gues. Then we have to handle refuse messages in Auctioneer as well.
				//do refuse with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy it. Willing To buy:', willingPrice]];
				do propose with: [ message :: proposalFromAuctioneer, contents :: ['I can\'t buy ' + proposedItem + ' from ' +proposalFromAuctioneer.sender + '. Willing To buy:', willingPrice]];
			}
		}
		
		reflex receive_accept_proposals when: !empty(accept_proposals) and !sold{
			loop a over: accept_proposals {
				write name + " said: Hurray, I bought item it from " + a.sender;
				remove a from:accept_proposals;
				sold<-true;
			}
	} 

		aspect base {
		draw circle(1) color: #green ;
	}
	}