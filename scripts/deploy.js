const { BigNumber } = require("ethers");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
  const initialERC20tokenAmount = BigNumber.from("1000000000000000000000000"); //initial token amount 1 million

  Token = await ethers.getContractFactory("MyERC20Token");
  Nft = await ethers.getContractFactory("MyERC1155NFTToken");
  Staking = await ethers.getContractFactory("NFTERC1155Staking");

  token = await Token.deploy("MyToken", "MT", initialERC20tokenAmount);
  nft = await Nft.deploy();
  staking = await Staking.deploy(nft.address, token.address);

  //send all the initial supplied ERC20 token to the staking contract
  //so it can send the tokens to the user as a staking reward
  await token.transfer(staking.address, initialERC20tokenAmount);

  console.log("ERC1155Token address:", nft.address);
  console.log("ERC20Token address:", token.address);
  console.log("Staking address:", staking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
