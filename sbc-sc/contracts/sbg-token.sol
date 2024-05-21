// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SBGToken {
    string public name = "SBG Token";
    string public symbol = "SBG";
    uint8 public decimals = 18;
    uint256 public totalSupply = 210000000 * (10 ** uint256(decimals));
    uint256 public mintSupply;
    address public owner;
    uint256 public baseSBGAcount;

    mapping(address => uint256) public balanceOf;
    // 当前 SBG 质押状态
    mapping(address => bool) public status;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InfoUpdated(string newInfo);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = 0;
        emit Transfer(address(0), owner, 0);
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[from] >= value, "Insufficient balance");
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        unchecked {
            balanceOf[from] -= value;
            balanceOf[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function setBase(uint256 value) external returns (bool success) {
        baseSBGAcount = value;
        return true;
    }

    function setInfo(string memory info) external onlyOwner {
        emit InfoUpdated(info);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        // require(value > totalSupply, "Mint exceeds limit");
        unchecked {
            mintSupply += value;
            balanceOf[to] += value;
        }
        emit Transfer(address(0), to, value);
    }
}
