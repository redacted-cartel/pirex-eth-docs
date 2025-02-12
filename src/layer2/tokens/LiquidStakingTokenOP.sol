// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {LiquidStakingToken} from "../LiquidStakingToken.sol";
import {ICrossDomainMessenger} from "src/vendor/layerzero/syncpools/interfaces/ICrossDomainMessenger.sol";
import {IL1Receiver} from "src/vendor/layerzero/syncpools/interfaces/IL1Receiver.sol";

/**
 * @title  OptimismLST
 * @notice An LiquidStakingToken OApp contract using non native bridges for syncing L2 deposits.
 * @dev    This contract facilitates interactions between mainnet PirexEth contracts and the L2 system.
 * @author redactedcartel.finance
 */
contract OptimismLST is LiquidStakingToken {
    /**
     * @notice Contract constructor to initialize LiquidStakingTokenVault with necessary parameters and configurations.
     * @dev    This constructor sets up the LiquidStakingTokenVault contract, configuring key parameters and initializing state variables.
     * @param  _endpoint   address  The address of the LOCAL LayerZero endpoint.
     * @param  _srcEid     uint32   The source endpoint ID.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address _endpoint,
        uint32 _srcEid
    ) LiquidStakingToken(_endpoint, _srcEid) {}

    /**
     * @dev Internal function to send a slow sync message
     * @param _value Amount of ETH to send
     * @param _data Data to send
     */
    function _sendSlowSyncMessage(
        address,
        uint256 _value,
        uint256,
        bytes memory _data
    ) internal override {
        bytes memory message = abi.encodeCall(
            IL1Receiver.onMessageReceived,
            _data
        );

        ICrossDomainMessenger(getMessenger()).sendMessage{value: _value}(
            getReceiver(),
            message,
            _minGasLimit()
        );
    }

    /**
     * @dev Internal function to get the minimum gas limit
     * This function should be overridden to set a minimum gas limit to forward during the execution of the message
     * by the L1 receiver contract. This is mostly needed if the underlying contract have some try/catch mechanism
     * as this could be abused by gas-griefing attacks.
     * @return minGasLimit Minimum gas limit
     */
    function _minGasLimit() internal pure override returns (uint32) {
        return 200_000;
    }
}
