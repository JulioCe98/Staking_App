// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingApp.sol";
import "../src/StakingToken.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract StakingAppTest is Test {
    StakingApp stakingApp;
    StakingToken stakingToken;

    address user = vm.addr(1);
    uint stakingPeriod = 24;
    uint rewardPerPeriod = 1;

    function setUp() public {
        stakingToken = new StakingToken("StakingToken", "STK");
        stakingApp = new StakingApp(
            address(stakingToken),
            stakingPeriod,
            rewardPerPeriod
        );
    }

    function testLoadValidEther() public {
        vm.deal(address(this), 5 ether);
        //    stakingApp.loadEther{value: 1 ether}();

        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        uint etherToDeposit = 1 ether;
        (bool result, ) = address(stakingApp).call{value: etherToDeposit}("");

        uint stakingAppNewBalance = address(stakingApp).balance;
        assert(result);
        assert(stakingAppNewBalance - stakingAppOldBalance == etherToDeposit);
    }

    function testLoadInvalidEther() public {
        vm.deal(address(this), 5 ether);

        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        uint etherToDeposit = 0;
        // vm.expectRevert("Invalid amount");
        (bool result, ) = address(stakingApp).call{value: etherToDeposit}("");
        assertFalse(result);
    }

    function testLoadEtherDifferentUser() public {
        vm.startPrank(user);

        vm.deal(user, 5 ether);

        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        uint etherToDeposit = 1 ether;

        (bool result, ) = address(stakingApp).call{value: etherToDeposit}("");
        assertFalse(result);

        vm.stopPrank();
    }

    function testDepositTokensValidAmount() public {
        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        uint stakingAppTokensBeforeDeposit = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint stakingAppTokensBalanceAfterDeposit = IERC20(stakingToken)
            .balanceOf(address(stakingApp));
        assert(
            stakingAppTokensBalanceAfterDeposit -
                stakingAppTokensBeforeDeposit ==
                tokensToDeposit
        );

        vm.stopPrank();
    }

    function testDepositTokensInvalidAmount() public {
        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 0;
        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        vm.expectRevert("Invalid amount");
        stakingApp.depositTokens(tokensToDeposit);

        vm.stopPrank();
    }

    function testDepositNoTokens() public {
        vm.startPrank(user);

        uint userTokensBalance = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalance == 0);

        uint tokensToDeposit = 500;
        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        vm.expectRevert();
        stakingApp.depositTokens(tokensToDeposit);

        vm.stopPrank();
    }

    function testWithdrawTokens() public {
        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint userTokensBalanceAfterDeposit = IERC20(stakingToken).balanceOf(
            user
        );
        assert(
            userTokensBalanceAfterMint - userTokensBalanceAfterDeposit ==
                tokensToDeposit
        );

        uint stakingAppTokensBalance = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint amountToWithdraw = 250;
        stakingApp.withdrawTokens(amountToWithdraw);

        uint newUserBalance = stakingApp.getMyStakingBalance();

        assert(currentUserBalance - newUserBalance == amountToWithdraw);

        uint stakingAppTokensNewBalance = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );
        assert(
            stakingAppTokensBalance - stakingAppTokensNewBalance ==
                amountToWithdraw
        );

        uint userTokensBalanceAfterWithdraw = IERC20(stakingToken).balanceOf(
            user
        );
        assert(
            userTokensBalanceAfterWithdraw + amountToWithdraw ==
                userTokensBalanceAfterMint
        );

        vm.stopPrank();
    }

    function testCantWithdrawTokensDueDontEnoughBalance() public {
        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint userTokensBalanceAfterDeposit = IERC20(stakingToken).balanceOf(
            user
        );
        assert(
            userTokensBalanceAfterMint - userTokensBalanceAfterDeposit ==
                tokensToDeposit
        );

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint tokensToWithdraw = 1000;
        vm.expectRevert("Don't enough balance");
        stakingApp.withdrawTokens(tokensToWithdraw);

        vm.stopPrank();
    }

    function testCantWithdrawTokensNotDeposit() public {
        vm.startPrank(user);

        uint tokensToWithdraw = 1000;
        vm.expectRevert("Don't enough balance");
        stakingApp.withdrawTokens(tokensToWithdraw);

        vm.stopPrank();
    }

    function testChangeStakingPeriodWithOwner() public {
        assert(stakingApp.stakingPeriod() == stakingPeriod);

        uint newStakingPeriod = 48;
        stakingApp.changeStakingPeriod(newStakingPeriod);

        assert(stakingApp.stakingPeriod() == newStakingPeriod);
    }

    function testChangeStakingPeriodWithoutOwner() public {
        vm.startPrank(user);

        assert(stakingApp.stakingPeriod() == stakingPeriod);

        uint newStakingPeriod = 48;
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod);

        vm.stopPrank();
    }

    function testClaimReward() public {
        vm.deal(address(this), 5 ether);

        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        uint etherToDeposit = 1 ether;
        (bool result, ) = address(stakingApp).call{value: etherToDeposit}("");

        uint stakingAppNewBalance = address(stakingApp).balance;
        assert(result);
        assert(stakingAppNewBalance - stakingAppOldBalance == etherToDeposit);

        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        uint stakingAppTokensBeforeDeposit = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint stakingAppTokensBalanceAfterDeposit = IERC20(stakingToken)
            .balanceOf(address(stakingApp));
        assert(
            stakingAppTokensBalanceAfterDeposit -
                stakingAppTokensBeforeDeposit ==
                tokensToDeposit
        );

        uint currentTimestamp = stakingPeriod + 1;
        vm.warp(currentTimestamp);

        stakingApp.claimReward();

        uint userLastTimestamp = stakingApp.getMyLastStakingTimestamp();
        assert(userLastTimestamp == currentTimestamp);

        assert(user.balance == rewardPerPeriod);

        vm.stopPrank();
    }

    function testCantClaimReward() public {
        vm.deal(address(this), 5 ether);

        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        uint etherToDeposit = 1 ether;
        (bool result, ) = address(stakingApp).call{value: etherToDeposit}("");

        uint stakingAppNewBalance = address(stakingApp).balance;
        assert(result);
        assert(stakingAppNewBalance - stakingAppOldBalance == etherToDeposit);

        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        uint stakingAppTokensBeforeDeposit = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint stakingAppTokensBalanceAfterDeposit = IERC20(stakingToken)
            .balanceOf(address(stakingApp));
        assert(
            stakingAppTokensBalanceAfterDeposit -
                stakingAppTokensBeforeDeposit ==
                tokensToDeposit
        );

        vm.expectRevert("Need to wait");
        stakingApp.claimReward();

        vm.stopPrank();
    }

    function testCantClaimRewardDontEnoughEther() public {
        uint stakingAppOldBalance = address(stakingApp).balance;
        assert(stakingAppOldBalance == 0);

        vm.startPrank(user);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;
        uint stakingAppTokensBeforeDeposit = IERC20(stakingToken).balanceOf(
            address(stakingApp)
        );

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        uint timestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserBalance == tokensToDeposit);
        assert(timestamp == block.timestamp);

        uint stakingAppTokensBalanceAfterDeposit = IERC20(stakingToken)
            .balanceOf(address(stakingApp));
        assert(
            stakingAppTokensBalanceAfterDeposit -
                stakingAppTokensBeforeDeposit ==
                tokensToDeposit
        );

        uint currentTimestamp = stakingPeriod + 1;
        vm.warp(currentTimestamp);

        vm.expectRevert();
        stakingApp.claimReward();

        vm.stopPrank();
    }

    function testGetMyStakingBalance() public {
        vm.startPrank(user);

        uint userBalanceWithoutDeposit = stakingApp.getMyStakingBalance();
        assert(userBalanceWithoutDeposit == 0);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserBalance = stakingApp.getMyStakingBalance();
        assert(currentUserBalance == tokensToDeposit);

        vm.stopPrank();
    }

    function testGetMyLastStakingTimestamp() public {
        vm.startPrank(user);

        uint userLastDepositTimestampWithoutDeposit = stakingApp
            .getMyLastStakingTimestamp();
        assert(userLastDepositTimestampWithoutDeposit == 0);

        uint userTokensBalanceBeforeMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceBeforeMint == 0);

        uint toMint = 1000;
        stakingToken.mint(toMint);

        uint userTokensBalanceAfterMint = IERC20(stakingToken).balanceOf(user);
        assert(userTokensBalanceAfterMint == toMint);

        uint tokensToDeposit = 500;

        IERC20(stakingToken).approve(address(stakingApp), tokensToDeposit);
        stakingApp.depositTokens(tokensToDeposit);

        uint currentUserTimestamp = stakingApp.getMyLastStakingTimestamp();
        assert(currentUserTimestamp == block.timestamp);

        vm.stopPrank();
    }
}
