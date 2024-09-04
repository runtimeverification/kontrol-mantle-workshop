// SPDX-License-Identifier: MIT
// Adapted from https://github.com/ethereum-optimism/optimism

pragma solidity ^0.8.13;

library Types {
    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }
}

contract Portal  {
    bool public paused;
    address public guardian;

    /// @notice Emitted when a withdrawal transaction is proven.
    event WithdrawalProven(address indexed from, address indexed to);

    /// @notice Emitted when the conract is paused.
    event Paused();

    /// @notice Reverts when paused.
    modifier whenNotPaused() {
        require(paused == false, "Portal: paused");
        _;
    }

    constructor() {
        guardian = msg.sender;
    }

    /// @notice Pauses this contract.
    function pause()
        external
        whenNotPaused
    {
        require(msg.sender == guardian, "Portal: not a guardian");
        paused = true;
        // Emit a `Paused` event.
        emit Paused();
    }

    /// @notice Accepts ETH value without triggering a deposit to L2.
    ///         This function mainly exists for the sake of the migration between the legacy
    ///         Optimism system and Bedrock.
    function donateETH() external payable {
        // Intentionally empty.
    }

   /// @notice Proves a withdrawal transaction.
    function proveWithdrawalTransaction(
        Types.WithdrawalTransaction memory _tx,
        uint256 _l2OutputIndex,
        Types.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    )
        external
        whenNotPaused
    {
        // Implementation omitted
        // Emit a `WithdrawalProven` event.
        emit WithdrawalProven(_tx.sender, _tx.target);
    }
}