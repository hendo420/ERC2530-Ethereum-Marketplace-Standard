pragma solidity ^0.8.0;

import "./IERC2530.sol";

contract ERC2530WithFeedback is IERC2530, ERC2530 {
    struct Feedback {
        address author;
        uint256 listingId;
        uint8 rating;
        string comment;
    }

    mapping(uint256 => Feedback[]) private _feedbacks;

    event FeedbackSubmitted(address indexed author, uint256 indexed listingId, uint8 rating, string comment);

    constructor(IERC20 token) ERC2530(token) {}

    function submitFeedback(uint256 listingId, uint8 rating, string calldata comment) external {
        require(rating >= 1 && rating <= 5, "ERC2530WithFeedback: rating must be between 1 and 5");

        Feedback memory newFeedback = Feedback(msg.sender, listingId, rating, comment);
        _feedbacks[listingId].push(newFeedback);

        emit FeedbackSubmitted(msg.sender, listingId, rating, comment);
    }

    function getFeedback(uint256 listingId, uint256 index) external view returns (address, uint8, string memory) {
        Feedback storage feedback = _feedbacks[listingId][index];
        return (feedback.author, feedback.rating, feedback.comment);
    }

    function getFeedbackCount(uint256 listingId) external view returns (uint256) {
        return _feedbacks[listingId].length;
    }
}
