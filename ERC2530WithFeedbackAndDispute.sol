pragma solidity ^0.8.0;

import "./IERC2530.sol";

contract ERC2530WithDispute is IERC2530, ERC2530 {
    struct Dispute {
        uint256 listingId;
        address buyer;
        string reason;
        bool isResolved;
        string resolution;
    }

    mapping(uint256 => Dispute) private _disputes;

    event DisputeOpened(uint256 indexed listingId, address indexed buyer, string reason);
    event DisputeResolved(uint256 indexed listingId, string resolution);

    constructor(IERC20 token) ERC2530(token) {}

    function openDispute(uint256 listingId, string calldata reason) external {
        (, , , bool isPurchased) = getListing(listingId);
        require(isPurchased, "ERC2530WithDispute: listing not purchased");

        Dispute storage dispute = _disputes[listingId];
        require(dispute.buyer == address(0), "ERC2530WithDispute: dispute already opened");

        dispute.listingId = listingId;
        dispute.buyer = msg.sender;
        dispute.reason = reason;
        dispute.isResolved = false;

        emit DisputeOpened(listingId, msg.sender, reason);
    }

    function resolveDispute(uint256 listingId, string calldata resolution) external onlyOwner {
        Dispute storage dispute = _disputes[listingId];
        require(dispute.buyer != address(0), "ERC2530WithDispute: dispute not opened");
        require(!dispute.isResolved, "ERC2530WithDispute: dispute already resolved");

        dispute.isResolved = true;
        dispute.resolution = resolution;

        emit DisputeResolved(listingId, resolution);
    }

    function getDispute(uint256 listingId) external view returns (address, string memory, bool, string memory) {
        Dispute storage dispute = _disputes[listingId];
        return (dispute.buyer, dispute.reason, dispute.isResolved, dispute.resolution);
    }
}
