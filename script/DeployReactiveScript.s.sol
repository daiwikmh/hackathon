// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../lib/forge-std/src/Script.sol';
import "../src/demos/contracts/ReactiveTracker.sol";

contract DeployReactiveScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Manually set gas price to avoid estimation
        vm.txGasPrice(1000000000); // 1 Gwei, adjust based on network

        ReactiveTracker tracker = new ReactiveTracker{value: 120000000000000}(
            0xF2D82330a6aD227C59604Cbd65AE522fbD352935, // _oracle
            0xF2D82330a6aD227C59604Cbd65AE522fbD352935, // _escrow
            0x1029BBd9B780f449EBD6C74A615Fe0c04B61679c  // _supplier
        );
        console.log("ReactiveTracker deployed at:", address(tracker));

        vm.stopBroadcast();
    }
}