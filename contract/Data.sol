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
    
    
    // Define mapping for data listings
    mapping (address => mapping (uint => uint)) startTime;

    mapping(uint256 => DataListing) public listings;
    uint256 public listingCount;
    
    // Define events
    event ListingCreated(uint256 indexed id, string description, uint256 price, address owner);
    event ListingSold(uint256 indexed id, address indexed buyer);
    
    // Create a new data listing
    function createListing(string calldata _name, string calldata _description,string calldata _image, uint256 _price) public {
        listings[listingCount] = DataListing(_name, _description, _image, _price, payable(msg.sender), 0);
        emit ListingCreated(listingCount, _description, _price, msg.sender);
        listingCount++;
    }
    
    // Purchase a data listing
    function purchaseListing(uint256 _id) public payable {
        require(msg.value == listings[_id].price, "Incorrect payment amount");
        listings[_id].NOU++;
        startTime[msg.sender][_id] = block.timestamp;
        emit ListingSold(_id, msg.sender);
        listings[_id].owner.transfer(msg.value);
    }

    //allows removal of a listing
    function removeListing (uint _id) public{
        delete listings[_id];
    }
    
    function getListingForUse(uint _id) public view returns(address,string memory,string memory
    ) {
       return(listings[_id].owner, listings[_id].name, listings[_id].description);
    }
         
    //function to get a listing by Id
    function getListing(uint _id) public view returns(address, string memory, string memory, uint, uint) {
       return(listings[_id].owner, listings[_id].name, listings[_id].image, listings[_id].price, listings[_id].NOU);
    }

    //function to get total number listings
    function gettotallistings() public view returns(uint){
        return(listingCount-1);
    }
    
}
