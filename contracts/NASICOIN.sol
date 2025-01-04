// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import OpenZeppelin contracts for ERC20 standard and access control
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NASICOIN (NASIC)
 * @dev NASICOIN is a token created to support the owner of a cat named NASIC. 
 *      It has unique functionalities such as staking, donations, and weekly lottery-based prize distributions.
 */
contract NASICOIN is ERC20, Ownable {
    // Constants
    uint256 public constant FISH_DECIMALS = 1000; // 1 NASIC = 1000 FISH
    uint256 public constant INITIAL_SUPPLY = 2 * 10**18; // 2 NASIC

    // State variables
    address public developer; // Address of the developer
    address public pendingNewOwner;
    address public pendingNewDeveloper;

    uint256 public ownerChangeRequestTime;
    uint256 public developerChangeRequestTime;

    uint256 private constant CHANGE_REQUEST_DELAY = 90 days; // 3 months

    // Events
    event DeveloperChanged(address indexed oldDeveloper, address indexed newDeveloper);
    event OwnerChangeRequested(address indexed requester, address indexed newOwner);
    event DeveloperChangeRequested(address indexed requester, address indexed newDeveloper);
    event OwnerChangeCanceled(address indexed currentOwner);
    event DeveloperChangeCanceled(address indexed currentDeveloper);

    /**
     * @notice Constructor to deploy the NASICOIN token.
     * @param initialOwner The initial owner of the contract (passed to the Ownable constructor).
     */
    constructor(address initialOwner) ERC20("NASICOIN", "NASIC") Ownable(initialOwner) {
        // Set developer to the deployer's address
        developer = msg.sender;

        // Mint 2 NASIC to the owner (deployer)
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice Modifier to restrict access to developer-only functions.
     */
    modifier onlyDeveloper() {
        require(msg.sender == developer, "Caller is not the developer");
        _;
    }

    // Functionality for ownership and developer change management...
    // (same as in the previous implementation)
}
