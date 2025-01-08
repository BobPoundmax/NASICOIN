// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IVault {
    function deposit(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract StablecoinVaultManager {
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;

    address public constant YCRV_VAULT = 0x5533ed0a3b83F70c3c4a1f69Ef5546D3D4713E44;

    struct DepositInfo {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => mapping(address => DepositInfo)) public userDeposits;
    mapping(address => uint256) public releasedTokens;

    event DepositMade(address indexed user, address indexed token, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 issuedTokens);

    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant ANNUAL_RATE = 2739726; // Fixed-point representation of 1/365 * 1e18

    function depositToVault(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(token == USDT || token == USDC || token == DAI || token == SUSD, "Unsupported token");

        // Calculate extra tokens for previously held deposits
        DepositInfo storage userInfo = userDeposits[msg.sender][token];
        if (userInfo.amount > 0) {
            uint256 daysHeld = (block.timestamp - userInfo.timestamp) / DAY_IN_SECONDS;
            if (daysHeld > 7) {
                uint256 extraTokens = ((daysHeld - 7) * ANNUAL_RATE * userInfo.amount) / 1e18;
                releasedTokens[msg.sender] += extraTokens;
            }
        }

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(YCRV_VAULT, amount);

        IVault(YCRV_VAULT).deposit(amount);

        userInfo.amount += amount;
        userInfo.timestamp = block.timestamp;

        emit DepositMade(msg.sender, token, amount, block.timestamp);
    }

    function withdrawFromVault(address token, uint256 amount) external {
        DepositInfo storage userInfo = userDeposits[msg.sender][token];
        require(userInfo.amount >= amount, "Insufficient balance");
        require(block.timestamp >= userInfo.timestamp + 7 * DAY_IN_SECONDS, "Withdrawal locked for 7 days");

        uint256 daysHeld = (block.timestamp - userInfo.timestamp) / DAY_IN_SECONDS;
        uint256 extraTokens = (daysHeld * ANNUAL_RATE * amount) / 1e18;

        userInfo.amount -= amount;
        if (userInfo.amount == 0) {
            userInfo.timestamp = 0;
        } else {
            userInfo.timestamp = block.timestamp;
        }

        releasedTokens[msg.sender] += extraTokens;

        emit Withdrawal(msg.sender, token, amount, extraTokens);
    }

    function calculateBonus(uint256 amount) internal pure returns (uint256) {
        return (7 * ANNUAL_RATE * amount) / 1e18;
    }

    function calculateTotalTokens(address user) external view returns (uint256) {
        return releasedTokens[user];
    }
}
