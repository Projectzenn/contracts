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
    
    
    event CompanyAdded(uint256 companyId, string name, string image, string details, address creator, address addr);
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
        
        GroupToken newGroup = new GroupToken(accountImplementation, accountRegistry, _name, _image);
        //address of the newCompany 
        pendingCompany.push(newGroup);
        emit CompanyAdded(companyCount, _name, _image, _details, msg.sender, address(newGroup));
    }
    
    function approveCompany(uint256 index) external onlyOwner(){
        require(index < pendingCompany.length, "Invalid index");
        
        address approvedCompany = address(pendingCompany[index]);
        
        groups.push(pendingCompany[index]);
        
        // Remove from the pending list using similar method as removeBillboard
        if (index != pendingCompany.length - 1) {
            pendingCompany[index] = pendingCompany[pendingCompany.length - 1];
        }
        pendingCompany.pop();

        emit CompanyAccepted(msg.sender, approvedCompany);
    }
    
     function removeCompany(uint256 index) external onlyOwner {
        require(index < groups.length, "Invalid index");

        address removedBillboardAddress = address(groups[index]);

        // Move the last billboard to the slot to delete
        groups[index] = groups[groups.length - 1];
        
        // Remove the last slot
        groups.pop();

        emit CompanyRemoved(index, removedBillboardAddress, msg.sender);
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