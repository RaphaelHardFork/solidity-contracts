// SPDX-License-Identifier: MIT
// contract address : 0xf5811343e29d529D3C0b8C052709AABeaf469a29 on Goerli

pragma solidity ^0.8.0;

// Utiliser sur Remix
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/token/ERC20/ERC20.sol";

contract RaphToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("RaphToken", "RT") {
        _mint(msg.sender, initialSupply);
    }
}
