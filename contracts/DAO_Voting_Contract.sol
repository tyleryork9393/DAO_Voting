// SPDX-License-Identifier: MIT
// Contract created to create proposals, vote, and execute proposals
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract DAOVoting is Ownable, ReentrancyGuard, Pausable {
    IERC20 public governanceToken;  // ERC20 token for voting weight

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        mapping(address => bool) hasVoted;  // Prevent double-voting
    }

    Proposal[] public proposals;
    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant QUORUM_PERCENT = 1;  // 1% of total supply must vote for testing. In production it would be 30% to 50% per needs.

    // Event state for voting
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 proposalId);
    event DebugMessage(string message, uint256 value, address caller);

    constructor(address _governanceToken) Ownable(msg.sender) {
        governanceToken = IERC20(_governanceToken);
    }

    // Create a new proposal
    function createProposal(string memory _description) external onlyOwner whenNotPaused {
        uint256 proposalId = proposals.length;
        proposals.push();
        Proposal storage p = proposals[proposalId];
        
        p.id = proposalId;
        p.description = _description;
        p.voteStart = block.timestamp;
        p.voteEnd = block.timestamp + VOTING_PERIOD;
        p.yesVotes = 0;
        p.noVotes = 0;
        p.executed = false;

        emit ProposalCreated(proposalId, _description);
    }

    // Vote on a proposal
    function vote(uint256 _proposalId, bool _support) external nonReentrant whenNotPaused {
        Proposal storage p = proposals[_proposalId];
       
        // Safety checks
        require(_proposalId < proposals.length, "Proposal ID is invalid");
        require(block.timestamp >= p.voteStart && block.timestamp <= p.voteEnd, "Voting not active");
        require(!p.hasVoted[msg.sender], "Already voted");
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");
      
        // Add our vote to the yes/no vote count
        p.hasVoted[msg.sender] = true;
        if (_support) {
            p.yesVotes += weight;
        } else {
            p.noVotes += weight;
        }
        emit Voted(_proposalId, msg.sender, _support, weight);
    }

    // Execute proposal if passed
    function executeProposal(uint256 _proposalId) external nonReentrant {
        Proposal storage p = proposals[_proposalId];
        
        // Safety checks to ensure we can execute the proposal
        require(block.timestamp > p.voteEnd, "Voting not ended");
        require(!p.executed, "Already executed");
        uint256 totalVotes = p.yesVotes + p.noVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        // Ensure at least a certain % have voted, per our quorum set earlier
        require(totalVotes >= (totalSupply * QUORUM_PERCENT) / 100, "Quorum not met");
        require(p.yesVotes > p.noVotes, "Proposal did not pass");

        p.executed = true;

        // Execute contents of proposal logic here if the proposal passed 
       
        emit ProposalExecuted(_proposalId);
    }

    // Owner emergency functions
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // View functions for testing
    function isVotingActive(uint256 _proposalId) public view returns (bool)
    {
        Proposal storage p = proposals[_proposalId];
        return block.timestamp >= p.voteStart && block.timestamp <= p.voteEnd;

    }

    function getProposalIntegrity(uint256 _proposalId) public view returns(uint256 id, bool isValid)
    {
        if(_proposalId < proposals.length)
        {
            Proposal storage p = proposals[_proposalId];
            isValid = bytes(p.description).length > 0 && p.voteStart > 0; // We have bytes IE not corrupted data and a vote start value, IE uncorrupted proposal
            return (p.id, isValid);
        }
        return (0, false);
    }

    function getPausedState() public view returns (bool)
    {
        return Pausable.paused(); // call the internal state via pausables scope
    }

    function getProposalCount() public view returns(uint256)
    {
        return proposals.length; // confirm that we are infact not failing on the proposal prechecks
    }

    function getTokenBalance(address voter) public view returns(uint256)
    {
        return governanceToken.balanceOf(voter);
    } 

}