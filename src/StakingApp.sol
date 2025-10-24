// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {
    struct StakingUser {
        uint totalUserBalance;
        uint lastDepositTimestamp;
    }

    address stakingTokenAddress;
    uint public stakingPeriod;
    uint rewardPerPeriod;

    mapping(address => StakingUser) userBalances;

    modifier enoughBalance(uint amount_) {
        _enoughBalance(amount_);
        _;
    }

    modifier hasBalance() {
        _hasBalance();
        _;
    }

    modifier validAmount(uint amount_) {
        _validAmount(amount_);
        _;
    }

    event onChangeStakingPeriod(uint newPeriod_);
    event onWithdrawTokens(uint amount_);
    event onReceiveEther(uint amount_);

    constructor(
        address stakingTokenAddress_,
        uint stakingPeriod_,
        uint rewardPerPeriod_
    ) Ownable(msg.sender) {
        stakingTokenAddress = stakingTokenAddress_;
        stakingPeriod = stakingPeriod_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    receive() external payable onlyOwner {
        require(msg.value > 0, "Invalid amount");
        emit onReceiveEther(msg.value);
    }

    // function loadEther() public payable onlyOwner {}

    function depositTokens(uint amount_) public validAmount(amount_) {
        IERC20(stakingTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount_
        );

        //Use storage to refer the object
        StakingUser storage userData = userBalances[msg.sender];

        userData.totalUserBalance += amount_;
        userData.lastDepositTimestamp = block.timestamp;
    }

    function withdrawTokens(uint amount_) public enoughBalance(amount_) {
        StakingUser storage userData = userBalances[msg.sender];

        userData.totalUserBalance -= amount_;

        IERC20(stakingTokenAddress).transfer(msg.sender, amount_);

        emit onWithdrawTokens(amount_);
    }

    function changeStakingPeriod(uint newStakingPeriod_) public onlyOwner {
        stakingPeriod = newStakingPeriod_;

        emit onChangeStakingPeriod(newStakingPeriod_);
    }

    function claimReward() public hasBalance {
        //Verify elapse period
        StakingUser storage userData = userBalances[msg.sender];
        uint userDepositTimestamp = userData.lastDepositTimestamp;

        uint period = block.timestamp - userDepositTimestamp;
        require(period >= stakingPeriod, "Need to wait");

        //update state
        userData.lastDepositTimestamp = block.timestamp;

        //send reward
        (bool result, ) = msg.sender.call{value: rewardPerPeriod}("");
        require(result, "Transaction failed");
    }

    function getMyStakingBalance() public view returns (uint amount) {
        amount = userBalances[msg.sender].totalUserBalance;
    }

    function getMyLastStakingTimestamp() public view returns (uint timestamp) {
        timestamp = userBalances[msg.sender].lastDepositTimestamp;
    }

    function _enoughBalance(uint amount_) internal view {
        uint userBalance = userBalances[msg.sender].totalUserBalance;
        require(userBalance >= amount_, "Don't enough balance");
    }

    function _hasBalance() internal view {
        uint userBalance = userBalances[msg.sender].totalUserBalance;
        require(userBalance > 0, "User without balance");
    }

    function _validAmount(uint amount_) internal pure {
        require(amount_ > 0, "Invalid amount");
    }
}
