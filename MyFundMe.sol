// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import  {PriceConverter} from "./MyOwnPriceConverter.sol";

using PriceConverter for uint256;

error NotOwner();
error fundedAmountLessThan$5();

contract MyFundMe {
    uint256 public constant MINIMUM_USD = 5 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;
    mapping(address => bool) funderExists;


    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {

        if (msg.value.getConversionRate()< MINIMUM_USD) {
            revert fundedAmountLessThan$5();
        }
        
        if (!funderExists[msg.sender]) {
            funderExists[msg.sender] = true;
            funders.push(msg.sender);
        }
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        delete funders;
        
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");

        require(success, "withdraw Failed");

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

}
