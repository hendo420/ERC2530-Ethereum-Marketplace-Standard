pragma solidity ^0.8.0;

import "./IERC2530.sol";

contract ERC2530WithFeedbackAndDispute is IERC2530, ERC2530 {
    struct Feedback {
        address author;
        uint256 listingId;
        uint8 rating;
        string comment;
        bool isDisputed;
    }

    mapping(uint256 => Feedback[]) private _feedbacks;

    event FeedbackSubmitted(address indexed author, uint256 indexed listingId, uint8 rating, string comment);
    event DisputeOpened(uint256 indexed listingId, uint256 indexed feedbackIndex);
    event DisputeResolved(uint256 indexed listingId, uint256 indexed feedbackIndex, string resolution);

    constructor(IERC20 token) ERC2530(token) {}

    function submitFeedback(uint256 listingId, uint8 rating, string calldata comment) external {
        require(rating >= 1 && rating <= 5, "ERC2530WithFeedback: rating must be between 1 and 5");

        Feedback memory newFeedback = Feedback(msg.sender, listingId, rating, comment, false);
        _feedbacks[listingId].push(newFeedback);

        emit FeedbackSubmitted(msg.sender, listingId, rating, comment);
    }

    function openDispute(uint256 listingId, uint256 feedbackIndex) external {
        Feedback storage feedback = _feedbacks[listingId][feedbackIndex];
        require(!feedback.isDisputed, "ERC2530WithFeedback: dispute already opened");
        feedback.isDisputed = true;

        emit DisputeOpened(listingId, feedbackIndex);
    }

    function resolveDispute(uint256 listingId, uint256 feedbackIndex, string calldata resolution) external onlyOwner {
        Feedback storage feedback = _feedbacks[listingId][feedbackIndex];
        require(feedback.isDisputed, "ERC2530WithFeedback: dispute not opened");
        feedback.isDisputed = false;

        emit DisputeResolved(listingId, feedbackIndex, resolution);
    }

    function getFeedback(uint256 listingId, uint256 index) external view returns (address, uint8, string memory, bool) {
        Feedback storage feedback = _feedbacks[listingId][index];
        return (feedback.author, feedback.rating, feedback.comment, feedback.isDisputed);
    }

    function getFeedbackCount(uint256 listingId) external view returns (uint256) {
        return _feedbacks[listingId].length;
    }
}
