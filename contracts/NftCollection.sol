//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftCollection is ERC721Enumerable
{
    string public baseURI;
    address public owner;
    uint24 public immutable MAX_SUPPLY = 5500;
    uint256 public immutable MINT_FEE = 10000000000000000 wei; 
    uint256 public maxMintAmount = 5;
    bool public isPaused;

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    constructor(string memory _baseURI) ERC721("Meow NFT", "MNT")
    {
        owner = msg.sender;
        baseURI = _baseURI;
        isPaused = false;

    }

    function mint(uint _count) external payable{
        
        uint supply = totalSupply();
        require(!isPaused);
        require(msg.value == MINT_FEE);
        require(_count > 0);
        require(_count <= maxMintAmount);
        require(supply + _count <= MAX_SUPPLY);

        for(uint i=1; i<=_count; i++)
        {

            _safeMint(msg.sender, supply + i);
        }
 
    } 

    function tokenURI(uint _tokenId) public view override returns (string memory)
    {
        require(_exists(_tokenId), "Token ID doesn't exits");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
    }

    function setBaseURI(string memory _baseURI) public onlyOwner
    {
        baseURI = _baseURI;
    }

    function pause(bool _state) public onlyOwner {
        isPaused = _state;
    }
}