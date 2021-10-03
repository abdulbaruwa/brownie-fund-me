// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// Define a contract that is able
// Accept some time of payment
contract FundMe {
    // Keep track of who sent us something, lets keep track of who sent us something
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    // fund the contract with a minimum usd value
    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to start with more Eth :-("
        );
        addressToAmountFunded[msg.sender] += msg.value; //msg.sender (sender) and msg.value (how much the sent) are keywords in every contract
        funders.push(msg.sender);

        // What is the eth to usd converstion rate ?
    }

    //
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    //
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000);
    }

    //
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD  * precision) / price;
    }

    //
    modifier onlyOwner() {
        require(msg.sender == owner, "cannot withdraw :-|");
        _;
    }

    //
    function withdraw() public payable {
        // this is a reference to current contract we are in.
        // & we only want the contract ower to withdraw

        msg.sender.transfer(address(this).balance);

        // clear funders
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
