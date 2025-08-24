// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title FundMe
 * @dev Hợp đồng crowdfunding phi tập trung
 * @notice Cho phép người dùng gửi ETH và owner rút tiền
 */
contract FundMe {
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
    }

    /**
     * Returns the latest answer.
     */
    function getPrice() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return int256(answer) * 1e10;
    }

    function getDecimals() public view returns (uint8) {
        return dataFeed.decimals();
    }

    /**
     * @dev Hàm nhận tiền từ người dùng
     * @notice Gửi ETH vào hợp đồng để ủng hộ dự án
     */
    function fund() public payable {
        // Kiểm tra số lượng ETH tối thiểu (1 ETH = 1e18 Wei)
        require(msg.value > 1e18, "You need to spend more ETH!");
    }

    /**
     * @dev Lấy số dư hiện tại của contract
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Hàm rút tiền cho owner (sẽ implement sau)
     * @notice Chỉ owner mới có thể rút toàn bộ số dư
     */
    /*
    function withdraw() public {
        // TODO: Check owner permissions
        // TODO: Transfer all balance to owner
        // TODO: Reset funding data
    }
    */
}
