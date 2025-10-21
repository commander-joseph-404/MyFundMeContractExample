// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {

        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer, , ,) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000); 
        // to convert to 18 decimals
        //cast int256 to uint256

    }

    function getConversionRate(uint256 ethAmount)  internal view returns (uint256) {
        uint256 ethPrice = getPrice();

        uint256 amountInUsd = ( ethPrice * ethAmount) / 1e18;
        return amountInUsd;
        
    }
}
