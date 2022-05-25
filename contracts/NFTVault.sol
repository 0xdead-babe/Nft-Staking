//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "hardhat/console.sol";
import "./NftCollection.sol";
import "./MeowToken.sol";

contract NftVault is IERC721Receiver
{
    NftCollection nftCollection;
    MeowToken meowToken;
    uint256 public totalStaked;


    //stake struct
    struct Stake
    {
        uint tokenId;
        uint timeStamp;
        address owner;
    }

    //map tokenId to stakeStruct
    mapping (uint=>Stake) vault;

    constructor(address _nft, address _token)
    {
        nftCollection = NftCollection(_nft);
        meowToken = MeowToken(_token);
    }


    function stake(uint[] calldata tokenIds) public 
    {
        uint length = tokenIds.length;
        uint tokenId;

        for(uint i=0;i<length;i++)
        {
            tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "You can't stake someone else's token");
            require(vault[tokenId].tokenId == 0, "Token has already beed staked");

            nftCollection.safeTransferFrom(msg.sender, address(this), tokenId, " ");

            vault[tokenId] = Stake({
                tokenId: tokenId,
                timeStamp: uint(block.timestamp),
                owner: msg.sender
            });
        }

        totalStaked += tokenIds.length;

    }


    function unStake(uint[] calldata tokenIds) public 
    {
        uint tokenId;

        for(uint i=0; i<tokenIds.length;i++)
        {
            tokenId = tokenIds[i];
            Stake memory stake = vault[tokenId];
            
            require(stake.tokenId !=0, "Nft was never staked");
            require(stake.owner == msg.sender, "You are not owner of NFT");

            nftCollection.safeTransferFrom(address(this), msg.sender, tokenId, " ");
            delete vault[tokenId];
        }

        totalStaked -= tokenIds.length;
    }

    function getReward(uint[] calldata tokenIds) public
    {
        uint tokenId;
        uint earned;
        address  recipient;

        for(uint i=0;i<tokenIds.length;i++)
        {
            tokenId = tokenIds[i];
            Stake memory stake = vault[tokenId];

            require(stake.tokenId !=0, "You can't claim reward for NFT that was never staked ");
            require(stake.owner == msg.sender, "You can't claim reward for NFT that you don't own");

            uint256 stakedTime = stake.timeStamp;
            earned += 10000  * (block.timestamp - stakedTime) / 1 days;
        }
        meowToken.transfer(msg.sender, earned);
    }



    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4) 
    {
            return this.onERC721Received.selector;
    }

}