// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol"; // ERC-20 import 
// don't have to invest your dead brain cells onto this. Think of it like the import of express 
// while making a node server. You don't dive into the node modules just to know what this express shi is right?
import "openzeppelin-contracts/contracts/access/Ownable.sol";
//And the above fellow is just a sidechick that gives your token an owner (usually the deployer)


// learn the syntax dwag
contract Token is ERC20, Ownable {
    constructor(address initialOwner, uint256 initialSupply, string memory 
name, string memory symbol) // vars essential for token
        ERC20(name, symbol)
        Ownable(initialOwner)
    {
        _transferOwnership(initialOwner);
        _mint(initialOwner, initialSupply * 10 ** 18);

    }
}

//THis is just the syntax to mint an ERC20 token scrpit file help you to run it.