// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, StdInvariant, console} from "forge-std/Test.sol";
import {StableSwapLP} from "../contracts/stableSwap/StableSwapLP.sol";
import {StableSwapFactory} from "../contracts/stableSwap/StableSwapFactory.sol";
import {StableSwapLPFactory} from "../contracts/stableSwap/StableSwapLPFactory.sol";
import {StableSwapTwoPool} from "../contracts/stableSwap/plain-pools/StableSwapTwoPool.sol";
import {StableSwapThreePool} from "../contracts/stableSwap/plain-pools/StableSwapThreePool.sol";
import {IStableSwapDeployer} from "../contracts/interfaces/IStableSwapDeployer.sol";
import {StableSwapTwoPoolDeployer} from "../contracts/stableSwap/StableSwapTwoPoolDeployer.sol";
import {StableSwapThreePoolDeployer} from "../contracts/stableSwap/StableSwapThreePoolDeployer.sol";
import {StableSwapInfo} from "../contracts/stableSwap/utils/StableSwapInfo.sol";
import {StableSwapTwoPoolInfo} from "../contracts/stableSwap/utils/StableSwapTwoPoolInfo.sol";
import {StableSwapThreePoolInfo} from "../contracts/stableSwap/utils/StableSwapThreePoolInfo.sol";
import {IStableSwapLPFactory} from "../contracts/interfaces/IStableSwapLPFactory.sol";
import {IStableSwapLP} from "../contracts/interfaces/IStableSwapLP.sol";
import {StableSwapRouter} from "../contracts/StableSwapRouter.sol";
import {IStableSwapInfo} from "../contracts/interfaces/IStableSwapInfo.sol";
import {StableSwapThreePoolHandler} from "./StableSwapThreePoolHandler.sol";
import {VyperHandler} from "./VyperHandler.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TwoHandler is Test {
    StableSwapThreePoolHandler handler1;
    VyperHandler handler2;

    uint256 public constant N_COINS = 3;

    constructor(
        StableSwapThreePoolHandler _handler1,
        VyperHandler _handler2
    ) {
        handler1 = _handler1;
        handler2 = _handler2;
    }

    function add_liquidity(uint256[N_COINS] memory amounts) public {
        handler1.add_liquidity(amounts);
        handler2.add_liquidity(amounts);
    }

    function exchange(uint256 i, uint256 j, uint256 dx) public {
        handler1.exchange(i, j, dx);
        handler2.exchange(i, j, dx);
    }

    function remove_liquidity(uint256 _amount) public {
        handler1.remove_liquidity(_amount);
        handler2.remove_liquidity(_amount);
    }

    function remove_liquidity_imbalance(
        uint256[N_COINS] memory amounts
    ) public {
        handler1.remove_liquidity_imbalance(amounts);
        handler2.remove_liquidity_imbalance(amounts);
    }

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i
    ) public {
        handler1.remove_liquidity_one_coin(_token_amount, i);
        handler2.remove_liquidity_one_coin(_token_amount, i);
    }
}
