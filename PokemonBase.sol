// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PokemonBase is Ownable{

    uint pokemonModulus = 10**4;

    //Pokemon constructor
    struct Pokemon{
        uint pokedex;
        string name;
        
        uint8 id;
        uint8 iv;
        uint8 lvl;
    }
    
    Pokemon[] public pokemonList;

    mapping (uint => address) pokemonToOwner;
    mapping (address => uint[]) pokemonIdList;
    
    //Create a new Pokemon
    function _generatePokemon (string memory _str) internal returns(Pokemon memory) {

        //Properties of the pokemon, including its name, id, pokedex, and value
        uint pokedex = _generatepokedex(_str);
        string memory name = _str;

        uint8 id = uint8(pokemonList.length) + 1;
        uint8 iv = uint8(_generateIV());
        uint8 lvl = 0;

        //Assigns the pokemon to an owner
        pokemonToOwner[pokedex] = msg.sender;

        //Adds pokemon to the pokemon list
        Pokemon memory newPokemon = Pokemon(pokedex, name, id, iv, lvl);
        pokemonList.push(newPokemon);
        
        //Adds pokemon idber to pokemon idber list
        pokemonIdList[msg.sender].push(newPokemon.id);

        return newPokemon;
    }
    
    //Randomly generate a 4 digit pokemon pokedex
    function _generatepokedex (string memory _str) private view returns (uint) {
        uint pokedex = uint(keccak256(abi.encodePacked(_str))) % pokemonModulus;
        return pokedex;
    }

    //Randomly generate a pokemon value from 0 to 100
    function _generateIV() private view returns(uint) {
        uint iv = uint(keccak256(abi.encodePacked(block.timestamp))) % 100 + 1;
        return iv;
    }

}