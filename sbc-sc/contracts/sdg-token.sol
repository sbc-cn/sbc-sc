// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SDGToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    // address public _defaultOwner = 0x565EAe1f9d793894083ea26AE1da2edE6a39d12a;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InfoUpdated(string newInfo);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        name = "SDG Token";
        symbol = "SDG";
        decimals = 18;
        totalSupply = 210000000 * 10 ** uint256(decimals); // Total supply of 210,000,000 SDG tokens
        owner = msg.sender;
        // owner = _defaultOwner;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value * decimals;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
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
        require(totalSupply + value >= totalSupply, "Total supply overflow");
        require(balanceOf[to] + value >= balanceOf[to], "Recipient balance overflow");
        totalSupply += value;
        balanceOf[to] += value  * decimals;
        emit Transfer(address(0), to, value);
    }
}
