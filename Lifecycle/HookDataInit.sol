// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";

IPoolManager manager = IPoolManager(0x01);

address hook = address(0x80); // prefix indicates the hook only has a beforeInitialize() function
address token0 = address(0x11);
address token1 = address(0x22);
uint24 swapFee = 3000; //0.3% fee tier
int24 tickSpacing = 60; // smaller tick spacing allows for more granular price ranges, which can improve capital eff. but increases computation and storage reqs.
// higher volatility pairs may require larger tick spacing.

// floor(sqrt(1) * 2^96 )
uint160 startingPrice = 79228162514264337593543950336;

// Asssume the custom hook requires a timestamp when initializing
bytes memory hookData = abi.encode(block.timestamp);

PoolKey memory pool = PoolKey({
    currency0: Currency.wrap(token0),
    currency1: Currency.wrap(token1),
    fee: swapFee,
    tickSpacing: tickSpacing,
    hooks: IHooks(hook)
});
manager.initialize(pool, startingPrice, hookData);