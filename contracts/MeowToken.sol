//SPDX-License-Identifier: GPL-3.0
//reward token

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MeowToken is ERC20
{
    constructor() ERC20("Meow Token", "MWT")
    {
        _mint(msg.sender, 1000*10**uint(decimals()));
    }
}