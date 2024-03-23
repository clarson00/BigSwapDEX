// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BigRandomToken is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name,symbol){
        _mint(msg.sender, 100*10**decimals());
    }

    function mint(address to, uint256 amount) external {
        _mint(to,amount);
    }


}