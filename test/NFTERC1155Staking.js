const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
describe("NFTERC1155Staking Contract", () => {
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let Token;
  let Nft;
  let Staking;
  let token;
  let nft;
  let staking;

  const initialERC20tokenAmount = BigNumber.from("1000000000000000000000000");
  const NFTTokenId = 1;
  const NFTTokenAmount = 1000

  //mint token with id 1 and amount 10 , from owner account . And approve it to the staking contract
  const mintAndApproveNFTWithTokenId1fromOwner = async () => {
    //mint some NFT from owner account .with token Id 1 , token amount 1000
    await nft.mint(NFTTokenId, NFTTokenAmount);

    //approving the staking contract from owner
    await nft.setApprovalForAll(staking.address, true);
  };

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    Token = await ethers.getContractFactory("MyERC20Token");
    Nft = await ethers.getContractFactory("MyERC1155NFTToken");
    Staking = await ethers.getContractFactory("NFTERC1155Staking");

    token = await Token.deploy("MyToken", "MT", initialERC20tokenAmount);
    nft = await Nft.deploy();
    staking = await Staking.deploy(nft.address, token.address);
    //mint some tokens
    await mintAndApproveNFTWithTokenId1fromOwner();
  });

  it("staking Contract is able to receive ERC1155 tokens", async () => {
    //send 5 tokens of tokenId 1, from owner to the staking contract
    await nft.safeTransferFrom(owner.address,staking.address, NFTTokenId, 5,"0x00");

    const balanceOfStakingContract = await nft.balanceOf(staking.address, 1);

    //balance of staking contract with token id should be 5
    expect(balanceOfStakingContract).to.equal(5);
  });

  it("user can not stake less than 100 tokens", async () => {
    //try to stack 10 tokens of Id1
    await expect(staking.stakeTokens(NFTTokenId, 10)).to.be.revertedWith(
      "Token Amount should be greater than 100"
    );
  });

  it("user should able to stake tokens", async () => {
    //staking contract balance before any staking
    const stakingBalanceBefore = await nft.balanceOf(staking.address, NFTTokenId);
    //stake tokens
    await expect(staking.stakeTokens(NFTTokenId, NFTTokenAmount)).to.emit(staking, "staked");

    ////staking contract balance after any staking
    const stakingBalanceAfter = await nft.balanceOf(staking.address, NFTTokenId);

    const diff = BigNumber.from(stakingBalanceAfter).sub(
      BigNumber.from(stakingBalanceBefore)
    );

    //difference should be NFTTokenAmount=1000
    expect(diff).to.equal(NFTTokenAmount);
  });

  it("User cannot withdraw more tokens than deposited", async () => {
    //stake some tokens and get the stake id
    const depositAmount = NFTTokenAmount;
    const tx = await staking.stakeTokens(NFTTokenId, depositAmount);
    const receipt = await tx.wait();
    const event = receipt.events.find((event) => event.event === "staked");
    const [from, tokenId, tokenAmount, stakeIndex] = event.args;

    //try to withdraw more tokens
    await expect(
      staking.withdrawTokens(stakeIndex, depositAmount + 100)
    ).to.be.revertedWith("you have less stake balance");
  });

  it("User can withdraw all tokens or remaining staking balance should be greater than 100", async () => {
    //stake some tokens
    await staking.stakeTokens(NFTTokenId, NFTTokenAmount);

    //NFTTokenAmount =1000 now try to withdraw 950 tokens . stakeIndex is 0 (as it is the first staking in the from this owner)
    await expect(staking.withdrawTokens(0, 950)).to.be.revertedWith(
      "withdraw all or remaining staking balance should be greater than 100"
    );
  });

  it("user should receive stake tokens on withdrawal", async () => {
    const stakingAmount = NFTTokenAmount;
    //stake some tokens. tokenId 1
    await staking.stakeTokens(NFTTokenId, stakingAmount);

    //owner token balance after staking
    const tokensAfterStaking = await nft.balanceOf(owner.address, NFTTokenId);

    //withdraw all the tokens . stakeIndex is 0 as this was the first staking from owner account
    await staking.withdrawTokens(0, stakingAmount);

    //owner token balance after withdrawal
    const tokensAfterWithdrawal = await nft.balanceOf(owner.address, NFTTokenId);

    //difference of tokens
    const diff = BigNumber.from(tokensAfterWithdrawal).sub(
      BigNumber.from(tokensAfterStaking)
    );

    expect(diff).to.equal(stakingAmount);
  });

  it("User should received ERC20 tokens as a staking reward",async()=>{

    //send all the initial supplied ERC20 token to the staking contract
    //so it can send the tokens to the user as a staking reward
    await token.transfer(staking.address,initialERC20tokenAmount);

    //this staking contract ERC20 token balance before giving anyone staking rewards
    const contractERC20tokenBalanceBefore = await token.balanceOf(staking.address)

    //*****NOTE :- for testing changed the time reference in _calculateROI function from weeks to seconds  ***//
    //Remember to made change in contract for testing

    //now stake some NFT tokens
    await staking.stakeTokens(NFTTokenId,NFTTokenAmount);

    //function to add delay 
    const delay = (t) => {
      return new Promise(resolve => {
        setTimeout(resolve, t);
      });
    }
    
    //add delay of 5 seconds
    console.log("added delay of 5 seconds");
    await delay(5000);
    
    //Now after 5 seconds user should get his reward as mentioned in contract (4 weeks ~ 4 seconds here)
    
    //withdraw all staking tokens as this is the first staking from owner so staking Index will be 0
    await staking.withdrawTokens(0,NFTTokenAmount);

    //this staking contract ERC20 token balance after giving owner staking rewards
    const contractERC20tokenBalanceAfter = await token.balanceOf(staking.address)
   

    //difference in staking contract ERC20 token balance
    const diff =  BigNumber.from(contractERC20tokenBalanceBefore).sub(
      BigNumber.from(contractERC20tokenBalanceAfter)
    );

    //owner ERC20 token balance after receiving reward
    const userERC20tokenBalance = await token.balanceOf(owner.address);

    //difference in staking contract balance should be same as owner received ERC20 tokens
    expect(diff).to.equal(userERC20tokenBalance);
    

  })
});
