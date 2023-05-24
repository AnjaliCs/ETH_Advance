//SPDX-License-Identifier : MIT
pragma solidity^0.8.0;

contract PlayZone  {
    address public owner;  // 5% to owner
    address public winner; // 95% to winner
    address[] players;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute!");
        _;
    }

    function getBalance() onlyOwner public view returns(uint256) {
        return address(this).balance;
    }

    function participate() public payable {
        require(msg.value  == 1 ether, "Please pay 1 Ether");
        players.push(msg.sender);
    }

    function allPlayers() public view returns(address[] memory) {
        return players;
    }

    function random() internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public onlyOwner {
        require(players.length >= 3, "Minimum 3 players are required!");
        uint256 r = random();
        uint256 index = r%players.length;
        winner = players[index];
        uint256 bal = address(this).balance;
        uint256 winnerAmount = (bal*95)/100;
        uint256 ownerAmount = (bal*5)/100;
        payable(winner).transfer(winnerAmount);
        payable(owner).transfer(ownerAmount);
        players.pop();
    }
}
