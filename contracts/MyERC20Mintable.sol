//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyERC20Mintable is ERC20,Ownable{
    constructor(string memory _name,string memory _symbol,uint _initialSupply) ERC20(_name,_symbol){
        uint _initialSupplyWithDecimal = tokenWithDecimal(_initialSupply);
        _mint(owner(),_initialSupplyWithDecimal);
    }

    function mint(uint _tokenSupply) public onlyOwner{
        uint _supplyWithDecimal = tokenWithDecimal(_tokenSupply);
        _mint(owner(),_supplyWithDecimal);
    }

    function burn(uint _tokenAmount) public onlyOwner{
        uint _tokenAmountWithDecimal = tokenWithDecimal(_tokenAmount);
        _burn(owner(),_tokenAmountWithDecimal);
    }

    function tokenWithDecimal(uint _tokenAmount) private view returns(uint){
        return _tokenAmount * (10 ** (decimals()));
    }
}