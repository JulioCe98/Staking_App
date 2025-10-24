// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(uint amount_) external {
        _mint(msg.sender, amount_);
    }

    function userBalance() public view returns (uint balance) {
        balance = balanceOf(msg.sender);
    }
}
