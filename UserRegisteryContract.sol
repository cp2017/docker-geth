pragma solidity ^0.4.2;

contract UserRegistry{
    
    mapping (address => address) public userContracts;
    
    function UserRegistry(){

    }

    function setUserContractAddress(address userContractAdd) {
        if(userContracts[msg.sender] == address(0)){
            userContracts[msg.sender] = userContractAdd;
        }
    }
}
