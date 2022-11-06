// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SBCToken is ERC20, Ownable, ReentrancyGuard {

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
    }

    function mint(address account, uint256 amount) external onlyOwner nonReentrant {
        _mint(account, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
}
