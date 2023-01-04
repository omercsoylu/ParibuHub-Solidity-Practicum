// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract FeeCollector {
    address public owner;
    uint256 public balance;

    constructor() {
        // When deploying the contract, the wallet address is assigned to the "owner" variable.
        owner = msg.sender;
    }

    receive() external payable {
        // allows the balance of the contract to be updated when it receives "Ether"
        balance += msg.value;
    }

    function withdraw(uint256 _amount, address payable _toAddress) public {
        // checks whether the wallet interacting with the function belongs to the "owner".
        require(
            owner == msg.sender,
            "You are not authorized to this transaction."
        );
        // checks if there is enough balance to withdraw
        require(balance >= _amount, "Insufficient balance.");

        // we update the "balance" variable before action to avoid any security problems.
        balance -= _amount;
        // the requested balance is transferred to the destination address.
        _toAddress.transfer(_amount);
    }
}
