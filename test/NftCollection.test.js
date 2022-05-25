const {
    expect
} = require("chai");
const {
    ethers
} = require("hardhat");


describe("Nft Collection", async () => {
    let meowToken;
    let nftCollection;
    let nftVault;
    let deployer;

    beforeEach(async () => {
        let [account] = await ethers.getSigners();
        deployer = account;
        const NftCollection = await ethers.getContractFactory("NftCollection", deployer);
        nftCollection = await NftCollection.deploy("ipfs://yyyyyyyyyyyy/");
        await nftCollection.deployed();
    })

    it("Should mint NFT", async () => {
        await nftCollection.connect(deployer).mint(3, {
            value: ethers.utils.parseEther("0.01")
        });
        const mintedAmount = await nftCollection.balanceOf(deployer.address);
        expect(mintedAmount.toString()).to.equal('3');
    });

    it("Should not allow to mint more than five token in single tx", async () => {
        let [signer] = await ethers.getSigners();
        await expect(nftCollection.connect(deployer).mint(7, {
            value: ethers.utils.parseEther("0.01")
        })).to.be.revertedWith("You can't mint more than 5 token in single tx");
    });

    it("Should not allow minting if minting is paused", async () => {
        await nftCollection.connect(deployer).pause(true);
        await expect(nftCollection.connect(deployer).mint(7, {
            value: ethers.utils.parseEther("0.01")
        })).to.be.revertedWith("Minting is paused");
    });

    it("Should return tokenURI for tokenId", async () => {
        await nftCollection.connect(deployer).mint(1, {
            value: ethers.utils.parseEther("0.01")
        });
        expect(await nftCollection.connect(deployer).tokenURI(1)).to.equal("ipfs://yyyyyyyyyyyy/1")
    })

})