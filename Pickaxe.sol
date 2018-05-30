pragma solidity ^0.4.16;

contract Pickaxe {
    uint constant challengeInterval = 60;
    uint constant difficultyAdjust = 10;
    uint constant rewardAdjust = 262800;

    uint difficulty = 300000;
    uint reward = 512;
    uint supply = 0;

    bytes32 challenge;
    uint[] times;

    mapping(address => uint) balances;

    // info

    function totalSupply() public constant returns (uint) {
        return supply;
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    event Transfer(address indexed from, address indexed to, uint tokens);

    function transfer(address to, uint tokens) public returns (bool success) {
        if(balances[msg.sender] < tokens)
            return false;

        balances[msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function getDifficulty() public constant returns (uint) {
        return difficulty;
    }

    function getTarget() public constant returns (bytes32) {
        return bytes32(~uint(0) / difficulty);
    }

    function getReward() public constant returns (uint) {
        return reward;
    }

    function getChallenge() public constant returns (bytes32) {
        return challenge;
    }

    // actions

    constructor() public {
        challenge = blockhash(block.number - 1);
        times[times.length++] = block.timestamp;
    }

    event Mint(address indexed from, uint reward, bytes32 newChallenge);

    function mint(uint nonce) public {
        bytes32 output = keccak256(abi.encodePacked(challenge, nonce));

        require(uint(output) < ~uint(0) / difficulty);

        challenge = output;
        times[times.length++] = block.timestamp;

        balances[msg.sender] += reward;
        supply += reward;

        emit Mint(msg.sender, reward, challenge);

        if(times.length % difficultyAdjust == 0) {
            // adjust difficulty

            uint currentDelta = times[times.length - 1] - times[times.length - difficultyAdjust];
            uint targetDelta = challengeInterval * difficultyAdjust;

            difficulty = (difficulty / currentDelta) * targetDelta;
        }

        if(times.length % rewardAdjust == 0) {
            reward /= 2;
        }
    }

}
