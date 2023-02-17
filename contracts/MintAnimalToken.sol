// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "SaleAnimalToken.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("h662Animals", "HAS") {}

    address public animalContractAddress = address(this);

    SaleAnimalToken public saleAnimalToken;

    mapping(uint256 => uint256) public animalTypes;
    mapping(uint256 => address) public animalContracts;

    struct AnimalTokenData{
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
        address contractAddress;
    }

    function mintAnimalToken() public {
        uint256 animalTokenId = totalSupply() + 1;

        uint256 animalType = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,animalTokenId)))%5+1;

        animalTypes[animalTokenId] = animalType;

        address contractAddress = animalContractAddress;

        animalContracts[animalTokenId] = contractAddress;

        _mint(msg.sender, animalTokenId);

    }


    function getAnimalTokens(address _animalTokenOwner) view public returns (AnimalTokenData[] memory) {
        // Get the number of tokens owned by the specified address.
        uint256 balanceLength = balanceOf(_animalTokenOwner);

        // Require that the address owns at least one token.
        require(balanceLength != 0,"Owner did not have token.");

        // Initialize a new array of AnimalTokenData structs with a length equal to the number of tokens owned by the address.
        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        // Loop through each token owned by the address and retrieve the animal type and price.
        for(uint256 i = 0; i < balanceLength; i++) {
            uint256 animalTokenId = tokenOfOwnerByIndex(_animalTokenOwner, i);
            uint256 animalType = animalTypes[animalTokenId]; 
            uint256 animalPrice = saleAnimalToken.getAnimalTokenPrice(animalTokenId);
            address contractAddress = animalContracts[animalTokenId]; // Get contract address from stored token data
    
            // Create a new AnimalTokenData struct and add it to the array.
            //Include the animal token ID, animal type, animal price, and the contract address of the current smart contract.
            animalTokenData[i] = AnimalTokenData(animalTokenId, animalType, animalPrice, contractAddress);
        }

        // Return the array of AnimalTokenData structs.
        return animalTokenData;
    }

    function setSaleAnimalToken(address _saleAnimalToken) public{
        saleAnimalToken = SaleAnimalToken(_saleAnimalToken);
    }
}
