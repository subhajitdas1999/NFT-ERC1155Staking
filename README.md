# ERC1155 staking contract 

Description :- This contract helps to stake any ERC1155 NFT . it takes two contract address as constructor argument, one is ERC1155NFT contract and another is ERC20 token contract (as the staking contract gives ERC20 as a staking reward).Minimum amount of NFT you can stake is 100 in this contract. User can stake their ERC1155 token , as a staking reward user will get ERC20 tokens (ROI:- 1month=5%APR,6month = 10% APR , 1Year = 15% APR) .

The staking contract is deployed with some ERC20 tokens. 



NOTE :- 
    1. It'll work on any type of ERC20 token, as long as the decimal value is 18.
    2. Before staking any token first Approve this contract as a operator, otherwise your transaction will be reverted.

# the contracts is deployed at rinkeby network 

1. ERC1155Token contract 0xC34525E0D7188fdA211D27b349B7364933C3AC89 .

contract verified [etherscan](https://rinkeby.etherscan.io/address/0xC34525E0D7188fdA211D27b349B7364933C3AC89#code) 

2. ERC20TOken contract 0xce07a94F963B3f7309BC008f5D729c0d8a349055 .

contract verified [etherscan](https://rinkeby.etherscan.io/address/0xce07a94F963B3f7309BC008f5D729c0d8a349055#code)

3. Staking address 0xa86450AEa8e4cF2Ff9942757eA2382CdD3272948 . 

contract verified [etherscan](https://rinkeby.etherscan.io/address/0xa86450AEa8e4cF2Ff9942757eA2382CdD3272948#code)

# To Deploy the contracts 

for rinkeby network 

1. configure hardhat.config.js

2. run :- npx hardhat run scripts/deploy.js --network rinkeby

# To run the tests for staking contract

All the tests for this staking contract written in test/NFTERC1155Staking.js file.

to run the tests,

1. run:- npx hardhat test (from root directory)

NOTE:- Do not forget to change the time period from days to seconds in "_calculateROI" function in NFTERC1155Staking.sol file , otherwise last test will fail
