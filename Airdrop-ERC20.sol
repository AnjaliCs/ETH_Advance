// SPDX-License-Identifier : MIT
pragma solidity^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Airdrop is ERC20 {

    address admin;
    uint256 public maxAirdropAmount;
    uint256 public currentAirdropAmount;
    address[] public airdropAddressList;
    uint256[] public airdropAmountList;

    mapping(address => bool) public processedAirdrop;
    event airdropProcessed(address participant, uint256 amount, uint256 date);

    constructor() ERC20("LTP Tokens", "LTP") {
        _mint(msg.sender, 1000*10**18);
        admin = msg.sender;
        maxAirdropAmount = (2 * totalSupply()) / 10; // Maximum airdrop amount is allocated to 20% of the totalSupply. 
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation!");
        _;
    }

    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "address cannot be zero!");
        admin = _newAdmin;
    }


    function addUsersForAirdrop(address _user, uint256 _amount) external onlyAdmin {
        require(_amount != 0, "Amount cannot be zero!");
        airdropAddressList.push(_user);
        airdropAmountList.push(_amount);
    }


    function removeUserForAirdrop(address _user) external onlyAdmin {
        require(_user != address(0), "User address cannot be zero");

        for(uint i; i < airdropAddressList.length; i++) {
            if(_user == airdropAddressList[i]) {
                airdropAddressList[i] = airdropAddressList[airdropAddressList.length - 1];
                airdropAmountList[i] = airdropAmountList[airdropAmountList.length - 1];
                airdropAddressList.pop();
                airdropAmountList.pop();
            }
        }
    }

    function deleteAirdropList() external onlyAdmin {
        delete airdropAddressList;
        delete airdropAmountList;
    }

    function mint(address to, uint256 amount) external onlyAdmin {
        _mint(to, amount);
    }

    function burn(uint amount) external  {
        _burn(msg.sender, amount);
    }


    function claimToken(address recipient) external {
        uint256 index;
        uint256 flag = 1;
        require(processedAirdrop[recipient] == false, "Airdrop already processed for this address");
        for(uint i; i  < airdropAddressList.length; i++) {
            if(airdropAddressList[i] == recipient)  {
                index = i;
                flag = 0;
                break;
            }
        }
        require(flag == 0 || airdropAddressList[index] == recipient, "This user is not eligible for the airdrop");
        require(currentAirdropAmount +  airdropAmountList[index] <= maxAirdropAmount, "Airdropped 100% of the allocated amount");
        processedAirdrop[recipient] = true;
        currentAirdropAmount +=  airdropAmountList[index];
        transferFrom(admin, recipient, airdropAmountList[index]);
        emit airdropProcessed(recipient, airdropAmountList[index], block.timestamp);
    }



    function getMaxAirdropAmount() external view returns(uint256) {
        return maxAirdropAmount;
    }

    function getCurrentAirdropAmount() external view returns(uint256) {
        return currentAirdropAmount;
    }

    function getWhiteListedUsers() external view returns(address[] memory) {
        return airdropAddressList;
    }

    function getAllocatedAmount() external view returns(uint256[] memory) {
        return airdropAmountList;
    }

    function getProcessedAirdrop(address _adr) external view returns(bool) {
        return processedAirdrop[_adr];
    }
}
