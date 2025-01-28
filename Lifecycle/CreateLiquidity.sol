// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoolManager } from "@uniswap/v4-core/interfaces/IPoolManager.sol";
import { PoolModifyLiquidityTest } from "@uniswap/v4-core/src/test/PoolModifyLiquidityTest.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";

// creating liquidity involves using periphery contrats. It is not recommended to directly provide liquidity with PoolManager.modifyPosition
// providing liquidity involves three primary arguments: Which pool to LP on, The range of liquidity, and a liquidity value that determines token input amounts

contract CreateLiquidity {
    // set the test router address
    PoolModifyLiquidityTest lpRouter = PoolModifyLiquidityTest(address(0x01));

    function createLiquidity(
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper,
        int256 liquidity,
        bytes calldata hookData
    ) external {
        // if 0 < Liquidity: add liquidity - - otherwise remove liquidity
        lpRouter.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams({
                tickLower: tickLower,
                tickUpper: tickUpper,
                liquidityDelta: liquidity,
                salt: 0
            }),
            hookData
        );
    }
}
