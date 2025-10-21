// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


library PriceConverter {
    function getPrice() internal pure returns (uint256) {

        int256 answer = 4000 * 1e8; // Mocked price for testing purposes

        return uint256(answer * 10000000000); 
        // to convert to 18 decimals
        //cast int256 to uint256

    }

    function getConversionRate(uint256 ethAmount)  internal pure returns (uint256) {
        uint256 ethPrice = getPrice();

        uint256 amountInUsd = ( ethPrice * ethAmount) / 1e18;
        return amountInUsd;
        
    }
}
