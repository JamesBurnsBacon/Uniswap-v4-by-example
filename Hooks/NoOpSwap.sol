// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {toBeforeSwapDelta, BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {SafeCast} from "v4-core/src/libraries/SafeCast.sol";

// elects to skip or delay the concentrated liquidity swap
// when a beforeSwap hook returns a BeforeSwapDelta that net exactly equal to params.amountSpecified, the subsequent swap operation is skipped.
// NoOp Swap requires Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
// NoOp will only work on beforeSwap
// used for async swap fulfillment. To reorder and fulfill swaps later.
// Combine NoOp + custom accounting to facilitate swaps with external liquidity.

contract NoOpSwap is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using SafeCast for uint256;

    mapping(PoolID => uint256 count) public beforeSwapCount;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external 
        override 
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        // example NoOp, if swap is exactInput and the amount is 69e18, then the swap will be skipped
        if (params.amountSpecified == -69e18) {
            // take the imput token so that v3 swap is skipped...
            uint256 amountTaken = 69e18;
            Currency imput = params.zeroForOne ? key.currency0 : key.currency1;
            poolManager.mint(address(this), input.toId(), amountTaken);

            // to NoOp the exact input, we return the amount that's taken by the hook
            return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(amountTaken.toInt128(), 0), 0);
        }

        beforeSwapCount[key.toId()]++;
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInititalize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterAddLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true, // no op'ing the swap
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true, // no op'ing the swap
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }    
}