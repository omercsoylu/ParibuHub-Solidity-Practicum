// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Counter {
    // I preferred private to use view function
    uint256 private count;

    // increase count variable by 1
    function increment() external {
        count++;
    }

    // decrease count variable by 1
    function decrement() external {
        count--;
    }

    // returns the value of count variable
    function viewCount() external view returns (uint256) {
        return count;
    }
}
