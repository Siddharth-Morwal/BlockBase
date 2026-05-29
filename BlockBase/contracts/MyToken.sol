// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address public owner;
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10 ** 18;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        require(totalSupply() + _amount <= MAX_SUPPLY, "Cap exceeded");
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }
}