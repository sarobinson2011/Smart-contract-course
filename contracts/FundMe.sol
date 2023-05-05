// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; 

contract FundMe {
    using SafeMath for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;

    constructor() {
      owner = msg.sender;
    }

    function fund() public payable {
      uint256 minimumUSD = 50 * 10 ** 18;                 
      require(getConversionRate(msg.value) >= minimumUSD, "you need to send at least $50 worth of ETH");
      addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns(uint256) {
      // Interface address below is for ETH/USD on Sepolia - see chain.link/data-feeds/prices
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      (,int256 answer,,,) = priceFeed.latestRoundData();
       return uint256(answer * 10000000000);
    } 

    // 1000000000
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
      uint256 ethPrice = getPrice();
      uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
      return ethAmountInUsd;
    }

    function withdraw() public payable {
      require(msg.sender == owner);
      payable(msg.sender).transfer(address(this).balance);
    }

}

