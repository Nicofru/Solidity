// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {

    uint public winningProposalId;
    WorkflowStatus public currentWorkflow;
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegistered(address voterAddress);
    event VoterUnregistered(address voterAddress);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted (address voter, uint proposalId);
    event VotesTallied();
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    mapping (address => Voter) public whitelist;
    Proposal[] public proposals;
    
    modifier onlyWhitelisted(address _address) {
        require(whitelist[_address].isRegistered == true, "Address not whitelisted");
        _;
    }

    modifier workflow(WorkflowStatus expectedWorkflow) {
        require(currentWorkflow == expectedWorkflow, "Worflow not respected");
        _;
    }

    function tallyVotes() external onlyOwner workflow(WorkflowStatus.VotingSessionEnded) {
        bool even;
        uint count;
        uint winner;

        for (uint i = 0; i < proposals.length; i++) {
            if (count < proposals[i].voteCount) {
                count = proposals[i].voteCount;
                winner = i;
                even = false;
            } else if (count == proposals[i].voteCount) {
                even = true;
            }
        }
        require(even == false, "Even score, no winner by majority");
        winningProposalId = winner;
        changeWorkflowStatus(WorkflowStatus.VotesTallied);
        emit VotesTallied();
    }

    function endVotingSession() external onlyOwner workflow(WorkflowStatus.VotingSessionStarted) {
        changeWorkflowStatus(WorkflowStatus.VotingSessionEnded);
        emit VotingSessionEnded();
    }

    function registerVote(uint proposalId) external onlyWhitelisted(msg.sender) workflow(WorkflowStatus.VotingSessionStarted) {
        require(whitelist[msg.sender].hasVoted == false, "Address has already voted");
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = proposalId;
        proposals[proposalId].voteCount++;
        emit Voted(msg.sender, proposalId);
    }

    function startVotingSession() external onlyOwner workflow(WorkflowStatus.ProposalsRegistrationEnded) {
        changeWorkflowStatus(WorkflowStatus.VotingSessionStarted);
        emit VotingSessionStarted();
    }

    function endProposalsRegistration() external onlyOwner workflow(WorkflowStatus.ProposalsRegistrationStarted) {
        changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
        emit ProposalsRegistrationEnded();
    }

    function registerProposal(string calldata description) external onlyWhitelisted(msg.sender) workflow(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal(description, 0));
        emit ProposalRegistered(proposals.length - 1);
    }

    function startProposalsRegistration() external onlyOwner workflow(WorkflowStatus.RegisteringVoters) {
        changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
        emit ProposalsRegistrationStarted();
    }

    function changeWorkflowStatus(WorkflowStatus newStatus) internal {
        emit WorkflowStatusChange(currentWorkflow, newStatus);
        currentWorkflow = newStatus;
    }

    function addToWhitelist(address _address) external onlyOwner {
        require (whitelist[_address].isRegistered == false, "Address already whitelisted");
        whitelist[_address].isRegistered = true;
        emit VoterRegistered(_address);
    }

    function removeFromWhitelist(address _address) external onlyOwner onlyWhitelisted(_address) {
        whitelist[_address].isRegistered = false;
        emit VoterUnregistered(_address);
    }
}
