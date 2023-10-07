// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GroupRegistry} from "../src/GroupRegistry.sol";

contract GroupRegistryTest is Test {
    GroupRegistry public groupRegistry;


    function setUp() public {
        address accountRegistry = address(0x1);
        address accountImplementation = address(0x2);
        
        groupRegistry = new GroupRegistry(accountRegistry, accountImplementation);
    }
  /*   

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    } */
}
