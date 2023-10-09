// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/GroupRegistry.sol";

contract DeployRegistry is GroupRegistry {
    constructor(address _ERC6551Registry, address _ERC6551AccountImplementation)
        GroupRegistry(_ERC6551Registry, _ERC6551AccountImplementation)
    {}
    

    
}
    

contract GroupTokenScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console2.log("Account: ", account);
        vm.startBroadcast(privateKey);
        //deploy the tokencontract
        address accountImplementation = vm.parseAddress("0x2d25602551487c3f3354dd80d76d54383a243358");
        address accountRegistry = vm.parseAddress("0x02101dfB77FDE026414827Fdc604ddAF224F0921");
        GroupRegistry registry = new GroupRegistry(accountRegistry, accountImplementation);
        
       registry.createGroup("Careerzen", "https://careerzen.org/images/careerzen.png", "https://api.careerzen.org");
       registry.createGroup("Polygon Team", "https://careerzen.org/images/careerzen.png", "https://api.careerzen.org");
       registry.createGroup("Careerzen Hack Team", "https://careerzen.org/images/careerzen.png", "https://api.careerzen.org");

       
        
        
        vm.stopBroadcast();
        
        
    }
}
