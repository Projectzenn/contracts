// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Project.sol";


contract ProjectScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console2.log("Account: ", account);
        vm.startBroadcast(privateKey);
        //deploy the tokencontract
        ProjectContract project = new ProjectContract();
        
        //now we want to be able to update the project immediately 
        //deadline is current block timestamp + 10 days
        project.updateProject("Careerzen", "description url ", "url link", 60 * 60 * 24 * 10);
        
        address member1 = vm.parseAddress("0xfFf09621F09CAa2C939386b688e62e5BE19D2D56");
        address member2 = vm.parseAddress("0xdb1B6961d1F9d1A17C02f23BD186b3bC4f3e7E2A");
        //add in two members with membership role. 
        project.addMember(member1);
        project.addMember(member2);
        
        project.addMilestone("milestone 1", 60 * 60 * 24 * 10);
        
        
        vm.stopBroadcast();
        
        
    }
}
