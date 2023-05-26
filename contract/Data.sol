// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataMarket {
    // Define struct for data listings
    struct DataListing {
        string name;
        string description;
        string image;
        uint256 price;
        address payable owner;
        uint NOU;
    }
    
    // Define mappings for data listings and ownership
    mapping (uint256 => DataListing) private listings;
    mapping (uint256 => bool) private listingExists;
    mapping (uint256 => mapping(address => bool)) private purchasers;
    mapping (uint256 => mapping(address => uint256)) private purchaseTimestamps;
    mapping (address => mapping(uint256 => bool)) private listingOwners;
    
    uint256 private listingCount;
    
    // Define events
    event ListingCreated(uint256 indexed id, string description, uint256 price, address owner);
    event ListingSold(uint256 indexed id, address indexed buyer);
    
    // Modifier to restrict access to listing owners
    modifier onlyListingOwner(uint256 _id) {
        require(listingOwners[msg.sender][_id], "Only the listing owner can perform this action");
        _;
    }
    
    // Create a new data listing
    function createListing(string calldata _name, string calldata _description, string calldata _image, uint256 _price) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_price > 0, "Price must be greater than zero");
        
        DataListing storage newListing = listings[listingCount];
        newListing.name = _name;
        newListing.description = _description;
        newListing.image = _image;
        newListing.price = _price;
        newListing.owner = payable(msg.sender);
        
        listingExists[listingCount] = true;
        listingOwners[msg.sender][listingCount] = true;
        
        emit ListingCreated(listingCount, _description, _price, msg.sender);
        
        listingCount++;
    }
    
    // Purchase a data listing
    function purchaseListing(uint256 _id) public payable {
        require(listingExists[_id], "Listing does not exist");
        require(!purchasers[_id][msg.sender], "You have already purchased this listing");
        require(msg.value == listings[_id].price, "Incorrect payment amount");
        
        purchasers[_id][msg.sender] = true;
        purchaseTimestamps[_id][msg.sender] = block.timestamp;
        listings[_id].NOU++;
        
        emit ListingSold(_id, msg.sender);
        
        listings[_id].owner.transfer(msg.value);
    }
    
    // Remove a data listing
    function removeListing(uint256 _id) public onlyListingOwner(_id) {
        require(listingExists[_id], "Listing does not exist");
        
        delete listings[_id];
        delete listingExists[_id];
        delete listingOwners[msg.sender][_id];
    }
    
    // Get a data listing for use
    function getListingForUse(uint256 _id) public view returns (address, string memory, string memory) {
        require(purchasers[_id][msg.sender], "You have not purchased this listing");
        return (listings[_id].owner, listings[_id].name, listings[_id].description);
    }
    
    // Get a data listing by ID
    function getListing(uint256 _id) public view returns (address, string memory, string memory, uint256, uint256) {
        require(listingExists[_id], "Listing does not exist");
        return (listings[_id].owner, listings[_id].name, listings[_id].image, listings[_id].price, listings[_id].NOU);
    }
    
    // Get the total number of listings
    function getTotalListings() public view returns (uint256) {
        return listingCount;
    }
}
