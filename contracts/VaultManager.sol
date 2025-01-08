// VaultManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IVault {
    function deposit(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function getProfit(address account) external view returns (uint256);
}

interface IPrizeManager {
    function updateWeeklyProfits(uint256 profits, uint256 totalInvested, uint256 reinvested) external;
}

contract StablecoinVaultManager is Ownable {
    address public prizeManager;

    constructor(address _prizeManager, address initialOwner) Ownable(initialOwner) {
        require(_prizeManager != address(0), "Invalid PrizeManager address");
        prizeManager = _prizeManager;
    }

    function calculateWeeklyProfits() external onlyOwner {
        uint256 profits = IVault(address(this)).getProfit(address(this));
        uint256 totalInvested = IVault(address(this)).balanceOf(address(this));
        uint256 reinvested = (profits * 50) / 100;

        IPrizeManager(prizeManager).updateWeeklyProfits(profits, totalInvested, reinvested);
    }
}