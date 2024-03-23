// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is Ownable {
    IERC20 public votingToken;
    uint256 public minimumQuorum;
    uint256 public votingPeriod;

    struct Proposal {
        string description;
        bytes callData;
        address recipient;
        uint256 voteCount;
        bool executed;
        uint256 creationTime;
        mapping(address => bool) voters;
    }

    Proposal[] public proposals;

    event ProposalCreated(uint256 indexed proposalId, string description, address recipient);
    event Voted(uint256 indexed proposalId, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalId, bool success);

    constructor(IERC20 _votingToken, uint256 _minimumQuorum, uint256 _votingPeriod) {
        votingToken = _votingToken;
        minimumQuorum = _minimumQuorum;
        votingPeriod = _votingPeriod;
    }

   // Create a new proposal
function createProposal(string memory _description, bytes memory _callData, address _recipient) public onlyOwner {
    Proposal storage newProposal = proposals.push(); // push an empty struct
    newProposal.description = _description;
    newProposal.callData = _callData;
    newProposal.recipient = _recipient;
    newProposal.voteCount = 0;
    newProposal.executed = false;
    newProposal.creationTime = block.timestamp;

    emit ProposalCreated(proposals.length - 1, _description, _recipient);
}


    function vote(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.voters[msg.sender], "Already voted");
        require(block.timestamp <= proposal.creationTime + votingPeriod, "Voting period has ended");

        uint256 votes = votingToken.balanceOf(msg.sender);
        require(votes > 0, "No votes available");

        proposal.voteCount += votes;
        proposal.voters[msg.sender] = true;

        emit Voted(_proposalId, msg.sender, votes);
    }

    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(block.timestamp >= proposal.creationTime + votingPeriod, "Voting period not yet ended");
        require(proposal.voteCount >= minimumQuorum, "Quorum not reached");

        proposal.executed = true;
        (bool success,) = proposal.recipient.call(proposal.callData);
        
        emit ProposalExecuted(_proposalId, success);
    }

    function getProposalsCount() public view returns (uint256) {
        return proposals.length;
    }

    function hasVoted(uint256 _proposalId, address _voter) public view returns (bool) {
        return proposals[_proposalId].voters[_voter];
    }
}
