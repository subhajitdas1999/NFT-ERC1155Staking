# ERC1155 staking contract 

this contract helps to stake any ERC1155 NFT . it takes two contract address as constructor argument , one is ERC1155 NFT contract and another is ERC20 token contract (as the staking contract gives ERC20 as a staking reward). you have to approve this (setApproveForAll) this staking contract as a operator to transfer NFTS.

# the contracts is deployed at rinkeby network 

1. ERC1155Token contract 0xC733CBb278BDdc5b5847aC7Bd71e40ffa478A905 

2. ERC20TOken contract 0x51e6077De24ff214f59113a73AB66cd631AaeFbd

3. Staking address 0x26dd4432DD84C88eE80F43FC2361751C54bfa87e . contract verified [etherscan](https://rinkeby.etherscan.io/address/0x83AD0a3056ac20b137347ab74A1c96601510846F#code)

# To Deploy the contracts 

for rinkeby network 

1. configure hardhat.config.js

2. run :- npx hardhat run scripts/deploy.js --network rinkeby

# To run the tests for staking contract

1. run:- npx hardhat test (from root directory)
