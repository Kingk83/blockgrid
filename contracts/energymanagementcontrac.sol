// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyManagement is Ownable {
    IERC20 public twhToken;

    struct UserEnergyAccount {
        uint256 energyProduced; // in kWh
        uint256 energyConsumed; // in kWh
        uint256 lastUpdate;     // Timestamp of the last update
        uint256 demandResponseCredits; // Credits earned through demand response
    }

    mapping(address => UserEnergyAccount) public userAccounts;

    // Event declarations
    event EnergyProduced(address indexed user, uint256 amount);
    event EnergyConsumed(address indexed user, uint256 amount);
    event EnergyPurchased(address indexed buyer, address indexed seller, uint256 amount);
    event DemandResponseParticipation(address indexed user, uint256 creditsEarned);

    constructor(IERC20 _twhToken) {
        twhToken = _twhToken;
    }

    // Log energy production (could be called by an IoT device via an off-chain service)
    function logEnergyProduction(uint256 _amount) external {
        UserEnergyAccount storage account = userAccounts[msg.sender];
        account.energyProduced += _amount;
        account.lastUpdate = block.timestamp;
        emit EnergyProduced(msg.sender, _amount);
    }

    // Log energy consumption (could be triggered by IoT device readings)
    function logEnergyConsumption(uint256 _amount) external {
        UserEnergyAccount storage account = userAccounts[msg.sender];
        account.energyConsumed += _amount;
        account.lastUpdate = block.timestamp;
        emit EnergyConsumed(msg.sender, _amount);
    }

    // Purchase energy from another user
    function purchaseEnergy(address _seller, uint256 _amount, uint256 _tokenAmount) external {
        require(twhToken.transferFrom(msg.sender, _seller, _tokenAmount), "Payment failed");
        userAccounts[_seller].energyProduced -= _amount;
        userAccounts[msg.sender].energyConsumed += _amount;
        emit EnergyPurchased(msg.sender, _seller, _amount);
    }

    // Users participate in demand response by reducing consumption; rewarded with credits
    function participateInDemandResponse(uint256 _reducedAmount) external {
        UserEnergyAccount storage account = userAccounts[msg.sender];
        uint256 creditsEarned = calculateDemandResponseCredits(_reducedAmount);
        account.demandResponseCredits += creditsEarned;
        emit DemandResponseParticipation(msg.sender, creditsEarned);
    }

    // Calculate credits for demand response (simplified version)
    function calculateDemandResponseCredits(uint256 _reducedAmount) public pure returns (uint256) {
        return _reducedAmount;
    }

    // Admin or the contract itself can reward users with TWH tokens based on their credits
    function rewardDemandResponseParticipants(address _participant, uint256 _creditAmount) external onlyOwner {
        UserEnergyAccount storage account = userAccounts[_participant];
        require(account.demandResponseCredits >= _creditAmount, "Not enough credits");
        account.demandResponseCredits -= _creditAmount;
        require(twhToken.transfer(_participant, _creditAmount), "Reward transfer failed");
    }
}
