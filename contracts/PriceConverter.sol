// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title PriceConverter
 * @dev Library để convert ETH prices sử dụng Chainlink price feeds
 * @notice Cung cấp functions để lấy ETH price và convert ETH sang USD
 */
library PriceConverter {
    /**
     * @dev Lấy giá ETH/USD từ Chainlink price feed
     * @param priceFeed Chainlink AggregatorV3Interface
     * @return ETH price in USD với 18 decimals
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate trong 18 digits
        // Chainlink price feeds return 8 decimals, cần * 1e10 để có 18 decimals
        return uint256(answer * 10000000000);
    }

    /**
     * @dev Convert ETH amount sang USD equivalent
     * @param ethAmount Số lượng ETH trong wei
     * @param priceFeed Chainlink price feed interface
     * @return USD value với 18 decimals
     */
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // ETH/USD conversion rate sau khi adjust decimals
        return ethAmountInUsd;
    }
}