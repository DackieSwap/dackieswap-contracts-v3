// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDackieSuperchain} from "./interfaces/IDackieSuperchain.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title DackieTokenMigrator
 * @notice Contract to migrate oldDACKIE and oldQUACK tokens to DackieSuperchain
 */
contract DackieTokenMigrator is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    // Dead address for burning tokens
    address constant DEAD_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    
    // Migration rates
    uint256 constant DACKIE_RATE = 10; // 10 oldDACKIE = 1 Dackie Superchain
    uint256 constant QUACK_RATE = 150; // 150 oldQUACK = 1 Dackie Superchain

    // Token contracts
    IERC20 public immutable oldDACKIE;
    IERC20 public immutable oldQUACK;
    IDackieSuperchain public immutable dackieSuperchain;

    // Maximum burn limits
    uint256 public maxOldDACKIE;
    uint256 public maxOldQUACK;

    // Total burned amounts
    uint256 public totalBurnedDACKIE;
    uint256 public totalBurnedQUACK;

    // Events
    event DackieMigrated(address indexed user, uint256 oldAmount, uint256 newAmount);
    event QuackMigrated(address indexed user, uint256 oldAmount, uint256 newAmount);
    event MaxBurnLimitsSet(uint256 maxOldDACKIE, uint256 maxOldQUACK);

    /**
     * @notice Constructor to set the token addresses and max burn limits
     * @param oldDACKIE_ Address of the old DACKIE token
     * @param oldQUACK_ Address of the old QUACK token
     * @param dackieSuperchain_ Address of the new DackieSuperchain token
     * @param maxOldDACKIE_ Maximum amount of oldDACKIE that can be burned
     * @param maxOldQUACK_ Maximum amount of oldQUACK that can be burned
     */
    constructor(
        address oldDACKIE_,
        address oldQUACK_,
        address dackieSuperchain_,
        uint256 maxOldDACKIE_,
        uint256 maxOldQUACK_
    ) {
        require(oldDACKIE_ != address(0), "Invalid oldDACKIE address");
        require(oldQUACK_ != address(0), "Invalid oldQUACK address");
        require(dackieSuperchain_ != address(0), "Invalid dackieSuperchain address");
        require(maxOldDACKIE_ > 0, "Invalid maxOldDACKIE");
        require(maxOldQUACK_ > 0, "Invalid maxOldQUACK");

        oldDACKIE = IERC20(oldDACKIE_);
        oldQUACK = IERC20(oldQUACK_);
        dackieSuperchain = IDackieSuperchain(dackieSuperchain_);
        maxOldDACKIE = maxOldDACKIE_;
        maxOldQUACK = maxOldQUACK_;
        
        emit MaxBurnLimitsSet(maxOldDACKIE, maxOldQUACK);
    }

    /**
     * @notice Migrate oldDACKIE tokens to DackieSuperchain
     * @param amount_ Amount of oldDACKIE tokens to migrate (must be multiple of 10)
     */
    function migrateDackie(uint256 amount_) external whenNotPaused nonReentrant {
        require(amount_ > 0, "Amount must be greater than 0");
        require(amount_ % DACKIE_RATE == 0, "Amount must be multiple of 10");
        require(totalBurnedDACKIE.add(amount_) <= maxOldDACKIE, "Exceeds max burn limit for DACKIE");

        uint256 newAmount = amount_ / DACKIE_RATE;

        // Update total burned amount before external calls
        totalBurnedDACKIE = totalBurnedDACKIE.add(amount_);

        // Check allowance
        require(oldDACKIE.allowance(msg.sender, address(this)) >= amount_, "Insufficient allowance");

        // Check balance
        require(oldDACKIE.balanceOf(msg.sender) >= amount_, "Insufficient balance");

        // Transfer old tokens to dead address
        require(
            oldDACKIE.transferFrom(msg.sender, DEAD_ADDRESS, amount_),
            "Old token transfer failed"
        );

        // Mint new tokens
        dackieSuperchain.mintTo(msg.sender, newAmount);

        emit DackieMigrated(msg.sender, amount_, newAmount);
    }

    /**
     * @notice Migrate oldQUACK tokens to DackieSuperchain
     * @param amount_ Amount of oldQUACK tokens to migrate (must be multiple of 150)
     */
    function migrateQuack(uint256 amount_) external whenNotPaused nonReentrant {
        require(amount_ > 0, "Amount must be greater than 0");
        require(amount_ % QUACK_RATE == 0, "Amount must be multiple of 150");
        require(totalBurnedQUACK.add(amount_) <= maxOldQUACK, "Exceeds max burn limit for QUACK");

        uint256 newAmount = amount_ / QUACK_RATE;

        // Update total burned amount before external calls
        totalBurnedQUACK = totalBurnedQUACK.add(amount_);

        // Check allowance
        require(oldQUACK.allowance(msg.sender, address(this)) >= amount_, "Insufficient allowance");

        // Check balance
        require(oldQUACK.balanceOf(msg.sender) >= amount_, "Insufficient balance");

        // Transfer old tokens to dead address
        require(
            oldQUACK.transferFrom(msg.sender, DEAD_ADDRESS, amount_),
            "Old token transfer failed"
        );

        // Mint new tokens
        dackieSuperchain.mintTo(msg.sender, newAmount);

        emit QuackMigrated(msg.sender, amount_, newAmount);
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
