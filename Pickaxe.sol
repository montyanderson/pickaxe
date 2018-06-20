pragma solidity ^0.4.16;

contract Pickaxe {
    string public constant name = "Pickaxe";
    string public constant symbol = "PIAX";
    uint8 public constant decimals = 18;  // 18 is the most common number of decimal places

    uint constant jackpot = 512000000000000000000;
    uint jackpotDifficulty = 1000000;

    uint constant jackpotPeriodDuration = 86400;
    uint jackpotPeriodStart = 0;
    uint minted = 0;

    uint constant maxTarget = ~uint(0);

    uint supply = 0;
    bytes32 challenge;

    mapping(address => uint) balances;

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

    constructor() public {
        jackpotPeriodStart = now;
        challenge = blockhash(block.number - 1);
    }

    event Mint(address indexed from, uint reward, bytes32 newChallenge);

    function mint(uint nonce, uint rewardDifficulty) public {
        require(
            uint(keccak256(
                abi.encodePacked(challenge, rewardDifficulty, msg.sender, nonce)
            )) < maxTarget / rewardDifficulty
        );

        uint reward = jackpot * rewardDifficulty / jackpotDifficulty;

        supply += reward;
        minted += reward;
        balances[msg.sender] += reward;

        if(minted >= jackpot) {
            uint jackpotPeriodLength = now - jackpotPeriodStart;

            jackpotDifficulty = jackpotDifficulty * jackpotPeriodLength / jackpotPeriodDuration * minted / jackpot;

            jackpotPeriodStart = now;
            challenge = blockhash(block.number - 1);
        }
    }

}
