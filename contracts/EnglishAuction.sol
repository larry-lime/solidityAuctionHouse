// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {
    uint256 public initialPrice;
    uint256 public biddingPeriod;
    uint256 public minimumPriceIncrement;
    uint256 public lastBidTime;
    address public highestBidder;
    uint256 public highestBid;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        uint256 _initialPrice,
        uint256 _biddingPeriod,
        uint256 _minimumPriceIncrement
    ) Auction(_sellerAddress, _judgeAddress, address(0), 0) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;
        highestBid = initialPrice;
        lastBidTime = block.number;
    }

    function bid() public payable {
        require(
            block.number <= lastBidTime + biddingPeriod,
            "Bidding period has ended"
        );
        require(
            msg.value >= highestBid + minimumPriceIncrement,
            "Bid not high enough"
        );

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        lastBidTime = block.number; // Update the last bid time
    }

    function getWinner() public view override returns (address winner) {
        if (block.number > lastBidTime + biddingPeriod) {
            return highestBidder;
        }
        return address(0); // No winner if the auction is still ongoing
    }

    // Additional functions as needed, such as withdraw()
}
