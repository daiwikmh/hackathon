// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../IReactive.sol";
import "../../ISystemContract.sol";
import "../../ISubscriptionService.sol";
import "../../IPayer.sol";
import "../../AbstractReactive.sol";
import "./MockSystemContract.sol";

interface IEscrow {
    function releasePayment(address recipient, uint256 amount) external;
}

contract ReactiveTracker is IReactive,AbstractReactive {
    uint256 constant CHAIN_ID = 11155111;
    uint64 private constant CALLBACK_GAS_LIMIT = 300000000000;
    uint256 private constant PAYMENT_AMOUNT = 0.0001 ether;
    uint256 constant SHIPPED_TOPIC = uint256(keccak256("Shipped(address,uint256)"));
    uint256 constant DELIVERED_TOPIC = uint256(keccak256("Delivered(address,uint256)"));
    address constant CALLBACK_SENDER_ADDR = 0x33Bbb7D0a2F1029550B0e91f653c4055DC9F4Dd8;


    address public escrow;
    address public supplier;
    address public oracle;


    uint256 public milestoneCount;
    bool public paused;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    event SubscriptionStatus(bool success);

    constructor(
        address _oracle,
        address _escrow,
        address _supplier
    ) payable {
        owner = msg.sender;
        escrow = _escrow;
        supplier = _supplier;
        oracle = _oracle;

        try service.subscribe(
    CHAIN_ID,  // 11155111
    _oracle,   // e.g., 0x6F8bd7Af7E113Dc433b7a9dFf0DAB859cf09c3A5
    SHIPPED_TOPIC,
    REACTIVE_IGNORE,
    REACTIVE_IGNORE,
    REACTIVE_IGNORE
) {
    emit SubscriptionStatus(true);
} catch {
    emit SubscriptionStatus(false);
}
    }

    function react(LogRecord calldata log) external override {
        if (paused) return;

        // (uint256 shipmentId) = abi.decode(log.data, (uint256));

        if (log.topic_0 == SHIPPED_TOPIC) {
            milestoneCount += 1;
            // emit ShipmentUpdate(log.chain_id, log._contract, "Shipped", milestoneCount, shipmentId);
        } else if (log.topic_0 == DELIVERED_TOPIC) {
            milestoneCount += 1;
            // emit ShipmentUpdate(log.chain_id, log._contract, "Delivered", milestoneCount, shipmentId);
            emit Callback(CHAIN_ID, escrow, CALLBACK_GAS_LIMIT, abi.encodeWithSignature(
                "releasePayment(address,uint256)",
                address(0),
                PAYMENT_AMOUNT
            ));
        }
    }

    function pause() external onlyOwner {
        require(!paused, "Already paused");
        service.unsubscribe(
            CHAIN_ID,
            oracle,
            SHIPPED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.unsubscribe(
            CHAIN_ID,
            oracle,
            DELIVERED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        paused = true;
    }

    function resume() external onlyOwner {
        require(paused, "Not paused");
        service.subscribe(
            CHAIN_ID,
            oracle,
            SHIPPED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        service.subscribe(
            CHAIN_ID,
            oracle,
            DELIVERED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        paused = false;
    }

    receive() external payable {}

    event ShipmentUpdate(
        uint256 indexed chainId,
        address indexed contractAddress,
        string status,
        uint256 milestoneCount,
        uint256 shipmentId
    );
}