// SPDX-License-Identifier: MIT
// A mock governance token created to show the DAO voting infrastructure
pragma solidity ^0.8.20;

// imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockGovernanceToken is ERC20, Ownable
{
    constructor() ERC20("Governance Token", "TEST") Ownable(msg.sender)
    {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1m tokens to deployer for testing
    }

    // Function to mint more tokens if need be for testing. (owner only, for testing)
    function mint(address to, uint256 amount) public onlyOwner
    {
        _mint(to, amount);
    }

    function getBalanceDebug(address account) public view returns(uint256)
    {
        return balanceOf(account); // Direct check for debugging
    }
}