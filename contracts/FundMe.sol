// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

// Define a contract that is able
// Accept some time of payment
contract FundMe{
    
    // Keep track of who sent us something, lets keep track of who sent us something
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders; 
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Ingerface(_priceFeed);
        owner = msg.sender;    
    }
    
    // fund the contract with a minimum usd value
    function fund() public payable{
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to start with more Eth :-(");
        addressToAmountFunded[msg.sender] += msg.value; //msg.sender (sender) and msg.value (how much the sent) are keywords in every contract
        funders.push(msg.sender);
        
        // What is the eth to usd converstion rate ?
    }
    
    // 
    function getVersion() public view returns(uint256){
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    // 
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFee = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFee.latestRoundData();
        
        return uint256(answer * 10000000000);
        //2903.20928508
    }
    
    // 
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
    
    // 
    modifier onlyOwner {
        require(msg.sender == owner, "cannot withdraw :-|");
        _;
    }
    
    // 
    function withdraw() payable public{
        // this is a reference to current contract we are in.
        // & we only want the contract ower to withdraw
        
        msg.sender.transfer(address(this).balance);
        
        // clear funders
        for(uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        
    }
}