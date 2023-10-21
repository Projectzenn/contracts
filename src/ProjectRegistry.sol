// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";


import "./Project.sol";
contract ProjectRegistry is Ownable(msg.sender) {
    
   address[] public projects;
    
    
    event ProjectCreated(string name, string image, string details, address creator, address projectAddress);
    
    //we want to integrate tokenbound accounts within the company registry
    constructor() {}
    
    //make sure that we add the copmany here already 
    function createProject(string memory _name, string memory _image, string memory _details) public  {
        ProjectContract newProject = new ProjectContract(_name, _details);
        emit ProjectCreated(_name, _image, _details, msg.sender, address(newProject));
    }


    //Option to transfer it to a DAO to fulfill full decentralization on the contract
    function transferToDAO(address daoAddress) external onlyOwner {
        transferOwnership(daoAddress);
    }
}