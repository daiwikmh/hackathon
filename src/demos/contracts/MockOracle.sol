// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockOracle {
    event Shipped(address indexed sender, uint256 shipmentId);
    event Delivered(address indexed sender, uint256 shipmentId);

    function emitShipped(uint256 shipmentId) external {
        emit Shipped(msg.sender, shipmentId);
    }

    function emitDelivered(uint256 shipmentId) external {
        emit Delivered(msg.sender, shipmentId);
    }
}