// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    address user = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken("StakingToken", "STK");
    }

    function testMint() public {
        vm.startPrank(user);

        assert(stakingToken.balanceOf(user) == 0);
        stakingToken.mint(1 ether); //1 * 10e18
        assert(stakingToken.balanceOf(user) == 1e18);

        vm.stopPrank();
    }
}
