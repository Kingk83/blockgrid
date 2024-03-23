// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ElectricityPriceOracle is Ownable {
    // Stores the latest electricity price (e.g., in cents per kWh)
    uint256 public latestElectricityPrice;

    // Event that is emitted every time the price is updated
    event PriceUpdated(uint256 newPrice);

    // Function to update the electricity price
    // In a real-world scenario, this could be automated using an off-chain oracle
    function updateElectricityPrice(uint256 _newPrice) public onlyOwner {
        latestElectricityPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    // In a real-world use case, consider mechanisms for validating the source and integrity of the oracle data
}
