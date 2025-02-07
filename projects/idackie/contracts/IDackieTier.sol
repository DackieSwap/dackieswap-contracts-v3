// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IDackiePool.sol";

contract IDackieTier is Ownable {
    using SafeMath for uint256;

    IDackiePool public immutable dackiePool;

    // threshold of locked duration
    uint256 public ceiling;

    // xCredit
    uint256 public multiplier;

    // xFactor
    uint256 public X_FACTOR = 1e12;

    uint256 public constant MIN_CEILING_DURATION = 5 weeks;

    // Base amount for tier calculation
    uint256 public tierBaseAmount = 100000 * 1e18;

    event UpdateCeiling(uint256 newCeiling);
    event UpdateMultiplier(uint256 newMultiplier);
    event UpdateTierBaseAmount(uint256 newTierBaseAmount);

    constructor(
        IDackiePool _dackiePool,
        uint256 _ceiling,
        uint256 _multiplier
    ) {
        require(_ceiling >= MIN_CEILING_DURATION, "Invalid ceiling duration");
        dackiePool = _dackiePool;
        ceiling = _ceiling;
        multiplier = _multiplier;
    }

    function getUserCredit(address _user) external view returns (uint256) {
        require(_user != address(0), "getUserCredit: Invalid address");
        return _calculateUserCredit(_user);
    }

    function    _calculateUserCredit(address _user) internal view returns (uint256) {
        (, , , , uint256 lockStartTime, uint256 lockEndTime, , bool locked , uint256 lockedAmount) = dackiePool.userInfo(_user);

        if (!locked || block.timestamp > lockEndTime) {
            return 0;
        }

        // lockEndTime always >= lockStartTime
        uint256 lockDuration = lockEndTime.sub(lockStartTime);

        if (lockDuration >= ceiling) {
            return lockedAmount.mul(multiplier).div(X_FACTOR);
        } else if (lockDuration < ceiling && lockDuration >= 0) {
            return ((lockedAmount.mul(multiplier).div(X_FACTOR)).mul(lockDuration)).div(ceiling);
        }

        // If none of the above conditions are met, return 0.
        return 0;
    }

    function getUserTier(address _user) external view returns (uint256) {
        uint256 userCredit = _calculateUserCredit(_user);

        if (userCredit < tierBaseAmount) {
            return 0;
        } else if (userCredit < 3 * tierBaseAmount) {
            return 1;
        } else if (userCredit < 10 * tierBaseAmount) {
            return 2;
        } else if (userCredit < 20 * tierBaseAmount) {
            return 3;
        } else if (userCredit < 35 * tierBaseAmount) {
            return 4;
        } else {
            return 5;
        }
    }

    function updateCeiling(uint256 _newCeiling) external onlyOwner {
        require(_newCeiling >= MIN_CEILING_DURATION, "updateCeiling: Invalid ceiling");
        require(ceiling != _newCeiling, "updateCeiling: Ceiling not changed");
        ceiling = _newCeiling;
        emit UpdateCeiling(ceiling);
    }

    function updateMultiplier(uint256 _newMultiplier) external onlyOwner {
        require(multiplier != _newMultiplier, "updateMultiplier: Multiplier not changed");
        multiplier = _newMultiplier;
        emit UpdateMultiplier(multiplier);
    }

    function updateTierBaseAmount(uint256 _newTierBaseAmount) external onlyOwner {
        require(tierBaseAmount != _newTierBaseAmount, "updateTierBaseAmount: Tier base amount not changed");
        tierBaseAmount = _newTierBaseAmount;
        emit UpdateTierBaseAmount(tierBaseAmount);
    }
}
