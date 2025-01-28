// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoolManager } from "@uniswap/v4-core/interfaces/IPoolManager.sol";
import { IHooks } from "@uniswap/v4-core/interfaces/IHooks.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { CurrencyLibrary, Currency } from "@uniswap/v4-core/src/types/Currency.sol";

contract PoolInitialize {
    using CurrencyLibrary for Currency;

    // set the init router
    IPoolManager manager = IPoolManager(address(0x01));

    function init(
        address token0,
        address token1,
        uint24 swapFee,
        int24 tickSpacing,
        address hook,
        uint160 sqrtPriceX96, // price ratio between tokens in liquidity pool, square root of price (t1/t2) scaled by 2^96, a fixed point math representation
        bytes calldata hookData
    ) external {
        //sort tokens, token 0 must be less than token 1
        if (token0 > token1) { (token0, token1) = (token1, token0); }
    }

    PoolKey memory pool = PoolKey({
        currency0: Currency.wrap(token0),
        currency1: Currency.wrap(token1),
        fee: swapFee,
        tickSpacing: tickSpacing,
        hooks: IHooks(hook)
    });
    manager.initialize(pool, sqrtPriceX96, hookData);
}
