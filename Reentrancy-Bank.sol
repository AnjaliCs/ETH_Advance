pragma solidity ^0.8.17;

contract Bank {
    mapping(address => uint) theBalances;
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No-reentrancy!");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        require(msg.value >= 1 ether, "cannot deposit below 1 ether");
        theBalances[msg.sender] += msg.value;
    }

    // removal of noReentrant modifier() can lead to reentrancy-attack
    function withdrawal() public noReentrant {  
        require(theBalances[msg.sender] >= 1 ether, "must have at least one ether");
        uint bal = theBalances[msg.sender];
        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "transaction failed");
        theBalances[msg.sender] -= 0;
    }

    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }
}
