// SPDX-License-Identifier : MIT;
pragma solidity^0.8.0;

contract Lottery {
    address owner;
    address payable[] public players;
    address payable public winner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable{
        require(msg.value == 1000000000000, "Please pay 0.000001 AVAX");
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint256) {
        require(msg.sender == owner, "You are not the owner");
        return address(this).balance;
    }

    function random() internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function allPlayers() public view returns(address payable[] memory) {
        return players;
    }

    function pickWinner() public {
        require(msg.sender == owner, "Only owner can pick winner!");
        require(players.length >= 3, "Minimum 3 players are required!");
        uint256 r = random();
        uint256 index = r%players.length;
        winner = players[index];
        winner.transfer(getBalance());
        players = new address payable[](0);
    }
}
