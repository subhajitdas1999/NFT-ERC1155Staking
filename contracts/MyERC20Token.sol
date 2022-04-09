//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20Token is ERC20, Ownable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialBitsSupply
    ) ERC20(_name, _symbol) {
        _mint(owner(), _initialBitsSupply);
    }

    //mint tokensBits. onlyOwner can mint tokens
    function mint(uint256 _tokenSupply) public onlyOwner {
        _mint(owner(), _tokenSupply);
    }

    //burn Token Bits. onlyOwner can mint tokens
    function burn(uint256 _tokenBitsAmount) public onlyOwner {
        _burn(owner(), _tokenBitsAmount);
    }
}
