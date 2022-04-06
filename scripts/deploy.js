async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
    const initialERC20tokenAmount = 100000000;

    Token = await ethers.getContractFactory("MyERC20Mintable");
    Nft = await ethers.getContractFactory("MyERC1155MintAndBurned");
    Staking = await ethers.getContractFactory("NFTERC1155Staking");

    token = await Token.deploy("My Token", "MT", initialERC20tokenAmount);
    nft = await Nft.deploy();
    staking = await Staking.deploy(nft.address, token.address);

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