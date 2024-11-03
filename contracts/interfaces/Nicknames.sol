// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@oasisprotocol/sapphire-contracts/contracts/OPL.sol";

contract Nicknames {
    mapping(address => string) private addressToNickname;    // адрес -> никнейм
    mapping(string => address) private nicknameToAddress;    // никнейм -> адрес
    mapping(address => bool) private hasNickname;          // флаг наличия никнейма у адреса

    event NicknameSet(string nickname);
    event NicknameChanged(string oldNickname, string newNickname);

    error NicknameAlreadyTaken(string nickname);
    error NicknameTooShort();
    error NicknameTooLong();
    error InvalidCharacters();
    error UserAlreadyHasNickname();

    modifier validNickname(string memory nickname) {
        // Проверка длины (от 3 до 16 символов)
        bytes memory nickBytes = bytes(nickname);
        if(nickBytes.length < 3) revert NicknameTooShort();
        if(nickBytes.length > 16) revert NicknameTooLong();
        
        // Проверка допустимых символов (буквы, цифры, подчеркивание)
        for(uint i = 0; i < nickBytes.length; i++) {
            bytes1 char = nickBytes[i];
            bool isLetter = (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A);
            bool isNumber = char >= 0x30 && char <= 0x39;
            bool isUnderscore = char == 0x5F;
            
            if(!isLetter && !isNumber && !isUnderscore) {
                revert InvalidCharacters();
            }
        }
        _;
    }

    function setNickname(string memory nickname) public validNickname(nickname) {
        // Проверяем, не занят ли никнейм
        if(nicknameToAddress[nickname] != address(0)) {
            revert NicknameAlreadyTaken(nickname);
        }

        // Проверяем, есть ли уже никнейм у пользователя
        if(hasNickname[msg.sender]) {
            // Если есть - удаляем старый никнейм
            string memory oldNickname = addressToNickname[msg.sender];
            delete nicknameToAddress[oldNickname];
            emit NicknameChanged(oldNickname, nickname);
        } else {
            hasNickname[msg.sender] = true;
            emit NicknameSet(nickname);
        }

        // Сохраняем новый никнейм
        addressToNickname[msg.sender] = nickname;
        nicknameToAddress[nickname] = msg.sender;
    }

    function getNickname(address user) public view returns (string memory) {
        return addressToNickname[user];
    }

    function getAddressByNickname(string memory nickname) public view returns (address) {
        return nicknameToAddress[nickname];
    }

    function hasUserNickname(address user) public view returns (bool) {
        return hasNickname[user];
    }

    function isNicknameTaken(string memory nickname) public view returns (bool) {
        return nicknameToAddress[nickname] != address(0);
    }
}