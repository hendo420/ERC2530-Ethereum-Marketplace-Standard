pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC2530 {
    event ListingCreated(uint256 indexed listingId, address indexed seller, uint256 price, string data);
    event ListingPurchased(uint256 indexed listingId, address indexed buyer, uint256 price);
    event ListingCanceled(uint256 indexed listingId, address indexed seller);

    function createListing(uint256 price, string calldata data) external;
    function purchaseListing(uint256 listingId) external;
    function cancelListing(uint256 listingId) external;
}

contract ERC2530 is IERC2530, Ownable {
    struct Listing {
        address seller;
        uint256 price;
        string data;
        bool active;
    }

    IERC20 private _token;
    uint256 private _listingCounter;
    mapping(uint256 => Listing) private _listings;

    constructor(IERC20 token) {
        _token = token;
    }

    function createListing(uint256 price, string calldata data) external override {
        _listingCounter++;
        _listings[_listingCounter] = Listing(msg.sender, price, data, true);
        emit ListingCreated(_listingCounter, msg.sender, price, data);
    }

    function purchaseListing(uint256 listingId) external override {
        Listing storage listing = _listings[listingId];
        require(listing.active, "ERC2530: listing not active");
        require(_token.transferFrom(msg.sender, listing.seller, listing.price), "ERC2530: token transfer failed");
        listing.active = false;
        emit ListingPurchased(listingId, msg.sender, listing.price);
    }

    function cancelListing(uint256 listingId) external override {
        Listing storage listing = _listings[listingId];
        require(listing.seller == msg.sender, "ERC2530: not the seller");
        require(listing.active, "ERC2530: listing not active");
        listing.active = false;
        emit ListingCanceled(listingId, msg.sender);
    }

    function getListing(uint256 listingId) external view returns (address, uint256, string memory, bool) {
        Listing storage listing = _listings[listingId];
        return (listing.seller, listing.price, listing.data, listing.active);
    }
}
