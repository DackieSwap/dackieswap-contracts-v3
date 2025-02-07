// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title IDackieSuperchain
 * @notice Interface for the DackieSuperchain contract
 */
interface IDackieSuperchain {
    /**
     * @notice Mints new tokens to the specified address
     * @param to_ The address to mint tokens to
     * @param amount_ The amount of tokens to mint
     */
    function mintTo(address to_, uint256 amount_) external;
}
