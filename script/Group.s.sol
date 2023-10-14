// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Script, console2} from "forge-std/Script.sol";
import "../src/GroupToken.sol";

    

contract GroupScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console2.log("Account: ", account);
        vm.startBroadcast(privateKey);
        //deploy the tokencontract
        address accountImplementation = vm.parseAddress("0x2d25602551487c3f3354dd80d76d54383a243358");
        address accountRegistry = vm.parseAddress("0x02101dfB77FDE026414827Fdc604ddAF224F0921");
        GroupToken group = new GroupToken(accountRegistry, accountImplementation, "MyGroup", "https://careerzen.org/images/careerzen.png");
        
       group.addAchievement("descriptionlink", false);

       
        
        
        vm.stopBroadcast();
        
        
    }
}
