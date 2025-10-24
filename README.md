# 🪙 Staking App - Solidity Project

This project is a **Staking Application** built in **Solidity** that allows users to stake tokens, earn ether rewards over time, and manage their staking balances.  

The project includes two smart contracts: **StakingApp** (main logic) and **StakingToken** (the ERC20 token used for staking).  
All features were tested using **Foundry**.

---

## 🧱 Project Overview

| Contract | Description |
|-----------|--------------|
| **StakingApp** | Main contract that manages deposits, staking periods, and reward claiming. |
| **StakingToken** | ERC20 token used by users to stake and receive rewards. |

---

## ⚙️ Main Variables

| Variable | Type | Description |
|-----------|------|-------------|
| `mapping(address => StakingUser) userBalances` | `mapping` | Stores each user’s staking information, including balance and timestamp. |

---

## 🔒 Modifiers

| Modifier | Description |
|-----------|-------------|
| `enoughBalance` | Ensures that the user has enough tokens to perform the requested operation. |
| `hasBalance` | Checks that the user currently has a staked balance before claiming rewards. |
| `validAmount` | Ensures that the staking amount is valid (greater than zero). |

---

## 🧩 Main Functions

| Function | Visibility | Description |
|-----------|-------------|-------------|
| `receive()` | `external payable onlyOwner` | Allows the contract owner to receive Ether if needed. |
| `depositTokens(uint amount_)` | `public validAmount(amount_)` | Allows users to stake tokens. The amount must be valid and greater than zero. |
| `changeStakingPeriod(uint newStakingPeriod_)` | `public onlyOwner` | Allows the owner to change the staking period duration. |
| `claimReward()` | `public hasBalance` | Allows users to claim their staking rewards, but only after the required staking time has passed. |
| `getMyStakingBalance()` | `public view returns (uint amount)` | Returns the amount of tokens the user has currently staked. |
| `getMyLastStakingTimestamp()` | `public view returns (uint timestamp)` | Returns the timestamp of the user's last staking action. |

---

## 🧠 Reward Logic

- Users stake tokens using `depositTokens`.  
- After the defined staking period, they can call `claimReward()` to receive their reward.  
- Rewards can only be claimed if the user has staked for the full staking duration.  

---

## 🧪 Testing

All functions and logic were **tested using Foundry**, ensuring reliable staking, claiming, and modifier behavior.

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|----------|
| **Solidity** | Smart contract development. |
| **Foundry** | Testing and deployment framework. |


---

## ✨ Summary

The **Staking App** demonstrates:
- Implementation of **staking logic** with time-based rewards.  
- Usage of **modifiers** for validation and access control.  
- Integration with an **ERC20 staking token**.  
- Comprehensive testing using **Foundry**.

---

## 🧑‍💻 Author

Created by **Julio** to showcase Solidity skills and best practices in staking mechanisms.
