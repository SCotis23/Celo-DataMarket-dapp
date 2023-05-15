// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DataMarket {
    
    // Define struct for data listings
    struct DataListing {
        string name;
        string description;
        string image;
        uint256 price;
        address payable owner;
        uint256 NOU;
    }
    
    // Define mapping for data listings
    mapping(uint256 => DataListing) public listings;
    uint256 public listingCount;
    mapping(address => mapping(uint256 => uint256)) public startTime;
    IERC20 public celoToken;
    
    // Define events
    event ListingCreated(uint256 indexed id, string description, uint256 price, address owner);
    event ListingSold(uint256 indexed id, address indexed buyer);
    event ListingRemoved(uint256 indexed id);
    
    constructor(address celoTokenAddress) {
        celoToken = IERC20(celoTokenAddress);
    }
    
    // Create a new data listing
    function createListing(string calldata _name, string calldata _description,string calldata _image, uint256 _price) public {
        require(_price > 0, "Price must be greater than 0");
        listings[listingCount] = DataListing(_name, _description, _image, _price, payable(msg.sender), 0);
        emit ListingCreated(listingCount, _description, _price, msg.sender);
        listingCount++;
    }
    
    // Purchase a data listing
    function purchaseListing(uint256 _id) public {
