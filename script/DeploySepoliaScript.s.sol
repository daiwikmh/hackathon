// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../lib/forge-std/src/Script.sol';
import "../src/demos/contracts/Escrow.sol";
import "../src/demos/contracts/MockOracle.sol";

contract DeploySepoliaScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy EscrowContract
        EscrowContract escrow = new EscrowContract();
        console.log("EscrowContract deployed at:", address(escrow));

        // Deploy MockOracle
        MockOracle oracle = new MockOracle();
        console.log("MockOracle deployed at:", address(oracle));

        // Fund Escrow
        (bool success, ) = address(escrow).call{value: 0.0001 ether}("");
        require(success, "Funding escrow failed");

        vm.stopBroadcast();
    }
}