// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";
import "hardhat/console.sol";

contract DutchAuction is Auction {
    uint256 public initialPrice;
    uint256 public biddingPeriod;
    uint256 public offerPriceDecrement;

    // TODO: place your code here
    uint256 public startBlock;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        uint256 _initialPrice,
        uint256 _biddingPeriod,
        uint256 _offerPriceDecrement
    ) Auction(_sellerAddress, _judgeAddress, address(0), 0) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;
        startBlock = time();

        // TODO: place your code here
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 blocksPassed = block.number - startBlock;

        // Ensure blocksPassed does not exceed biddingPeriod
        if (blocksPassed > biddingPeriod) {
            blocksPassed = biddingPeriod;
        }

        uint256 priceDecrease = blocksPassed * offerPriceDecrement;

        // Ensure price does not go below reserve (minimum) price
        if (initialPrice > priceDecrease) {
            return initialPrice - priceDecrease;
        } else {
            return 0; // The minimum price reached
        }
    }

    function bid() public payable {
        // TODO: place your code here
        // require time() < biddingPeriod, "Bidding period has ended.";
        require(time() <= startBlock + biddingPeriod, "Auction has ended");
        require(msg.value >= getCurrentPrice(), "Bid is too low");
    }
}
