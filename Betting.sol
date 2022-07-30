// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

   contract Betting {
       address payable public owner;
       uint public minBet;
       uint public totalBetsOne;
       uint public totalBetsTwo;
       address payable[] public players;

       struct Player {
           uint betAmount;
           uint16 teamSelected;
       }

       function deposit() external payable {}

       //Mapping user address to user info (struct Player)
       mapping(address => Player) public playersInfo;

       constructor() {
           owner = payable(msg.sender);
           minBet = 100000000000000;  //0/0001 Eth
       }


       //Function to check player exists or not
       function checkPlayerExists(address player) public view returns(bool) {
           for(uint i = 0; i < players.length; i++){
               if(players[i] == player) {
                   return true;
               }
               return false;
           }
       }

      
       // Function to create a bet
       function bet(uint8 _teamSelected) public payable {
           require(!checkPlayerExists(payable(msg.sender))); // check if the user is already played
           require(msg.value >= minBet);  // The amount sent by the user should be greater than minbet amount

           // Adding in player info, betAmount and selectedteam
           playersInfo[msg.sender].betAmount = msg.value;
           playersInfo[msg.sender].teamSelected = _teamSelected;

           // Adding the address of the player to players arrary
           players.push(payable(msg.sender));

           
           // Updating the stakes of the selected team with player's bet
           if(_teamSelected ==1){
               totalBetsOne += msg.value;
           } 
           else {
               totalBetsTwo += msg.value;
           }
       }


       // Function to give rewards
       function rewardDistribution(uint16 teamWinner) public {
           address payable[1000] memory winners;

           uint count = 0;      // counts the array of winners
           uint loserBet = 0;   // counts losers
           uint winnerBet = 0;  // counts winners

           address add;
           uint256 bet;
           address payable playerAddress;

           // looping through the players array to check who selected the winner team
           for(uint i=0; i < players.length; i++){
               playerAddress = players[i];

               // if winner team selected, add this to winners array
               if(playersInfo[playerAddress].teamSelected == teamWinner){
                   winners[count] = playerAddress;
                   count++;
                }
           }

           if(teamWinner == 1){
               loserBet = totalBetsTwo;
               winnerBet = totalBetsOne;
           }
           else{
               loserBet = totalBetsOne;
               winnerBet = totalBetsTwo;
           }

           // looping through the array of winner to give reward to winner
           for(uint j=0; j < count; j++){

               // address in the fixed array should not be empty
               if(winners[j] != address(0)){
                   add = winners[j];
                   bet = playersInfo[add].betAmount;

                   // transferring eth to the winner
                   winners[j].transfer((bet*(10000+(loserBet*10000/winnerBet)))/10000);
               }
           }

           delete playersInfo[playerAddress];  // deleting the players array
           //players.length = 0;
           loserBet = 0;   // reinitializing the bet
           winnerBet = 0;
           totalBetsOne = 0;
           totalBetsTwo = 0;       
       }
       
       function AmountOne() public view returns(uint){
           return totalBetsOne;
        }
        
        function AmountTwo() public view returns(uint){
            return totalBetsTwo;
        }

   }
