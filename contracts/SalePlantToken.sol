// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintPlantToken.sol";

contract SalePlantToken{
    MintPlantToken public mintPlantTokenAddress;
 
    constructor(address _mintPlantTokenAddress){
        mintPlantTokenAddress = MintPlantToken(_mintPlantTokenAddress);
    }

    mapping(uint256 => uint256) public plantTokenPrices;

    uint256[] public onSalePlantTokenArray;

    function setForSalePlantToken(uint256 _plantTokenId, uint256 _price) public {
        address plantTokenOnwer = mintPlantTokenAddress.ownerOf(_plantTokenId);
        
        require(plantTokenOnwer == msg.sender, "Caller is not plant token owner.");
        require(_price > 0, "Price is zero or lower.");
        require(plantTokenPrices[_plantTokenId] == 0, "This plant token is already on sale.");
        require(mintPlantTokenAddress.isApprovedForAll(plantTokenOnwer,address(this)),"Plant token owner did not approve token.");

        plantTokenPrices[_plantTokenId] = _price;

        onSalePlantTokenArray.push(_plantTokenId);
    }

    function purchasePlantToken(uint256 _plantTokenId) public payable{
        uint256 price = plantTokenPrices[_plantTokenId];
        address plantTokenOnwer = mintPlantTokenAddress.ownerOf(_plantTokenId);

        require(price > 0, "Plant token not sale.");
        require(price <= msg.value, "Caller sent lower than price.");
        require(plantTokenOnwer != msg.sender, "caller is plant token owner.");

        payable(plantTokenOnwer).transfer(msg.value);
        mintPlantTokenAddress.safeTransferFrom(plantTokenOnwer,msg.sender,_plantTokenId);

        plantTokenPrices[_plantTokenId] = 0;

        for(uint256 i = 0; i < onSalePlantTokenArray.length; i++){
            if(plantTokenPrices[onSalePlantTokenArray[i]] == 0){
                onSalePlantTokenArray[i] = onSalePlantTokenArray[onSalePlantTokenArray.length - 1];
                onSalePlantTokenArray.pop();
            }
        }
    }

    function getOnSalePlantTokenArrayLength() view public returns(uint256){
        return onSalePlantTokenArray.length;
    }
    
    function getPlantTokenPrice(uint256 _plantTokenId) view public returns (uint256){
        return plantTokenPrices[_plantTokenId];
    }
}