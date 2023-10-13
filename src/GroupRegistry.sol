// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";


import "./GroupToken.sol";
contract GroupRegistry is Ownable(msg.sender) {
    
   
    address public accountRegistry;
    address public accountImplementation;
    uint256 public companyCount;
     // Array to store addresses of all created billboard contracts
    GroupToken[] public groups;

    // Array to store addresses of billboards pending approval
    GroupToken[] public pendingCompany;
    
    
    event GroupCreated(uint256 companyId, string name, string image, string details, address creator, address addr);
    event CompanyAccepted(address accepted, address company);
    event CompanyRejected(uint256 indexed companyId, string indexed name);
    event CompanyRemoved(uint256 indexed companyId, address company, address indexed remover);
    
    
    //we want to integrate tokenbound accounts within the company registry
    constructor(address _accountRegistry, address _accountImplementation) {
        
        accountImplementation = _accountImplementation;
        accountRegistry = _accountRegistry;
    }
    
    //make sure that we add the copmany here already 
    function createGroup(string memory _name, string memory _image, string memory _details) public  {
        
        GroupToken newGroup = new GroupToken(accountImplementation, accountRegistry, _name, _image, _details);
        //address of the newCompany 
        pendingCompany.push(newGroup);
        emit GroupCreated(companyCount, _name, _image, _details, msg.sender, address(newGroup));
    }
    
 
    function getTotalGroups() external view returns (uint256) {
        return groups.length;
    }

    function getTotalPendingGroups() external view returns (uint256) {
        return pendingCompany.length;
    }

    //Option to transfer it to a DAO to fulfill full decentralization on the contract
    function transferToDAO(address daoAddress) external onlyOwner {
        transferOwnership(daoAddress);
    }
}