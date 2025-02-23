// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() external payable {
        require(msg.value > 0, "No funds sent");
    }

    function releasePayment(address recipient, uint256 amount) external {
        require(msg.sender == owner, "Owner only");
        require(address(0x1029BBd9B780f449EBD6C74A615Fe0c04B61679c).balance >= amount, "Insufficient funds");
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Add this to accept raw Ether
    receive() external payable {}
}