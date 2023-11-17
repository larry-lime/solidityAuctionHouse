// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "hardhat/console.sol";

contract Auction {
    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint256 winningPrice;

    // TODO: place your code here
    mapping(address => uint256) internal balances; // Balances to track funds
    bool internal done = false; // Flag to track if auction has ended

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        address _winnerAddress,
        uint256 _winningPrice
    ) payable {
        judgeAddress = _judgeAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0)) sellerAddress = msg.sender;
        winnerAddress = _winnerAddress;
        winningPrice = _winningPrice;
        balances[winnerAddress] = msg.value; // Assume the winner sends the bid amount
    }

    // This is used in testing.
    // You should use this instead of block.number directly.
    // You should not modify this function.
    function time() public view returns (uint256) {
        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint256 price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public virtual {
        require(
            this.auctionEnded(),
            "Contract value is not equal to winning price."
        );
        require(
            msg.sender == winnerAddress ||
                (judgeAddress == address(0)) ||
                (judgeAddress != address(0) &&
                    (msg.sender == judgeAddress ||
                        msg.sender == winnerAddress)),
            "Unauthorized caller."
        );

        balances[sellerAddress] += winningPrice;
        balances[winnerAddress] -= winningPrice;
        // finalizes the auction
        done = true;
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {
        // if contract value is equal to winning price, then refund
        require(
            this.auctionEnded(),
            "Contract value is not equal to winning price."
        );
        // if judge exists, then only judge or seller can call
        if (judgeAddress != address(0)) {
            require((msg.sender == judgeAddress), "Unauthorized caller.");
        } else {
            require(msg.sender == sellerAddress, "Unauthorized caller.");
        }
        done = true;
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {
        if (done) {
            uint256 amount = balances[msg.sender];
            balances[msg.sender] = 0; // Prevent re-entrancy
            payable(msg.sender).transfer(amount);
        }
    }

    // check if the auction has ended
    function auctionEnded() public view returns (bool) {
        // Check if there exists a winner address
        return winnerAddress != address(0);
    }
}
