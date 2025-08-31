// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// Custom errors cho gas efficiency
error NotOwner();
error InsufficientFunding();
error TransferFailed();

/**
 * @title FundMe
 * @dev Hợp đồng crowdfunding phi tập trung với Chainlink price feeds
 * @notice Cho phép người dùng gửi ETH (tối thiểu \$5 USD) và owner rút tiền
 * @author Your Name
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // State variables
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] public s_funders;
    
    // Immutable variable cho gas optimization
    address public immutable i_owner;
    
    // Constant cho minimum funding (5 USD in wei, 18 decimals)
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    
    // Price feed interface
    AggregatorV3Interface private s_priceFeed;

    // Events
    event FundingReceived(address indexed funder, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    /**
     * @dev Constructor sets owner và price feed address
     * @param priceFeedAddress Chainlink price feed contract address
     * 
     * Network addresses:
     * Sepolia ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     * ZKsync Sepolia ETH/USD: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
     */
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    /**
     * @dev Hàm nhận tiền từ người dùng
     * @notice Gửi ETH vào hợp đồng để ủng hộ dự án (tối thiểu \$5 USD)
     */
    function fund() public payable {
        // Sử dụng library function để check minimum USD
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert InsufficientFunding();
        }
        
        // Update amount funded mapping
        s_addressToAmountFunded[msg.sender] += msg.value;
        
        // Add to funders array if first time funding
        if (s_addressToAmountFunded[msg.sender] == msg.value) {
            s_funders.push(msg.sender);
        }
        
        emit FundingReceived(msg.sender, msg.value);
    }

    /**
     * @dev Hàm rút tiền cho owner
     * @notice Chỉ owner mới có thể rút toàn bộ số dư và reset funding data
     */
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        
        // Reset tất cả funders data
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        // Reset funders array
        s_funders = new address[](0);
        
        // Transfer funds using call method (recommended)
        (bool callSuccess, ) = payable(msg.sender).call{value: contractBalance}("");
        if (!callSuccess) {
            revert TransferFailed();
        }
        
        emit FundsWithdrawn(msg.sender, contractBalance);
    }

    /**
     * @dev Cheaper withdraw function - gas optimized version
     */
    function cheaperWithdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        
        // Gas-optimized loop
        address[] memory funders = s_funders;
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        
        (bool success, ) = i_owner.call{value: contractBalance}("");
        if (!success) {
            revert TransferFailed();
        }
        
        emit FundsWithdrawn(i_owner, contractBalance);
    }

    /**
     * @dev Lấy số dư hiện tại của contract
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Lấy phiên bản của price feed
     */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    /**
     * @dev Lấy giá ETH hiện tại từ Chainlink
     */
    function getPrice() public view returns (uint256) {
        return PriceConverter.getPrice(s_priceFeed);
    }

    /**
     * @dev Convert ETH amount sang USD
     * @param ethAmount Số lượng ETH (in wei)
     */
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        return PriceConverter.getConversionRate(ethAmount, s_priceFeed);
    }

    // Getter functions
    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }
    
    function getFundingAmount(address funder) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }
    
    function getNumberOfFunders() public view returns (uint256) {
        return s_funders.length;
    }
    
    function getOwner() public view returns (address) {
        return i_owner;
    }

    // Special functions cho việc nhận ETH trực tiếp
    
    /**
     * @dev Explainer from: https://solidity-by-example.org/fallback/
     * Ether is sent to contract
     *      is msg.data empty?
     *          /   \
     *         yes  no
     *         /     \
     *    receive()?  fallback()
     *     /   \
     *   yes   no
     *  /        \
     *receive()  fallback()
     */
    
    /**
     * @dev Handle pure ETH transfers (no data)
     */
    receive() external payable {
        fund();
    }

    /**
     * @dev Handle ETH transfers with data or unknown function calls
     */
    fallback() external payable {
        fund();
    }
}
