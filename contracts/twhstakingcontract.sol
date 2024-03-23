// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TWHStaking is ReentrancyGuard {
    IERC20 public twhToken;

    struct UserInfo {
        uint256 amount;    // How many TWH tokens the user has staked.
        uint256 stakeTime; // Timestamp when user deposited.
        uint256 endTime;   // Timestamp when the stake period ends.
    }

    mapping(address => UserInfo) public userInfo;

    event Staked(address indexed user, uint256 amount, uint256 endTime);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(IERC20 _twhToken) {
        twhToken = _twhToken;
    }

    function stake(uint256 _amount, uint256 _lockTimeInSeconds) public nonReentrant {
        require(_amount > 0, "Cannot stake 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount == 0 || block.timestamp >= user.endTime, "Existing stake not ended");

        twhToken.transferFrom(msg.sender, address(this), _amount);

        user.amount = _amount;
        user.stakeTime = block.timestamp;
        user.endTime = block.timestamp + _lockTimeInSeconds;

        emit Staked(msg.sender, _amount, user.endTime);
    }

    function withdraw() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "Nothing to withdraw");
        require(block.timestamp >= user.endTime, "Stake is locked");

        uint256 amount = user.amount;
        user.amount = 0;

        twhToken.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function balanceOf(address _user) public view returns (uint256) {
        return userInfo[_user].amount;
    }

    function stakeTimeOf(address _user) public view returns (uint256) {
        return userInfo[_user].stakeTime;
    }

    function endTimeOf(address _user) public view returns (uint256) {
        return userInfo[_user].endTime;
    }
}
