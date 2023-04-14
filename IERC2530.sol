pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC2530 {
    event ListingCreated(uint256 indexed listingId, address indexed seller, uint256 price, string data);
    event ListingPurchased(uint256 indexed listingId, address indexed buyer, uint256 price);
    event ListingCanceled(uint256 indexed listingId, address indexed seller);

    function createListing(uint256 price, string calldata data) external;
    function purchaseListing(uint256 listingId) external;
    function cancelListing(uint256 listingId) external;
    function getListing(uint256 listingId) external view returns (address, uint256, string memory, bool);
    function token() external view returns (IERC20);
}
