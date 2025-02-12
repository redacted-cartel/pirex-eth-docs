// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {L1BaseReceiverUpgradeable} from "src/vendor/layerzero/syncpools/L1/L1BaseReceiverUpgradeable.sol";
import {IArbitrumMessenger} from "../interfaces/IArbitrumMessenger.sol";
import {IOutbox} from "../interfaces/IOutbox.sol";
import {Constants} from "src/vendor/layerzero/syncpools/libraries/Constants.sol";
import {Errors} from "../libraries/Errors.sol";

/**
 * @title L1 Arbitrum Receiver ETH
 * @notice L1 receiver contract for ETH
 * @dev This contract receives messages from the Arbitrum based L2 messenger and forwards them to the L1 sync pool
 * It only supports ETH
 */
contract L1ArbReceiverETH is L1BaseReceiverUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer for L1 Arbitrum Receiver ETH
     * @param l1SyncPool Address of the L1 sync pool
     * @param messenger Address of the messenger contract
     * @param owner Address of the owner
     */
    function initialize(
        address l1SyncPool,
        address messenger,
        address owner
    ) external initializer {
        __Ownable_init(owner);
        __L1BaseReceiver_init(l1SyncPool, messenger);
    }

    /**
     * @dev Function to receive messages from the L2 messenger
     * @param message The message received from the L2 messenger
     */
    function onMessageReceived(
        bytes calldata message
    ) external payable virtual override {
        (
            uint32 originEid,
            bytes32 guid,
            address tokenIn,
            uint256 amountIn,
            uint256 amountOut
        ) = abi.decode(message, (uint32, bytes32, address, uint256, uint256));

        address sender = IOutbox(
            IArbitrumMessenger(getMessenger()).activeOutbox()
        ).l2ToL1Sender();

        _forwardToL1SyncPool(
            originEid,
            bytes32(uint256(uint160(sender))),
            guid,
            tokenIn,
            amountIn,
            amountOut,
            msg.value
        );
    }
}
