**DAO Voting Consensus System**

Overview
This project demonstrates a decentralized autonomous organization (DAO) voting system built on Ethereum using Solidity smart contracts. It showcases foundational blockchain infrastructure, including token governance and consensus mechanisms for proposal creation, voting, and execution. The system emphasizes security features such as reentrancy guards, quorum requirements, and dynamic vote weighting to prevent manipulation by large token holders (e.g., whales) and ensure fair decentralized decision-making.

**Key concepts:**
 + Consensus Mechanisms: Utilizes token-weighted voting with quorum thresholds (configurable, e.g., 1% for testing, 30-50% in production) to achieve decentralized agreement.
 + Governance Token: An ERC-20 compliant token for voting power.
 + Proposal Lifecycle: Creation (owner-only), voting (time-bound, non-reentrant), execution (post-quorum validation).
 + Security: Ownable contracts, pausable in emergencies, vote duplication prevention via mappings, timestamp-based validity checks.
 + Testing Focus: Designed for Remix IDE simulation with test wallets, minting, and multi-wallet voting to illustrate real-world DAO operations.
This portfolio project highlights proficiency in Solidity development, smart contract architecture, and blockchain engineering principles.

Prerequisites
 + Remix IDE: Use the online Remix Ethereum IDE (remix.ethereum.org) for compilation, deployment, and testing on a simulated blockchain (e.g., JavaScript VM).
 + Solidity Version: Compatible with Solidity ^0.8.0.
 + No External Dependencies: Relies on OpenZeppelin imports for ERC20, Ownable, ReentrancyGuard, and Pausable (include via Remix file imports or GitHub URLs).

**[Smart Contracts]**
1. _MockGovernanceToken.sol_
   An ERC-20 compliant governance token used for voting weight in the DAO system.

Imports:
@openzeppelin/contracts/token/ERC20/ERC20.sol
@openzeppelin/contracts/access/Ownable.sol
Key Features:
 + Ownable by deployer.
 + Initial mint: 1,000,000 tokens to deployer.
 + Mint function for additional tokens (owner-only).
 + Standard ERC-20 functions: balanceOf, transfer, totalSupply, name ("Governance Token"), symbol ("TEST").

2. _DAO_Voting.sol_
   The core DAO contract for managing proposals, voting, and execution.

Imports:
@openzeppelin/contracts/access/Ownable.sol
@openzeppelin/contracts/security/ReentrancyGuard.sol
@openzeppelin/contracts/security/Pausable.sol
@openzeppelin/contracts/token/ERC20/IERC20.sol (for governance token interface)
Key Features:
 + Ownable and pausable for emergency control.
 + ReentrancyGuard to prevent reentrant attacks.
 + Proposal struct: ID, description, voteStart, voteEnd, yesVotes, noVotes, executed.
 + Mapping to track voted addresses per proposal.
 + Constants: VOTING_PERIOD (3 days in blocks), QUORUM_PERCENT (1% for testing; adjust to 30-50% in production).
 + Dynamic weighting: Scales votes based on token balance to mitigate whale dominance.
 + Events: ProposalCreated, Voted, ProposalExecuted.


**Usage in Remix IDE**
[1] Setup:
Open Remix IDE.
Create two files: MockGovernanceToken.sol and DAO_Voting.sol.
Paste the contract code (ensure OpenZeppelin imports are loaded via Remix's GitHub import feature).
Enable auto-compile.

[2] Deploy MockGovernanceToken:
Select the contract in Remix.
Choose an account (e.g., first test wallet).
Click "Deploy".
Note the deployed contract address.
Use mint(address to, uint256 amount) to distribute tokens to test wallets (e.g., mint 1000 tokens each).
Verify balances with balanceOf(address).

[3] Deploy DAO_Voting:
Select the contract.
In the "Deploy" field, input the MockGovernanceToken address as the constructor argument.
Deploy using the owner account.
Verify deployment via transaction logs.

[4] Create and Vote on Proposals:
Switch to owner account.
Call createProposal(string description) (e.g., "Implement Staking").
Switch to test wallets with tokens.
Call vote(uint256 proposalId, bool support) (e.g., proposalId=0, support=true).
Attempt double-voting to see reentrancy guard in action (should revert with "Already voted").
Use view functions like isVotingActive(uint256) or getProposalCount() to monitor.

[5] Execute Proposal:
After voting period (simulate time in Remix VM if needed).
Call executeProposal(uint256 proposalId).
Check events for confirmation.

[6] Testing Safeguards:
Pause/unpause for emergencies.
Test quorum: Ensure total votes meet threshold.
View events and logs for ProposalCreated, Voted, ProposalExecuted.
