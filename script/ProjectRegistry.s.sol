// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ProjectRegistry.sol";


contract ProjectRegistryScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console2.log("Account: ", account);
        vm.startBroadcast(privateKey);
        //deploy the tokencontract
        
        //the following values need to be added. 
        
        ProjectRegistry project = new ProjectRegistry();
        //string memory _name, string memory _image, string memory _details
        project.createProject("ETH Online Hackathon", "bafkreidbtwqczfziwwgrsgttuuhgoo5dlm2uhql3g7ab3lp7y6ehsegtte", "bafkreife2ztu4oe4k2jjml5ohq2z2hpvle53xmgpxpiwqr4wiwg7kvanpe");
        
        vm.stopBroadcast();
        
        
    }
}
