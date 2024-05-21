// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SDC {
    struct Collectible {
        string name;
        string description;
        uint256 power;
        string rarity;
    }

    Collectible[] public collectibles;
    mapping(uint256 => address) public collectibleToOwner;
    mapping(address => uint256) public ownerCollectibleCount;

    address public owner;

    event CollectibleCreated(uint256 indexed collectibleId, string name, address owner);
    event Transfer(address indexed from, address indexed to, uint256 indexed collectibleId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InfoUpdated(uint256 indexed collectibleId, string name, string description, uint256 power, string rarity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createCollectible(string memory name, string memory description, uint256 power, string memory rarity) public onlyOwner {
        Collectible memory newCollectible = Collectible(name, description, power, rarity);
        collectibles.push(newCollectible);
        uint256 collectibleId = collectibles.length - 1;
        collectibleToOwner[collectibleId] = msg.sender;
        ownerCollectibleCount[msg.sender]++;
        emit CollectibleCreated(collectibleId, name, msg.sender);
    }

    function transferCollectible(address to, uint256 collectibleId) public {
        require(collectibleToOwner[collectibleId] == msg.sender, "You do not own this collectible");
        require(to != address(0), "Invalid address");

        ownerCollectibleCount[msg.sender]--;
        ownerCollectibleCount[to]++;
        collectibleToOwner[collectibleId] = to;

        emit Transfer(msg.sender, to, collectibleId);
    }

    function getCollectible(uint256 collectibleId) public view returns (string memory, string memory, uint256, string memory, address) {
        Collectible storage collectible = collectibles[collectibleId];
        return (collectible.name, collectible.description, collectible.power, collectible.rarity, collectibleToOwner[collectibleId]);
    }

    function getCollectiblesByOwner(address _owner) public view returns (uint256[] memory) {
        uint256 count = ownerCollectibleCount[_owner];
        uint256[] memory result = new uint256[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < collectibles.length; i++) {
            if (collectibleToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function updateCollectible(uint256 collectibleId, string memory name, string memory description, uint256 power, string memory rarity) public onlyOwner {
        Collectible storage collectible = collectibles[collectibleId];
        collectible.name = name;
        collectible.description = description;
        collectible.power = power;
        collectible.rarity = rarity;
        emit InfoUpdated(collectibleId, name, description, power, rarity);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
