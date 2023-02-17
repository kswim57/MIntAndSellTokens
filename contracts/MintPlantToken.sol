// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "SalePlantToken.sol";

contract MintPlantToken is ERC721Enumerable {
    constructor() ERC721("h662Plants", "HPS") {}

    SalePlantToken public salePlantToken;

    mapping(uint256 => uint256) public plantTypes;

    struct PlantTokenData{
        uint256 plantTokenId;
        uint256 plantType;
        uint256 plantPrice;
    }

    function mintPlantToken() public {
        uint256 plantTokenId = totalSupply() + 1;

        uint256 plantType = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,plantTokenId)))%5+1;

        plantTypes[plantTokenId] = plantType;

        _mint(msg.sender, plantTokenId);
    }

    function getPlantTokens(address _plantTokenOwner) view public returns(PlantTokenData[] memory){
        uint256 balanceLength = balanceOf(_plantTokenOwner);

        require(balanceLength != 0,"Owner did not have token.");

        PlantTokenData[] memory plantTokenData = new PlantTokenData[](balanceLength);

        for(uint256 i = 0; i < balanceLength; i++){
            uint256 plantTokenId = tokenOfOwnerByIndex(_plantTokenOwner, i);
            uint256 plantType = plantTypes[plantTokenId]; 
            uint256 plantPrice = salePlantToken.getPlantTokenPrice(plantTokenId);
 
            plantTokenData[i] = PlantTokenData(plantTokenId, plantType, plantPrice);
        }

        return plantTokenData;
    }

    function setSalePlantToken(address _salePlantToken) public{
        salePlantToken = SalePlantToken(_salePlantToken);
    }
}