//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NFTERC1155Staking {
    //staking id
    uint private stakeId;

    //NFT contract
    IERC1155 public NFTContract;
    //ERC20 token contract
    IERC20 public ERC20tokenContract;

    //ERC20 token decimals
    uint8 private tokenDecimals = 18;

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
    mapping( uint => Stake) public stakings;

    //event for staking
    event staked(address indexed staker, uint tokenId, uint tokenAmount,uint stakeId);
    //event for stake withdraw
    event withdrawStake(uint tokenId,uint withDrawTokenAmount,uint remainingTokenAmount,uint recievedROI);

    function stakeTokens(uint _tokenId,uint _tokenAmount) public{
        require(_tokenAmount>=100,"Token Amount should be greater than 100");
        stakeId++;
        Stake memory stake = Stake(
            msg.sender,
            _tokenId,
            _tokenAmount,
            block.timestamp
        );

        stakings[stakeId] = stake;
        NFTContract.safeTransferFrom(stake.stakeOwner,address(this),stake.tokenId,stake.tokenAmount,"");

        //emit the stake event
        emit staked(msg.sender,_tokenId,_tokenAmount,stakeId);
    }

    // withdraw the staked tokens with ERC20 in return
    function withdrawTokens(uint _stakeId,uint _withdrawTokenAmount) public {
        Stake storage stake = stakings[_stakeId];
        require(stake.tokenAmount >= _withdrawTokenAmount,"you have less stake balance");
        uint updatedTokenBalence = stake.tokenAmount - _withdrawTokenAmount;        
        require(updatedTokenBalence >= 100 || updatedTokenBalence==0,"withdraw all or remaining staking balance should be greater than 100");
        uint ERC20tokenAmount = _calculateROI(_stakeId,_withdrawTokenAmount);

        //update the new staking balance
        stake.tokenAmount = updatedTokenBalence;
        //return the staked tokens
        NFTContract.safeTransferFrom(address(this),stake.stakeOwner,stake.tokenId,_withdrawTokenAmount,"");
        //return the APR w.r.t ERC20
        ERC20tokenContract.transfer(stake.stakeOwner,ERC20tokenAmount);

        //emit the withdraw event
        emit withdrawStake(stake.tokenId,_withdrawTokenAmount,stake.tokenAmount,ERC20tokenAmount);
    }

    function _calculateROI(uint _stakeId,uint _tokenAmount) private view returns(uint){
        Stake memory stake = stakings[_stakeId];
        uint stakingPeriod = block.timestamp-stake.timeOfStaking;
        uint returnPersentage;

        //for testing purpose

        // if (stakingPeriod >= 4 seconds && stakingPeriod < 24 seconds){
        //     returnPersentage = 5;
        // }
        
        //if staking period is greater than 1 month and less than 6 month ROI is 5%
        if (stakingPeriod >= 4 weeks && stakingPeriod < 24 weeks){
            returnPersentage = 5;
        }       
        //if staking period is greater than 6 month and less than 1 year ROI is 10%
        else if(stakingPeriod >= 24 weeks && stakingPeriod < 48 weeks){
            returnPersentage = 10;
        }
        //if staking period is greater than 1 year, ROI is 15%
        else if(stakingPeriod >= 48 weeks) {
            returnPersentage = 15;
        }
        //erc20 decimal is present,considering it into the calculation 
        return (10**tokenDecimals * _tokenAmount * returnPersentage)/100 ; 

    }

    //we need this function to recieve ERC1155 NFT
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }


}