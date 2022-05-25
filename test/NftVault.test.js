const {
    expect
} = require("chai");
const {
    ethers,
    waffle
} = require("hardhat");




describe("Nft Vault", async () => {
    let meowToken;
    let nftCollection;
    let nftVault;
    let deployer;
    let provider = waffle.provider;

    beforeEach(async () => {
        const [account] = await ethers.getSigners();
        deployer = account;

        const MeowToken = await ethers.getContractFactory("MeowToken", deployer);
        meowToken = await MeowToken.deploy();
        await meowToken.deployed();

        const NftCollection = await ethers.getContractFactory("NftCollection", deployer);
        nftCollection = await NftCollection.deploy("ipfs://yyyyyyyyyyyy/");
        await nftCollection.deployed();

        const NftVault = await ethers.getContractFactory("NftVault", deployer);
        nftVault = await NftVault.deploy(nftCollection.address, meowToken.address);
        await nftVault.deployed();

        const balance = await meowToken.balanceOf(deployer.address);
        await meowToken.connect(deployer).transfer(nftVault.address, balance);

    });


    it("Should stake NFT", async () => {
        await nftCollection.connect(deployer).mint(1, {
            value: ethers.utils.parseEther("0.01")
        });
        await nftCollection.connect(deployer).approve(nftVault.address, 1);
        await nftVault.connect(deployer).stake([1]);
        expect((await nftVault.totalStaked()).toString()).to.equal('1');
    });

    it("Should allow to unstake tokens", async () => {
        //stake
        await nftCollection.connect(deployer).mint(1, {
            value: ethers.utils.parseEther("0.01")
        });
        await nftCollection.connect(deployer).approve(nftVault.address, 1);
        await nftVault.connect(deployer).stake([1]);

        //unstake
        await nftVault.connect(deployer).unStake([1]);
        expect((await nftVault.totalStaked()).toString()).to.equal('0');
    });

    it("Should should give you reward", async () => {
        const accounts = await ethers.getSigners();
        const randomAccount = accounts[7];

        await nftCollection.connect(randomAccount).mint(1, {
            value: ethers.utils.parseEther("0.01")
        });
        await nftCollection.connect(randomAccount).approve(nftVault.address, 1);
        await nftVault.connect(randomAccount).stake([1]);
        let balance = (await meowToken.balanceOf(randomAccount.address)).toString();
        console.log(`Balance before staking: ${ethers.utils.formatEther(balance)}`);

        //increase block.timestamp
        const sevenDays = 100 * 24 * 60 * 60;
        await ethers.provider.send('evm_increaseTime', [sevenDays]);
        await ethers.provider.send('evm_mine');

        //getreward

        await nftVault.connect(randomAccount).getReward([1]);
        balance = (await meowToken.balanceOf(randomAccount.address)).toString();
        console.log(`Balance before staking: ${ethers.utils.formatEther(balance)}`);
    })

});