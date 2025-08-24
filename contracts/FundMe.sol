// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title FundMe
 * @dev Hợp đồng crowdfunding phi tập trung
 * @notice Cho phép người dùng gửi ETH và owner rút tiền
 */
contract FundMe {
    
    /**
     * @dev Hàm nhận tiền từ người dùng
     * @notice Gửi ETH vào hợp đồng để ủng hộ dự án
     */
    function fund() public payable {
        // TODO: Implement minimum USD value requirement
        // TODO: Keep track of funders and amounts
        // TODO: Emit events for transparency
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
