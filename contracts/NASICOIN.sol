// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    /**
     * @notice Request to change the owner.
     * @param _newOwner Address of the new owner.
     */
    function requestOwnerChange(address _newOwner) external onlyDeveloper {
        require(_newOwner != address(0), "New owner cannot be zero address");
        require(ownerChangeRequestTime == 0, "Owner change already requested");

        pendingNewOwner = _newOwner;
        ownerChangeRequestTime = block.timestamp;

        emit OwnerChangeRequested(msg.sender, _newOwner);
    }

    /**
     * @notice Cancel the owner change request.
     */
    function cancelOwnerChange() external onlyOwner {
        require(ownerChangeRequestTime > 0, "No owner change request pending");

        pendingNewOwner = address(0);
        ownerChangeRequestTime = 0;

        emit OwnerChangeCanceled(msg.sender);
    }

    /**
     * @notice Finalize the owner change after 3 months.
     */
    function finalizeOwnerChange() external {
        require(ownerChangeRequestTime > 0, "No owner change request pending");
        require(block.timestamp >= ownerChangeRequestTime + CHANGE_REQUEST_DELAY, "Owner change delay not met");

        address oldOwner = owner();
        address newOwner = pendingNewOwner;

        _transferOwnership(newOwner);

        pendingNewOwner = address(0);
        ownerChangeRequestTime = 0;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice Request to change the developer.
     * @param _newDeveloper Address of the new developer.
     */
    function requestDeveloperChange(address _newDeveloper) external onlyOwner {
        require(_newDeveloper != address(0), "New developer cannot be zero address");
        require(developerChangeRequestTime == 0, "Developer change already requested");

        pendingNewDeveloper = _newDeveloper;
        developerChangeRequestTime = block.timestamp;

        emit DeveloperChangeRequested(msg.sender, _newDeveloper);
    }

    /**
     * @notice Cancel the developer change request.
     */
    function cancelDeveloperChange() external onlyDeveloper {
        require(developerChangeRequestTime > 0, "No developer change request pending");

        pendingNewDeveloper = address(0);
        developerChangeRequestTime = 0;

        emit DeveloperChangeCanceled(msg.sender);
    }

    /**
     * @notice Finalize the developer change after 3 months.
     */
    function finalizeDeveloperChange() external {
        require(developerChangeRequestTime > 0, "No developer change request pending");
        require(block.timestamp >= developerChangeRequestTime + CHANGE_REQUEST_DELAY, "Developer change delay not met");

        address oldDeveloper = developer;
        address newDeveloper = pendingNewDeveloper;

        developer = newDeveloper;

        pendingNewDeveloper = address(0);
        developerChangeRequestTime = 0;

        emit DeveloperChanged(oldDeveloper, newDeveloper);
    }
}
