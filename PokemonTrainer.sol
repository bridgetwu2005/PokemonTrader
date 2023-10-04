// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "contracts/PokemonChanger.sol";

abstract contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) public virtual view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public virtual view returns (address owner);

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

    constructor (string memory name) {
        _name = name;
    }

    function tokenName() external view returns (string memory) {
        return _name;
    }

    function checkOwner(uint _tokenId) public view onlyOwner returns(address) {
        return pokemonToOwner[_tokenId];
    }

    function findPokemon(uint256 _tokenId) public view returns (uint, string memory, uint8,  uint8, uint256, string memory) {
        if(_tokenId> 0 && _tokenId-1<=pokemonList.length) {
          Pokemon memory pokemon =  pokemonList[_tokenId-1];  
          return (pokemon.pokedex, pokemon.name, pokemon.id, pokemon.lvl, pokemon.price, pokemon.image);
        } else {
             return (0, "", 0, 0, 0, "");  
        }
    }
    function findAllPokemon() public view  returns (uint[] memory, string[] memory, uint8[] memory,  uint8[] memory, uint256[] memory, string[] memory) {
        uint256 size = pokemonList.length;
        uint[] memory pokedexs = new uint[](size);
        string[] memory names = new string[](size); 
        uint8[] memory ids= new uint8[](size); 
        uint8[] memory lvls = new uint8[](size);
        uint256[] memory prices = new uint256[](size); 
        string[] memory images = new string[](size); 
        for (uint i = 0; i < size; ++i) {
            Pokemon memory pokemon =  pokemonList[i];  
            pokedexs[i] = pokemon.pokedex;
            names[i] = pokemon.name;
            ids[i] = pokemon.id;
            lvls[i] = pokemon.lvl;
            prices[i] = pokemon.price; 
            images[i] = pokemon.image; 
         }
        return (pokedexs,names, ids, lvls, prices, images);
    }
    function findMyPokemons() public view returns (uint[] memory, string[] memory, uint8[] memory,  uint8[] memory, uint256[] memory, string[] memory) {
        return viewPokemon(msg.sender);
    }

    function buyyPokemon(uint256 _tokenId) payable public {
        address payable _current_owner = pokemonToOwner[_tokenId];
        require(_current_owner != address(0));
        require(msg.sender != address(0));
        require(msg.sender != _current_owner);
        //only need id, skip others
        (, , uint8 _id,, uint256 _price,) =  findPokemon(_tokenId);
        require(_id > 0);
        require(msg.value >= _price);
        //transfer ownership of pokemon
        _transfer(_current_owner, msg.sender, _tokenId);
        //make address as payable
        address payable buyer = payable(msg.sender);
        //make a payment
        //return extra payment
        if(msg.value > _price) buyer.transfer(msg.value - _price);
        //sender make a payment to pokemon owner
        _current_owner.transfer(_price);

        //now remove current owner pokemon from Pokemon list
        uint[] memory fromList = pokemonIdList[_current_owner];
        bool pokemonFound = false;
        uint size = fromList.length;
        for(uint i = 0; i < fromList.length; i++) {
            if (fromList[i] == _tokenId) {
                pokemonFound = true;
            }
            if (pokemonFound && i <= fromList.length - 1) {
                if (i < size-1) {
                    pokemonIdList[_current_owner][i] = pokemonIdList[_current_owner][i + 1];

                }
            }
        }
        if (pokemonFound) {
            emit message("Pop");
            pokemonIdList[_current_owner].pop();
            uint length = pokemonIdList[_current_owner].length;
            emit messageNumber("Shifted Pokemon List to Right", length);
        }
        //add pokemon to buyer Pokemon list
        pokemonIdList[msg.sender].push(_tokenId);
    }

    function generatePokemon (string memory _pname,  uint256 _price, string memory _image) public returns(Pokemon memory) {
        return _generatePokemon(_pname, _price, _image);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        pokemonToOwner[_tokenId] = payable(_to);
        emit Transfer(_from, _to, _tokenId);
    }
    function balanceOf(address _owner) public override view returns (uint256) {
        uint[] memory pokemonIds = pokemonIdList[_owner];
        return pokemonIds.length;
    }

    function ownerOf(uint256 _tokenId) public override view returns (address _owner) {
        _owner = pokemonToOwner[_tokenId];
    }
}
