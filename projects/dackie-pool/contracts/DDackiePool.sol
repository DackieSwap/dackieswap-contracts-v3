// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DDACKIEPOOL is ERC20 {
    constructor() ERC20("dDACKIEPOOL", "dDACKIEPOOL") {
        _mint(msg.sender, 10*10**18);
    }
}
