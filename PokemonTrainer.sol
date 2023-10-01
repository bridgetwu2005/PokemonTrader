// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "contracts/PokemonChanger.sol";

contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // function balanceOf(address owner) public view returns (uint256 balance);
    // function ownerOf(uint256 tokenId) public view returns (address owner);

    // function approve(address to, uint256 tokenId) public;
    // function getApproved(uint256 tokenId) public view returns (address operator);

    // function setApprovalForAll(address operator, bool _approved) public;
    // function isApprovedForAll(address owner, address operator) public view returns (bool);

    // function transferFrom(address from, address to, uint256 tokenId) public;
    // function safeTransferFrom(address from, address to, uint256 tokenId) public;

    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract PokemonTrainer is ERC721, PokemonChanger {
    string private _name;

    event message(string _msg);
    event messageNumber(string _msg, uint _num);

    constructor (string memory name) public {
        _name = name;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    // function pokemonTransfer(address _from, address _to, uint256 _tokenId) public onlyOwner{
    //     pokemonToOwner[_tokenId] = _to;
    //     emit Transfer(_from, _to, _tokenId);
    // }
 
    function checkOwner(uint _tokenId) public view onlyOwner returns(address) {
        return pokemonToOwner[_tokenId];
    }

    // function findPokemon(uint256 _tokenId) public view returns (Pokemon memory) {
    //     for(uint i = 0; i < pokemonList.length; i++) {
    //         if (pokemonList[i].id == _tokenId) {
    //             return pokemonList[i];
    //         }
    //     }
        
    // }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        pokemonToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(uint256 _tokenId, address _from, address _to) public {
        // Pokemon memory pokemon =  findPokemon(_tokenId);

        uint pokemonId = 0;
        for(uint i = 0; i < pokemonList.length; i++) {
            if (pokemonList[i].id == _tokenId) {
                pokemonId = pokemonList[i].id;
            }
        }

        require(_from != address(0));
        require(_to != address(0));
        require(pokemonId > 0);

        //transfer ownership of pokemon
        // _transfer(_from, _to, _tokenId);
        pokemonToOwner[_tokenId] = _to;

        //make a payment
        uint[] memory fromList = pokemonIdList[_from];
        
        bool pokemonFound = false;
        for(uint i = 0; i < fromList.length; i++) {

            if (fromList[i] == _tokenId) {
                pokemonIdList[_from][i] = 0;
                pokemonFound = true;
            }

            if (pokemonFound && i <= fromList.length - 1) {
                if (i != 0) {
                    pokemonIdList[_from][i] = pokemonIdList[_from][i + 1];
                    emit message("Shifted Pokemon List to Right");
                }
            }
        }

        if (pokemonFound) {
            pokemonIdList[_from].pop();
            uint length = pokemonIdList[_from].length;
        }

        // //add pokemon
        // pokemonIdList[_to].push(_tokenId);
    }

    function generatePokemon (string memory _str) public returns(Pokemon memory) {
        return _generatePokemon(_str);
    }
}
