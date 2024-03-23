// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyTraceability is Ownable {
    struct EnergySource {
        address owner;
        string sourceType;
        uint256 capacity;
        string location;
        bool isActive;
    }

    struct ProductionLog {
        uint256 timestamp;
        uint256 amountProduced;
    }

    struct EnergyTransaction {
        uint256 timestamp;
        address buyer;
        address seller;
        uint256 amount;
        uint256 sourceId;
    }

    EnergySource[] public energySources;
    mapping(uint256 => ProductionLog[]) public productionLogs;
    EnergyTransaction[] public energyTransactions;

    event EnergySourceRegistered(uint256 indexed sourceId, address owner, string sourceType, 
    uint256 capacity, string location);
    event ProductionLogged(uint256 indexed sourceId, uint256 timestamp, uint256 amountProduced);
    event EnergyTransactionRecorded(uint256 indexed transactionId, uint256 timestamp, 
    address buyer, address seller, uint256 amount, uint256 sourceId);

    function registerEnergySource(string memory _sourceType, uint256 _capacity, string memory _location) 
    public onlyOwner {
        uint256 sourceId = energySources.length;
        energySources.push(EnergySource({
            owner: msg.sender,
            sourceType: _sourceType,
            capacity: _capacity,
            location: _location,
            isActive: true
        }));
        emit EnergySourceRegistered(sourceId, msg.sender, _sourceType, _capacity, _location);
    }

    function logProduction(uint256 _sourceId, uint256 _amountProduced) public {
        EnergySource memory source = energySources[_sourceId];
        require(source.owner == msg.sender, "Not the owner of the energy source");
        require(source.isActive, "Energy source is not active");
        productionLogs[_sourceId].push(ProductionLog({
            timestamp: block.timestamp,
            amountProduced: _amountProduced
        }));
        emit ProductionLogged(_sourceId, block.timestamp, _amountProduced);
    }

    function recordEnergyTransaction(uint256 _sourceId, address _buyer, address _seller, uint256 _amount) 
    public onlyOwner {
        EnergySource memory source = energySources[_sourceId];
        require(source.isActive, "Energy source is not active");
        uint256 transactionId = energyTransactions.length;
        energyTransactions.push(EnergyTransaction({
            timestamp: block.timestamp,
            buyer: _buyer,
            seller: _seller,
            amount: _amount,
            sourceId: _sourceId
        }));
        emit EnergyTransactionRecorded(transactionId, block.timestamp, _buyer, _seller, _amount, _sourceId);
    }

    function toggleEnergySourceActiveState(uint256 _sourceId) public {
        EnergySource storage source = energySources[_sourceId];
        require(source.owner == msg.sender, "Not the owner of the energy source");
        source.isActive = !source.isActive;
    }

    // Additional functions as needed...
}
