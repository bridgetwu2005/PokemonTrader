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
        require (_pokemonID-1 >= 0 && pokemonList[_pokemonID-1].id >= 0);
        pokemonList[_pokemonID-1].lvl++;
    }

    //Cancels level up transaction
    function withdrawLevelUp(uint _pokemonID) external onlyOwner{
        require (pokemonList[_pokemonID].lvl >= 0);
        pokemonList[_pokemonID].lvl--;
        address payable _owner = payable(address(uint160(owner())));
       _owner.transfer(address(this).balance);
     }
    
    //Gets all the pokemon for an owner
    function viewPokemon(address _owner) public view returns (uint[] memory, string[] memory, uint8[] memory,  uint8[] memory,uint256[] memory, string[] memory) {
        uint[] memory myPokemon = pokemonIdList[_owner];
        uint size = myPokemon.length;
        if(size == 0) {
            return (new uint[](0), new string[](0), new uint8[](0), new uint8[](0), new uint256[](0), new string[](0));  
        } else {
            uint[] memory pokedexs = new uint[](size);
            string[] memory names = new string[](size); 
            uint8[] memory ids= new uint8[](size); 
            uint8[] memory lvls = new uint8[](size);
            uint256[] memory prices = new uint256[](size); 
            string[] memory images = new string[](size); 
            uint count = 0;
            for (uint i = 0; i <size; i++) {     
                 uint id = myPokemon[i];
                if (pokemonList[id-1].id > 0) {
                    Pokemon memory pokemon = pokemonList[id-1];
                    pokedexs[count] = pokemon.pokedex;
                    names[count] = pokemon.name;
                    ids[count] = pokemon.id;
                    lvls[count] = pokemon.lvl; 
                    prices[count] = pokemon.price; 
                    images[count] = pokemon.image; 
                    count++;
              }
            }
            return (pokedexs,names, ids, lvls, prices, images);  
        }
    }
}