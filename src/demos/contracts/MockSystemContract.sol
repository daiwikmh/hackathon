// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../IReactive.sol";
import "../../ISubscriptionService.sol";


contract MockSystemContract is ISubscriptionService {
    // Toggle to simulate Reactive Network (RN) or ReactVM (RVM) context
    bool public isReactiveNetwork;

    // Track subscriptions for testing purposes (optional, can be extended)
    struct Subscription {
        uint256 chain_id;
        address _contract;
        uint256 topic_0;
        uint256 topic_1;
        uint256 topic_2;
        uint256 topic_3;
        bool active;
    }
    mapping(address => Subscription[]) public subscriptions; // Caller -> Subscriptions

    // Constructor to set initial context
    constructor(bool _isReactiveNetwork) {
        isReactiveNetwork = _isReactiveNetwork;
    }

    // Simulate RN (true) or RVM (false) context
    function ping() external pure override returns (bool) {
        return true; // Default to RN; overridden in tests if needed
    }

    // Subscribe to events; simulates Reactive Network behavior
    function subscribe(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3
    ) external override {
        require(isReactiveNetwork, "Subscriptions only in RN context");
        require(
            chain_id != 0 || _contract != address(0) || 
            topic_0 != REACTIVE_IGNORE || topic_1 != REACTIVE_IGNORE || 
            topic_2 != REACTIVE_IGNORE || topic_3 != REACTIVE_IGNORE,
            "At least one criterion must be specific"
        );

        // Store subscription for testing (optional)
        subscriptions[msg.sender].push(Subscription({
            chain_id: chain_id,
            _contract: _contract,
            topic_0: topic_0,
            topic_1: topic_1,
            topic_2: topic_2,
            topic_3: topic_3,
            active: true
        }));
    }

    // Unsubscribe from events; simulates Reactive Network behavior
    function unsubscribe(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3
    ) external override {
        require(isReactiveNetwork, "Unsubscriptions only in RN context");

        // Optional: Simulate removal by marking inactive
        Subscription[] storage subs = subscriptions[msg.sender];
        for (uint256 i = 0; i < subs.length; i++) {
            if (
                subs[i].chain_id == chain_id &&
                subs[i]._contract == _contract &&
                subs[i].topic_0 == topic_0 &&
                subs[i].topic_1 == topic_1 &&
                subs[i].topic_2 == topic_2 &&
                subs[i].topic_3 == topic_3 &&
                subs[i].active
            ) {
                subs[i].active = false;
                return; // Found and "removed"
            }
        }
        // No revert if not found, per interface spec
    }

    // IPayable: Handle debt queries (mocked for simplicity)
    function debt(address _contract) external view override returns (uint256) {
        return 0; // No debt in mock; can be extended for payment testing
    }

    // IPayable: Accept Ether
    receive() external payable override {}

    // Helper to toggle context for testing
    function setReactiveNetwork(bool _isReactiveNetwork) external {
        isReactiveNetwork = _isReactiveNetwork;
    }

    // Helper to check subscription count (for testing)
    function getSubscriptionCount(address subscriber) external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < subscriptions[subscriber].length; i++) {
            if (subscriptions[subscriber][i].active) {
                count++;
            }
        }
        return count;
    }
}

// Define REACTIVE_IGNORE as a constant if not in IPayable.sol
uint256 constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;