// PrizeManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PrizeManager
 * @dev Manages prize pools, distributions, and random winner selection.
 */
contract PrizeManager is Ownable {
    // Prize pools
    uint256 public superPrize;
    uint256 public highPrize;
    uint256 public middlePrize;
    uint256 public lowPrize;

    // Dividends
    uint256 public ownerDividend;
    uint256 public developerDividend;

    // Prize distribution settings
    uint256 public prizeScale = 10;
    uint256 private lastPrizeScaleUpdate;

    // Flags for dividend withdrawal
    bool public distributeOwnerDividends = false;
    bool public distributeDeveloperDividends = false;

    address public nasicoinToken;

    mapping(address => uint256) public releasedTokens;

    // Events
    event PrizePoolsUpdated(uint256 superPrize, uint256 highPrize, uint256 middlePrize, uint256 lowPrize);
    event DividendsUpdated(uint256 ownerDividend, uint256 developerDividend);
    event PrizeScaleUpdated(uint256 newPrizeScale);
    event PrizesDistributed(uint256 superPrizeWinners, uint256 highPrizeWinners, uint256 middlePrizeWinners, uint256 lowPrizeWinners);
    event WeeklyReport(
        uint256 totalInvested,
        uint256 weeklyProfit,
        uint256 lowPrizeRemaining,
        uint256 middlePrizeRemaining,
        uint256 highPrizeRemaining,
        uint256 superPrizeRemaining
    );
    event TokensMintedToUsers(uint256 totalMinted);

    /**
     * @notice Constructor to initialize the contract with an initial owner.
     * @param initialOwner Address of the initial owner.
     */
    constructor(address initialOwner, address _nasicoinToken) Ownable(initialOwner) {
        require(_nasicoinToken != address(0), "Invalid NASICOIN token address");
        nasicoinToken = _nasicoinToken;
    }

    /**
     * @notice Updates the prize pools and dividends based on weekly profits.
     * @param profits Total profits accumulated over the week.
     */
    function updatePrizePools(uint256 profits) external onlyOwner {
        require(profits > 0, "No profits to distribute");

        uint256 prizeShare = (profits * 50) / 100; // 50% for prize pools
        uint256 dividendShare = (profits * 5) / 100; // 5% for each dividend

        // Update prize pools
        superPrize += (prizeShare * 10) / 100; // 10% to super prize
        highPrize += (prizeShare * 10) / 100; // 10% to high prize
        middlePrize += (prizeShare * 10) / 100; // 10% to middle prize
        lowPrize += (prizeShare * 10) / 100; // 10% to low prize

        // Update dividends
        ownerDividend += dividendShare;
        developerDividend += dividendShare;

        emit PrizePoolsUpdated(superPrize, highPrize, middlePrize, lowPrize);
        emit DividendsUpdated(ownerDividend, developerDividend);
    }

    /**
     * @notice Internal function to mint all accumulated tokens to users and resets their balances in the releasedTokens mapping.
     */
    function _mintTokensToUsers() internal {
        uint256 totalMinted = 0;

        for (address account = address(0); account <= address(type(uint160).max); account = address(uint160(account) + 1)) {
            uint256 amount = releasedTokens[account];
            if (amount > 0) {
                releasedTokens[account] = 0;
                totalMinted += amount;
                IERC20(nasicoinToken).transfer(account, amount);
            }
        }

        emit TokensMintedToUsers(totalMinted);
    }

    function emitWeeklyReport(uint256 totalInvested, uint256 weeklyProfit) external onlyOwner {
        emit WeeklyReport(
            totalInvested,
            weeklyProfit,
            lowPrize,
            middlePrize,
            highPrize,
            superPrize
        );
    }

    /**
     * @notice External function to be called by other contracts to trigger minting of tokens before a prize draw.
     */
    function prepareForPrizeDraw() external {
        _mintTokensToUsers();
    }
}