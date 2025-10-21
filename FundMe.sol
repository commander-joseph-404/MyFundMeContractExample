// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import  {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
error fundedAmountLessThan$5();

contract FundMe {
    using PriceConverter for uint256;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 1e18;
    mapping(address => bool) funderExists;

    // funderExists helps to check if the funder is already in the funders array
    // to avoid duplicate entries

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }


    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    function fund() public payable {

        if (msg.value.getConversionRate() <= MINIMUM_USD) {
            revert fundedAmountLessThan$5();
        }
        if (!funderExists[msg.sender]) {
            funderExists[msg.sender] = true;
            funders.push(msg.sender);
        }
        addressToAmountFunded[msg.sender] += msg.value;

    }

    function withdraw() public onlyOwner() {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        delete funders;
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}

