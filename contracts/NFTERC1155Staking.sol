//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NFTERC1155Staking {
    //NFT contract
    IERC1155 public NFTContract;

    //ERC20 token contract
    IERC20 public ERC20tokenContract;

    //ERC20 token Decimals
    uint public ERC20Tokendecimals = 18;

    constructor(IERC1155 _NFTContract,IERC20 _ERC20tokenContract){
        NFTContract = _NFTContract;
        ERC20tokenContract  = _ERC20tokenContract;
        
    }

    //staking details
    struct Stake{
        address stakeOwner;
        uint tokenId;
        uint tokenAmount;
        uint timeOfStaking;
    }

    // mapping staking id => Stake
    mapping( address => Stake[]) public stakings;

    //event for staking
    event staked(address indexed staker, uint tokenId, uint tokenAmount,uint stakeIndex);
    //event for stake withdraw
    event withdrawStake(uint tokenId,uint withDrawTokenAmount,uint remainingTokenAmount,uint recievedROI);

    function stakeTokens(uint _tokenId,uint _tokenAmount) public{
        require(NFTContract.balanceOf(msg.sender,_tokenId)>= _tokenAmount,"Account have less token");
        require(NFTContract.isApprovedForAll(msg.sender,address(this)),"Approve this contract as an operator");
        require(_tokenAmount >= 100,"Token Amount should be greater than 100");
        Stake memory stake = Stake(
            msg.sender,
            _tokenId,
            _tokenAmount,
            block.timestamp
        );

        stakings[msg.sender].push(stake);
        NFTContract.safeTransferFrom(stake.stakeOwner,address(this),stake.tokenId,stake.tokenAmount,"");

        //emit the staked events .latest stake Index should be length of stakes array -1 .
        emit staked(msg.sender,_tokenId,_tokenAmount,stakings[msg.sender].length - 1);
    }

    // withdraw the staked tokens with ERC20 in return
    function withdrawTokens(uint _stakeIndex,uint _withdrawTokenAmount) public {
        //check the stake index
        require(_stakeIndex < stakings[msg.sender].length,"Invalid Index");
        Stake storage stake = stakings[msg.sender][_stakeIndex];
        require(stake.tokenAmount >= _withdrawTokenAmount,"you have less stake balance");
        uint updatedTokenBalence = stake.tokenAmount - _withdrawTokenAmount;        
        require(updatedTokenBalence >= 100 || updatedTokenBalence==0,"withdraw all or remaining staking balance should be greater than 100");
        uint ERC20tokenAmount = _calculateROI(_stakeIndex,_withdrawTokenAmount);

        //update the new staking balance
        stake.tokenAmount = updatedTokenBalence;
        //return the staked tokens
        NFTContract.safeTransferFrom(address(this),stake.stakeOwner,stake.tokenId,_withdrawTokenAmount,"");
        //return the APR w.r.t ERC20
        ERC20tokenContract.transfer(stake.stakeOwner,ERC20tokenAmount);

        //emit the withdraw event
        emit withdrawStake(stake.tokenId,_withdrawTokenAmount,stake.tokenAmount,ERC20tokenAmount);
    }

    function _calculateROI(uint _stakeIndex,uint _tokenAmount) public view returns(uint){
        Stake memory stake = stakings[msg.sender][_stakeIndex];
        uint stakingPeriod = block.timestamp-stake.timeOfStaking;
        uint returnPersentage;
        //for testing
        // if (stakingPeriod >= 4 seconds && stakingPeriod < 24 seconds){
        //     returnPersentage = 5;
        // }
        //if staking period is greater than 1 month(30days) and less than 6 month (~183 days) ROI is 5%  
        if (stakingPeriod >= 30 days && stakingPeriod < 183 days){
            returnPersentage = 5;
        }
        //if staking period is greater than 6 month(~183 days) and less than 1 year(365 days) ROI is 10%
        else if(stakingPeriod >= 183 days && stakingPeriod < 365 days){
            returnPersentage = 10;
        }
        //if staking period is greater than 1 year, ROI is 15%
        else if(stakingPeriod >= 365 days) {
            returnPersentage = 15;
        }
        //erc20 decimal is present,considering it into the calculation 
        return (10**ERC20Tokendecimals * _tokenAmount * returnPersentage)/100 ; 

    }
    //we need this function to recieve ERC1155 NFT
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }


}