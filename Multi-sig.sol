// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

   contract MultiSigWallet {
       event Deposit(address indexed sender, uint amount);
       event Submit(uint indexed txId);
       event Approve(address indexed owner, uint indexed txId);
       event Revoke(address indexed owner, uint indexed txId);
       event Execute(uint indexed txId);

       
       // Structure to store transactions
       struct Transaction {
           address to;
           uint value;
           bytes data;
           bool executed;
       }

       address[] public owners;    // storing the owners of multi-sig wallet in owners array
       uint public required;       // required no. of owners for approval


       // Mapping to check if msg.sender is one of the owners
       mapping(address => bool) public isOwner;  
       
       // Storing the transactions data in transaction array
       Transaction[] public transactions;


       // Mapping to check if the tx is approved by the owner or not
       mapping(uint => mapping(address => bool)) public approved;


       modifier onlyOwner() {
           require(isOwner[msg.sender], "You are not the owner");
           _;
       }

       modifier txExists(uint _txId) {
           require(_txId < transactions.length, "Transaction doesn't exist");
           _;
       }

       modifier notApproved(uint _txId) {
           require(!approved[_txId][msg.sender], "Transaction already approved");
           _;
       }

       modifier notExecuted(uint _txId) {
           require(!transactions[_txId].executed, "Transaction already executed");
           _;
       }

       constructor(address[] memory _owners, uint _required) {
           require(_owners.length > 0, "Owners required!");     
           require(_required > 0 && _required <= _owners.length, "Invalid required no. of owners");

           for (uint i; i< _owners.length; i++) {   // for new owner
               address owner = _owners[i];

               require(owner != address(0), "Invalid owner");
               require(!isOwner[owner], "Owner is not unique");

               isOwner[owner] = true;    // inserting the new owner into isOwner mapping
               owners.push(owner);       // adding the owner into owners array
           }

           required = _required;

       }

       receive() external payable{
           emit Deposit(msg.sender, msg.value);
       }


       function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
           transactions.push(Transaction({    // Pushing all the params into transactions array
               to: _to,
               value: _value,
               data: _data,
               executed: false
           }));
           emit Submit(transactions.length -1);   // Emitted the Submit event, the 1st txId should be 0
       }


       function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
           approved[_txId][msg.sender] = true;    // tx sent by msg.sender is approved
           emit Approve(msg.sender, _txId);
       }

       
       // Function to count the no.of approvals by giving the txId
       function _getApprovalCount(uint _txId) private view returns(uint count) {
           for (uint i; i < owners.length; i++) {
               if (approved[_txId][owners[i]]) {   // if tx is approved by the owner[i]
                   count += 1;                     // will update the count by 1
               }
           }
       }


       function execute(uint _txId) external txExists(_txId) notExecuted(_txId) {
           require(_getApprovalCount(_txId) >= required, "approvals < required");
           Transaction storage transaction = transactions[_txId];

           transaction.executed = true;

           (bool success, ) = transaction.to.call{value: transaction.value}(
               transaction.data
           );

           require(success, "Transaction failed");
           emit Execute(_txId);
       }


       function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
           require(approved[_txId][msg.sender], "Transaction not approved");
           approved[_txId][msg.sender] = false;  // tx by msg.sender is not approved 
           emit Revoke(msg.sender, _txId);
       }
   }
