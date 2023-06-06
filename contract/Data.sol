// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataMarket {
    struct DataListing {
        string name;
        string description;
        string image;
        uint256 price;
        address payable owner;
        uint256 NOU;
    }

    mapping (address => mapping (uint => uint)) startTime;
    mapping (uint256 => DataListing) public listings;
    mapping (uint => mapping(address => bool)) purchasers;
    uint256 public listingCount;

    event ListingCreated(uint256 indexed id, string description, uint256 price, address owner);
    event ListingSold(uint256 indexed id, address indexed buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    function createListing(string calldata _name, string calldata _description, string calldata _image, uint256 _price) public {
        listings[listingCount] = DataListing(_name, _description, _image, _price, payable(msg.sender), 0);
        emit ListingCreated(listingCount, _description, _price, msg.sender);
        listingCount++;
    }

    function purchaseListing(uint256 _id) public payable {
        require(msg.value == listings[_id].price, "Incorrect payment amount");
        listings[_id].NOU++;
        startTime[msg.sender][_id] = block.timestamp;
        purchasers[_id][msg.sender] = true;
        emit ListingSold(_id, msg.sender);
        listings[_id].owner.transfer(msg.value);
    }

    function removeListing(uint _id) public onlyOwner {
        delete listings[_id];
    }

    function getListingForUse(uint _id) public view returns (address, string memory, string memory) {
        require(purchasers[_id][msg.sender], "You have not purchased this data");
        return (listings[_id].owner, listings[_id].name, listings[_id].description);
    }

    function getListing(uint _id) public view returns (address, string memory, string memory, uint, uint) {
        return (listings[_id].owner, listings[_id].name, listings[_id].image, listings[_id].price, listings[_id].NOU);
    }

    function getTotalListings() public view returns (uint) {
        return (listingCount - 1);
    }
}
