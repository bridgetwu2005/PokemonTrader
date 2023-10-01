// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "contracts/PokemonBase.sol";

contract PokemonChanger is PokemonBase{

    uint levelUpFee = 0.001 ether;
    
    //Sets up the amount of ether needed to level up a pokemon
    function setLevelUpPrice(uint _price) external onlyOwner {
        levelUpFee = _price;
    }

    //Checks if the pokemon is above a certain level
    modifier levelCheck(uint _lvl, uint _pokemonID) {
        require(pokemonList[_pokemonID].lvl >= _lvl);
        _;
    }
    
    //Levels up the pokemon if the pokemon is paid enough
    function levelUp(uint _pokemonID) external payable onlyOwner{
        require (msg.value - levelUpFee >= 0);
        pokemonList[_pokemonID].lvl++;
    }

    //Cancels level up transaction
    function withdrawLevelUp() external onlyOwner{
        address payable _owner = payable(address(uint160(owner())));
       _owner.transfer(address(this).balance);
     }
    
    //Gets all the pokemon for an owner
    function viewPokemon(address _owner) public view returns(Pokemon[] memory) {
        uint[] memory myPokemon = pokemonIdList[_owner];

        if(myPokemon.length <= 0) {
            Pokemon[] memory empty = new Pokemon[](0);
            return empty;
        }
        
        uint count = 0;
        Pokemon[] memory result = new Pokemon[](myPokemon.length);

        for (uint i = 0; i < myPokemon.length; i++) {         
            uint index = myPokemon[i];
            
            if (pokemonList[index].id > 0) {
                Pokemon memory item = pokemonList[index];
                result[count] = item;
                count++;
            }
        }

        return result;
    }

    function viewpokemonIdList(address _owner) public view returns(uint[] memory) {
        return pokemonIdList[_owner];
    }
    
}