// NASICOIN.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Import OpenZeppelin contracts for ERC20 standard and access control
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NASICOIN (NASIC)
 * @dev NASICOIN is a token created to support the owner of a cat named NASIC. 
 *      It has unique functionalities such as staking, donations, and weekly lottery-based prize distributions.
 *      The fractional unit of NASICOIN is called "FISH".
 */
contract NASICOIN is ERC20, Ownable {
    // Constants
    uint256 public constant INITIAL_SUPPLY = 2000 * 10**18; // 2000 NASIC with 18 decimals

    // State variables
    address public developer; // Address of the developer
    address public vaultManager; // Address of the VaultManager contract
    address public pendingNewOwner;
    address public pendingNewDeveloper;

    uint256 public ownerChangeRequestTime;
    uint256 public developerChangeRequestTime;

    uint256 private constant CHANGE_REQUEST_DELAY = 3 minutes; // 3 minutes

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

        // Mint initial supply to the owner
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice Override the decimals function to return 18, standard for ERC20 tokens.
     *         The smallest fractional unit of NASICOIN is called "FISH".
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @notice Modifier to restrict access to developer-only functions.
     */
    modifier onlyDeveloper() {
        require(msg.sender == developer, "Caller is not the developer");
        _;
    }

    /**
     * @notice Set the address of the VaultManager contract.
     * @param _vaultManager The address of the VaultManager contract.
     */
    function setVaultManager(address _vaultManager) external onlyOwner {
        require(_vaultManager != address(0), "VaultManager address cannot be zero");
        vaultManager = _vaultManager;
    }

    /**
     * @notice Mint new tokens. Can only be called by the VaultManager contract.
     * @param to The address to receive the newly minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external {
        require(msg.sender == vaultManager, "Caller is not the VaultManager");
        _mint(to, amount);
    }

    // Ownership and developer management functions remain unchanged...
}