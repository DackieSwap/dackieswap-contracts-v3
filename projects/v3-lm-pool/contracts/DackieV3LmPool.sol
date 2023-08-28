// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '@pancakeswap/v3-core/contracts/libraries/LowGasSafeMath.sol';
import '@pancakeswap/v3-core/contracts/libraries/SafeCast.sol';
import '@pancakeswap/v3-core/contracts/libraries/FullMath.sol';
import '@pancakeswap/v3-core/contracts/libraries/FixedPoint128.sol';
import '@pancakeswap/v3-core/contracts/interfaces/IDackieV3Pool.sol';

import './libraries/LmTick.sol';

import './interfaces/IDackieV3LmPool.sol';
import './interfaces/ILMPool.sol';
import './interfaces/IMasterChefV3.sol';
import './interfaces/IDackieV3LmPoolDeveloper.sol';

contract DackieV3LmPool is IDackieV3LmPool {
  using LowGasSafeMath for uint256;
  using LowGasSafeMath for int256;
  using SafeCast for uint256;
  using SafeCast for int256;
  using LmTick for mapping(int24 => LmTick.Info);

  uint256 public constant REWARD_PRECISION = 1e12;

  IDackieV3Pool public immutable pool;
  IMasterChefV3 public immutable masterChef;

  // The first version LMPool.
  ILMPool public immutable firstLMPool;

  // The second version LMPool.
  ILMPool public immutable secondLMPool;

  // The third version LMPool.
  ILMPool public immutable thirdLMPool;

  mapping(int24 => bool) public lmTicksFlag;

  uint256 public rewardGrowthGlobalX128;

  mapping(int24 => LmTick.Info) public lmTicks;

  uint128 public lmLiquidity;

  uint32 public lastRewardTimestamp;

  // Need to initialize the LMPool when first call from v3 pool or MCV3.
  bool public initialization;

  // Record the first negative RewardGrowthInside value.
  mapping(int24 => mapping(int24 => uint256)) public negativeRewardGrowthInsideInitValue;
  // Read old negativeRewardGrowthInsideInitValue data from thirdLMPool.
  mapping(int24 => mapping(int24 => bool)) public checkThirdLMPool;

  modifier onlyPool() {
    require(msg.sender == address(pool), 'Not pool');
    _;
  }

  modifier onlyMasterChef() {
    require(msg.sender == address(masterChef), 'Not MC');
    _;
  }

  modifier onlyPoolOrMasterChef() {
    require(msg.sender == address(pool) || msg.sender == address(masterChef), 'Not pool or MC');
    _;
  }

  constructor() {
    (
    address poolAddress,
    address masterChefAddress,
    address firstLMPoolAddress,
    address secondLMPoolAddress,
    address thirdLMPoolAddress
    ) = IDackieV3LmPoolDeveloper(msg.sender).parameters();
    pool = IDackieV3Pool(poolAddress);
    masterChef = IMasterChefV3(masterChefAddress);
    lastRewardTimestamp = uint32(block.timestamp);
    firstLMPool = ILMPool(firstLMPoolAddress);
    secondLMPool = ILMPool(secondLMPoolAddress);
    thirdLMPool = ILMPool(thirdLMPoolAddress);
  }

  /// @notice Will trigger this once when the first call from MasterChefV3 or V3 pool,
  /// this will update the latest global information from old LMPool.
  /// Because we will deploy new LMPool and set LMPool in v3 pool in the same transaction, so we can call initialize at the same tx.
  function initialize() external override {
    if (!initialization) {
      initialization = true;
      rewardGrowthGlobalX128 = thirdLMPool.rewardGrowthGlobalX128();
      lmLiquidity = thirdLMPool.lmLiquidity();
      lastRewardTimestamp = thirdLMPool.lastRewardTimestamp();
    }
  }

  function _getLMTicks(int24 tick) internal view returns (LmTick.Info memory info) {
    // When tick had updated in thirdLMPool , read tick info from third LMPool, or read from second LMPool , if not , read from firstLMPool.
    if (thirdLMPool.lmTicksFlag(tick)) {
      (info.liquidityGross, info.liquidityNet, info.rewardGrowthOutsideX128) = thirdLMPool.lmTicks(tick);
    } else if (secondLMPool.lmTicksFlag(tick)) {
      (info.liquidityGross, info.liquidityNet, info.rewardGrowthOutsideX128) = secondLMPool.lmTicks(tick);
    } else {
      (info.liquidityGross, info.liquidityNet, info.rewardGrowthOutsideX128) = firstLMPool.lmTicks(tick);
    }
  }

  /// @notice Update tick information from old LMPool when need to update the tick information at the first time.
  /// @dev Old LMPool ticks information can be compatible.
  function _updateLMTicks(int24 tick) internal {
    if (!lmTicksFlag[tick]) {
      lmTicksFlag[tick] = true;
      lmTicks[tick] = _getLMTicks(tick);
    }
  }

  function accumulateReward(uint32 currTimestamp) external override onlyPoolOrMasterChef {
    if (currTimestamp <= lastRewardTimestamp) {
      return;
    }

    if (lmLiquidity != 0) {
      (uint256 rewardPerSecond, uint256 endTime) = masterChef.getLatestPeriodInfo(address(pool));

      uint32 endTimestamp = uint32(endTime);
      uint32 duration;
      if (endTimestamp > currTimestamp) {
        duration = currTimestamp - lastRewardTimestamp;
      } else if (endTimestamp > lastRewardTimestamp) {
        duration = endTimestamp - lastRewardTimestamp;
      }

      if (duration != 0) {
        rewardGrowthGlobalX128 += FullMath.mulDiv(
          duration,
          FullMath.mulDiv(rewardPerSecond, FixedPoint128.Q128, REWARD_PRECISION),
          lmLiquidity
        );
      }
    }

    lastRewardTimestamp = currTimestamp;
  }

  function crossLmTick(int24 tick, bool zeroForOne) external override onlyPool {
    // Update the lmTicks state from the secondLMPool.
    _updateLMTicks(tick);

    if (lmTicks[tick].liquidityGross == 0) {
      return;
    }

    int128 lmLiquidityNet = lmTicks.cross(tick, rewardGrowthGlobalX128);

    if (zeroForOne) {
      lmLiquidityNet = -lmLiquidityNet;
    }

    lmLiquidity = LiquidityMath.addDelta(lmLiquidity, lmLiquidityNet);
  }

  /// @notice Get the current negativeRewardGrowthInsideInitValue based on all old LMPools.
  function _getNegativeRewardGrowthInsideInitValue(
    int24 tickLower,
    int24 tickUpper
  ) internal view returns (uint256 initValue) {
    // If already chekced third LMPool , use current negativeRewardGrowthInsideInitValue.
    if (checkThirdLMPool[tickLower][tickUpper]) {
      initValue = negativeRewardGrowthInsideInitValue[tickLower][tickUpper];
    } else {
      bool checkSecondLMPoolFlagInThirdLMPool = thirdLMPool.checkSecondLMPool(tickLower, tickUpper);
      // If already checked second LMPool , use third LMPool negativeRewardGrowthInsideInitValue.
      if (checkSecondLMPoolFlagInThirdLMPool) {
        initValue = thirdLMPool.negativeRewardGrowthInsideInitValue(tickLower, tickUpper);
      } else {
        // If not checked second LMPool , use second LMPool negativeRewardGrowthInsideInitValue.
        initValue = secondLMPool.negativeRewardGrowthInsideInitValue(tickLower, tickUpper);
      }
    }
  }

  /// @notice This will check the whether the range RewardGrowthInside is negative when the range ticks were initialized.
  /// @dev This is for fixing the issues that rewardGrowthInsideX128 can be underflow on purpose.
  /// If the rewardGrowthInsideX128 is negative , we will process it as a positive number.
  /// Because the RewardGrowthInside is self-incrementing, so we record the initial value as zero point.
  function _checkNegativeRewardGrowthInside(int24 tickLower, int24 tickUpper) internal {
    (uint256 rewardGrowthInsideX128, bool isNegative) = _getRewardGrowthInsideInternal(tickLower, tickUpper);
    uint256 initValue = _getNegativeRewardGrowthInsideInitValue(tickLower, tickUpper);
    // Only need to check third LMPool once , and initialize negativeRewardGrowthInsideInitValue.
    if (!checkThirdLMPool[tickLower][tickUpper]) {
      checkThirdLMPool[tickLower][tickUpper] = true;
      negativeRewardGrowthInsideInitValue[tickLower][tickUpper] = initValue;
    }
    if (isNegative) {
      if (initValue == 0 || initValue > rewardGrowthInsideX128) {
        negativeRewardGrowthInsideInitValue[tickLower][tickUpper] = rewardGrowthInsideX128;
      }
    }
  }

  /// @notice Need to rest Negative Tick info when tick flipped.
  function _clearNegativeTickInfo(int24 tickLower, int24 tickUpper) internal {
    negativeRewardGrowthInsideInitValue[tickLower][tickUpper] = 0;
    // No need to check thirdLMPool after tick flipped.
    if (!checkThirdLMPool[tickLower][tickUpper]) checkThirdLMPool[tickLower][tickUpper] = true;
  }

  function updatePosition(int24 tickLower, int24 tickUpper, int128 liquidityDelta) external onlyMasterChef {
    // Update the lmTicks state from the secondLMPool.
    _updateLMTicks(tickLower);
    _updateLMTicks(tickUpper);
    (, int24 tick, , , , , ) = pool.slot0();
    uint128 maxLiquidityPerTick = pool.maxLiquidityPerTick();
    uint256 _rewardGrowthGlobalX128 = rewardGrowthGlobalX128;

    bool flippedLower;
    bool flippedUpper;
    if (liquidityDelta != 0) {
      flippedLower = lmTicks.update(
        tickLower,
        tick,
        liquidityDelta,
        _rewardGrowthGlobalX128,
        false,
        maxLiquidityPerTick
      );
      flippedUpper = lmTicks.update(
        tickUpper,
        tick,
        liquidityDelta,
        _rewardGrowthGlobalX128,
        true,
        maxLiquidityPerTick
      );
    }

    if (tick >= tickLower && tick < tickUpper) {
      lmLiquidity = LiquidityMath.addDelta(lmLiquidity, liquidityDelta);
    }

    if (liquidityDelta < 0) {
      if (flippedLower) {
        lmTicks.clear(tickLower);
      }
      if (flippedUpper) {
        lmTicks.clear(tickUpper);
      }
    }
    // Need to rest Negative Tick info when tick flipped.
    if (liquidityDelta < 0 && (flippedLower || flippedUpper)) {
      _clearNegativeTickInfo(tickLower, tickUpper);
    } else {
      _checkNegativeRewardGrowthInside(tickLower, tickUpper);
    }
  }

  function getRewardGrowthInside(
    int24 tickLower,
    int24 tickUpper
  ) external view returns (uint256 rewardGrowthInsideX128) {
    (rewardGrowthInsideX128, ) = _getRewardGrowthInsideInternal(tickLower, tickUpper);
    uint256 initValue = _getNegativeRewardGrowthInsideInitValue(tickLower, tickUpper);
    rewardGrowthInsideX128 = rewardGrowthInsideX128 - initValue;
  }

  function _getRewardGrowthInsideInternal(
    int24 tickLower,
    int24 tickUpper
  ) internal view returns (uint256 rewardGrowthInsideX128, bool isNegative) {
    (, int24 tick, , , , , ) = pool.slot0();
    LmTick.Info memory lower;
    if (lmTicksFlag[tickLower]) {
      lower = lmTicks[tickLower];
    } else {
      lower = _getLMTicks(tickLower);
    }
    LmTick.Info memory upper;
    if (lmTicksFlag[tickUpper]) {
      upper = lmTicks[tickUpper];
    } else {
      upper = _getLMTicks(tickUpper);
    }

    // calculate reward growth below
    uint256 rewardGrowthBelowX128;
    if (tick >= tickLower) {
      rewardGrowthBelowX128 = lower.rewardGrowthOutsideX128;
    } else {
      rewardGrowthBelowX128 = rewardGrowthGlobalX128 - lower.rewardGrowthOutsideX128;
    }

    // calculate reward growth above
    uint256 rewardGrowthAboveX128;
    if (tick < tickUpper) {
      rewardGrowthAboveX128 = upper.rewardGrowthOutsideX128;
    } else {
      rewardGrowthAboveX128 = rewardGrowthGlobalX128 - upper.rewardGrowthOutsideX128;
    }

    rewardGrowthInsideX128 = rewardGrowthGlobalX128 - rewardGrowthBelowX128 - rewardGrowthAboveX128;
    isNegative = (rewardGrowthBelowX128 + rewardGrowthAboveX128) > rewardGrowthGlobalX128;
  }
}