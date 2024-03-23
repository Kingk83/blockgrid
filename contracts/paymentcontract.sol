// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TWHPayment is ReentrancyGuard, Ownable {
    IERC20 public twhToken;

    // Address where collected fees will be sent
    address public feeCollector;

    // Fee rate as a percentage of the transaction amount (1% = 100, 0.5% = 50, max is 100%)
    uint256 public feeRate;

    event PaymentMade(address indexed from, address indexed to, uint256 amount, uint256 fee);
    event FeeCollectorChanged(address indexed newFeeCollector);
    event FeeRateChanged(uint256 newFeeRate);

    constructor(IERC20 _twhToken, address _feeCollector, uint256 _feeRate) {
        require(_feeRate <= 10000, "Fee rate too high"); // Max 100% fee
        twhToken = _twhToken;
        feeCollector = _feeCollector;
        feeRate = _feeRate;
    }

    // Allows a user to send TWH tokens to another address, deducting a fee
    function makePayment(address _to, uint256 _amount) external nonReentrant {
        require(_to != address(0), "Cannot pay to the zero address");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 fee = calculateFee(_amount);
        uint256 amountAfterFee = _amount - fee;

        require(twhToken.transferFrom(msg.sender, _to, amountAfterFee), "Payment failed");
        if (fee > 0) {
            require(twhToken.transferFrom(msg.sender, feeCollector, fee), "Fee transfer failed");
        }

        emit PaymentMade(msg.sender, _to, amountAfterFee, fee);
    }

    function calculateFee(uint256 _amount) public view returns (uint256) {
        return _amount * feeRate / 10000;
    }

    // Update the feeCollector and feeRate by the owner
    function setFeeCollector(address _newFeeCollector) external onlyOwner {
        require(_newFeeCollector != address(0), "Cannot set zero address");
        feeCollector = _newFeeCollector;
        emit FeeCollectorChanged(_newFeeCollector);
    }

    function setFeeRate(uint256 _newFeeRate) external onlyOwner {
        require(_newFeeRate <= 10000, "Fee rate too high");
        feeRate = _newFeeRate;
        emit FeeRateChanged(_newFeeRate);
    }
    
    // In case the contract accepts Ether, withdraw functionality for the owner
    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // To accept ETH payments
    receive() external payable {}
}
