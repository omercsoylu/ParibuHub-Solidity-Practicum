// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract FeeCollector {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        balance += msg.value;
    }

    function withdraw(uint256 _amount, address payable _toAddress) public {
        require(
            owner == msg.sender,
            "You are not authorized to this transaction."
        );
        require(balance >= _amount, "Insufficient balance.");

        balance -= _amount;
        _toAddress.transfer(_amount);
    }
}
