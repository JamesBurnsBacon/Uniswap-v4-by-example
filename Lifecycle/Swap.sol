// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";

contract Swap {
    //set router address
    PoolSwapTest swapRouter = PoolSwapTest(address(0x01));

    //slippage tolerance to allow for unlimited price impact
    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_PRICE + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_PRICE - 1;

    /// @notice swap tokens
    /// @param key the pool where the swap is happening
    /// @param amountSpecified the amount of tokens to swap. Negative is an exact-input swap.
    /// @param zeroForOne whether the swap is token0 -> token1 or token1 -> token0.
    /// @param hookData any data to be passed to the pool's hook
    function swap(PoolKey memory key, int256 amountSpecified, bool zeroForOne, bytes memory hookData) internal {
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT //unlimited impact
        });

        // in v4, users have the option to recieve native ERC20's or wrapped ERC6909 tokens
        // here we'll take the ERC20s
        PoolSwapTest.TestSettings memory testSettings = PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false});

        swapRouter.swap(key, params, testSettings, hookData);
    }
}