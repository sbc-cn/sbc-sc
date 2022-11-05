// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ABCToken is ERC20, Ownable {

    constructor() ERC20("ABC TOKEN", "ABC") {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
}
