// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVoting {

    IERC20 public voteToken;
    address public owner;
    bool public votingOpen = true;

    struct Candidate {
        string name;
        string description;
        uint256 totalVotes;
    }

    Candidate[] private candidates;

    mapping(address => bool) private voted;

    event CandidateAdded(
        uint256 indexed candidateId,
        string name,
        string description
    );

    event VoteCast(
        address indexed voter,
        uint256 indexed candidateId,
        uint256 weight
    );

    event VotingClosed(
        uint256 indexed winnerId,
        string winnerName,
        uint256 winnerVotes
    );

    modifier onlyOwner() {
        require(msg.sender == owner,"TokenVoting: only owner can call");
        _;
    }

    modifier votingStillOpen() {
        require(votingOpen, "TokenVoting: voting is closed");
        _;
    }

    constructor(address _tokenaddress) {
        require(_tokenaddress != address(0),"TokenVoting: invalid token address");
        voteToken = IERC20(_tokenaddress);
        owner = msg.sender;
    }

    function addCandidate(string memory name, string memory description) public onlyOwner votingStillOpen {
        require(bytes(name).length > 0, "TokenVoting: empty name");
        candidates.push( Candidate(name, description, 0));

       emit CandidateAdded(candidates.length - 1, name, description);
    }

    function vote(uint256 candidateId, uint256 amount ) public votingStillOpen {
        require(!voted[msg.sender], "TokenVoting: already voted" );

        require(candidateId < candidates.length, "TokenVoting: invalid candidate");

        require(amount > 0, "TokenVoting: amount must be > 0");

        bool success = voteToken.transferFrom( msg.sender, address(this), amount);

        require(success, "TokenVoting: token transfer failed");

        candidates[candidateId].totalVotes += amount;

        voted[msg.sender] = true;

        emit VoteCast(msg.sender, candidateId, amount);
    }

    function closeVoting()  public onlyOwner votingStillOpen {
        votingOpen = false;

        uint256 winnerId = _getWinnerId();

        emit VotingClosed(winnerId, candidates[winnerId].name, candidates[winnerId].totalVotes);
    }

    function _getWinnerId() internal view returns (uint256) {
        uint256 winnerId = 0;
        uint256 highestVotes = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].totalVotes > highestVotes ) {
                highestVotes = candidates[i].totalVotes;
                winnerId = i;
            }
        }
             return winnerId;
    }

    function getWinnerId() public view returns (uint256) {
        return _getWinnerId();
    }

    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function getCandidate( uint256 id ) public view returns (string memory name,  string memory description, uint256 totalVotes) {
        require(id < candidates.length, "TokenVoting: invalid candidate id");

        Candidate memory c = candidates[id];

        return (c.name, c.description, c.totalVotes);
    }

    function hasVoted( address user ) public view returns (bool) {
        return voted[user];
    }
}