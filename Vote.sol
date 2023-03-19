// SPDX-License-identifier: GPL-3.0
pragma solidity 0.8.18;

error AlreadyVoted();
error CandidateNotFound(uint256 candidate);
error AlreadyClosed();
error VoteStillOpen();
error NobodyVoted();

contract Vote{

    struct Candidate{
        string name;
        uint votes;
    }

    struct Voter {
        bool voted;
        uint256 candidate;
    }

    event NewVote(uint256 indexed candideteIndex, string candidatesName);

    mapping(address => Voter) private s_voters;

    uint private immutable i_timestampEnd;

    Candidate[] private s_candidates;
    string public s_name;
    uint256 private s_votesTotal;
    
    constructor(string memory name, string[] memory candidatesName, uint duration){
        s_name = name;
        i_timestampEnd = block.timestamp + duration;

        for(uint256 i=0; i < candidatesName.length; i++) {
            Candidate memory candidate = Candidate({
                name: candidatesName[i],
                votes: 0
            });
            s_candidates.push(candidate);
        }
    }

    modifier validVote{
        if(block.timestamp <i_timestampEnd) revert VoteStillOpen();
        if(s_votesTotal == 0) revert NobodyVoted();
        _;
    }

    function vote(uint256 candidate) external {
        if(block.timestamp > i_timestampEnd) revert AlreadyClosed();
        if(candidate <0 || candidate >= s_candidates.length) revert CandidateNotFound(candidate);
        if(s_voters[msg.sender].voted) revert AlreadyVoted();

        s_voters[msg.sender].voted = true;
        s_voters[msg.sender].candidate = candidate;
        s_candidates[candidate].votes+= 1;
        s_votesTotal +=1;

        emit NewVote(candidate, s_candidates[candidate].name);
    }

    function getWinner() public view validVote returns(string memory){
        Candidate[] memory candidates = s_candidates;
        uint256 winner = 0;

        for (uint256 i = 0; i < s_candidates.length; i++){
            if(candidates[i].votes > candidates[winner].votes){
                winner = i;
            }
        }

        return candidates[winner].name;

    }

    function getResulDetailed() public view validVote returns (Candidate[] memory){
        return s_candidates;
    }

    function getcandiates() public view returns(string[] memory){
        Candidate[] memory candidates = s_candidates;
        string[] memory candidatesName = new string[](candidates.length);

        for(uint256 i = 0; i < candidates.length; i++){
            candidatesName[i] = candidates[i].name;
        }

        return candidatesName;
    }
}