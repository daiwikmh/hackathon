// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

interface IPayable {
    // @notice Allows contracts to pay their debts and resume subscriptions.
    receive() external payable;
    event Callback(
    uint256 indexed chain_id,
    address indexed _contract,
    uint64 indexed gas_limit,
    bytes payload
);

    // @notice Allows reactive contracts to check their outstanding debt.
    // @param _contract Reactive contract's address.
    function debt(address _contract) external view returns (uint256);
}
