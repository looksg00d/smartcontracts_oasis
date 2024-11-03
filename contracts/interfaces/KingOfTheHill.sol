// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@oasisprotocol/sapphire-contracts/contracts/OPL.sol";
import "./IERC20Template.sol";
import "./Nicknames.sol";

contract KingOfTheHill {
    struct Message {
        address sender;
        string content;
    }

    struct King {
        address addr;
        uint256 timeOnThrone;
    }

    Message[] private messages;
    King[] private kings;
    address private currentKing;
    uint256 private lastClaimTime;
    uint256 private currentPrize;
    uint256 private totalPrizePool;
    uint256 private commission;
    uint256 public lastDistributionTime;
    uint256 public distributionInterval = 7 days;
    IERC20Template public oceanToken;
    address public owner;
    Nicknames public nicknamesContract;

    event NewKing(address indexed king, uint256 amount, uint256 timestamp);
    event NewMessage(address indexed sender, string content);
    event CommissionWithdrawn(address indexed owner, uint256 amount);

    constructor(address _oceanTokenAddress, address _nicknamesAddress) {
        oceanToken = IERC20Template(_oceanTokenAddress);
        nicknamesContract = Nicknames(_nicknamesAddress);
        lastDistributionTime = block.timestamp;
        owner = 0x5666534b19B5c9d5C54881c43B3C01EE52a82f21;
    }

    function claimThrone(uint256 amount) public {
        require(amount > currentPrize, "Need more tokens to become king");

        require(
            oceanToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        if (currentKing != address(0)) {
            uint256 timeSpent = block.timestamp - lastClaimTime;
            updateKingTime(currentKing, timeSpent);
        }

        currentKing = msg.sender;
        currentPrize = amount;
        lastClaimTime = block.timestamp;
        totalPrizePool += amount;

        emit NewKing(msg.sender, amount, block.timestamp);

        if (block.timestamp >= lastDistributionTime + distributionInterval) {
            distributeRewards();
            lastDistributionTime = block.timestamp;
        }
    }

    function updateKingTime(address king, uint256 timeSpent) internal {
        bool found = false;
        for (uint i = 0; i < kings.length; i++) {
            if (kings[i].addr == king) {
                kings[i].timeOnThrone += timeSpent;
                found = true;
                break;
            }
        }
        if (!found) {
            kings.push(King(king, timeSpent));
        }
    }

    function sendMessage(string memory content) public {
        messages.push(Message(msg.sender, content));
        emit NewMessage(msg.sender, content);
    }

    function distributeRewards() public {
        require(kings.length > 0, "No kings to reward");

        sortKingsByTime();

        uint256 totalAmount = totalPrizePool;
        commission += totalAmount * 5 / 100;

        if (kings.length == 1) {
            oceanToken.transfer(kings[0].addr, totalAmount * 95 / 100);
        } else if (kings.length == 2) {
            oceanToken.transfer(kings[0].addr, totalAmount * 60 / 100);
            oceanToken.transfer(kings[1].addr, totalAmount * 35 / 100);
        } else {
            uint256 firstPrize = totalAmount * 50 / 100;
            uint256 secondPrize = totalAmount * 30 / 100;
            uint256 thirdPrize = totalAmount * 15 / 100;

            oceanToken.transfer(kings[0].addr, firstPrize);
            oceanToken.transfer(kings[1].addr, secondPrize);
            oceanToken.transfer(kings[2].addr, thirdPrize);
        }

        delete kings;
        totalPrizePool = 0;
    }

    function sortKingsByTime() internal {
        uint256 n = kings.length;
        for (uint i = 0; i < n; i++) {
            for (uint j = 0; j < n - i - 1; j++) {
                if (kings[j].timeOnThrone < kings[j + 1].timeOnThrone) {
                    King memory temp = kings[j];
                    kings[j] = kings[j + 1];
                    kings[j + 1] = temp;
                }
            }
        }
    }

    function getTopKings() public view returns (King[] memory) {
        uint256 count = kings.length < 10 ? kings.length : 10;
        King[] memory topKings = new King[](count);
        for (uint256 i = 0; i < count; i++) {
            topKings[i] = kings[i];
        }
        return topKings;
    }

    function getKingInfo() public view returns (
        string memory kingNickname,
        uint256 prize,
        uint256 timeOnThrone
    ) {
        string memory nickname = nicknamesContract.getNickname(currentKing);
        return (
            bytes(nickname).length > 0 ? nickname : toAsciiString(currentKing),
            currentPrize,
            block.timestamp - lastClaimTime
        );
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function withdrawCommission() public {
        require(msg.sender == owner, "Only owner can withdraw commission");
        require(commission > 0, "No commission to withdraw");

        uint256 amount = commission;
        commission = 0;
        oceanToken.transfer(owner, amount);

        emit CommissionWithdrawn(owner, amount);
    }

    function getAllMessages() public view returns (Message[] memory) {
        return messages;
    }
}