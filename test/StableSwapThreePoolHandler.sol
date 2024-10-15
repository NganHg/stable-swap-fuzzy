// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, StdInvariant, console, StdCheats} from "forge-std/Test.sol";
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
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint8 public _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 newDecimals
    ) ERC20(name, symbol) {
        _decimals = newDecimals;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

contract StableSwapThreePoolHandler is Test {
    StableSwapThreePool pool;

    address tokenA;
    address tokenB;
    address tokenC;

    address tokenLP;

    address liquidityProvider = makeAddr("liquidityProvider");
    address user = makeAddr("user");

    uint256 public constant N_COINS = 3;
    address[N_COINS] coins;
    uint256 public constant MAX_DECIMAL = 18; //Maximum number of decimal places for the token balances
    uint256 public constant FEE_DENOMINATOR = 1e10; //The denominator used to calculate the fee, fees are expressed as a fraction of 1e10
    uint256 public constant PRECISION = 1e18; // The precision to which values are calculated, accurate up to 18 decimal places
    uint256[N_COINS] public PRECISION_MUL; //Array of integers that coin balances are multiplied by in order to adjust their precision to 18 decimal places
    uint256[N_COINS] public RATES; //Array of integers indicating the relative value of `1e18` tokens for each stablecoin

    uint256 public constant MAX_ADMIN_FEE = 1e10;
    uint256 public constant MAX_FEE = 5e9;
    uint256 public constant MAX_A = 1e6;
    uint256 public constant MAX_A_CHANGE = 10;
    uint256 public constant MIN_ROSE_gas = 2300;
    uint256 public constant MAX_ROSE_gas = 23000;

    constructor(StableSwapThreePool _pool) {
        pool = _pool;

        tokenA = pool.coins(0);
        tokenB = pool.coins(1);
        tokenC = pool.coins(2);

        coins[0] = tokenA;
        coins[1] = tokenB;
        coins[2] = tokenC;

        RATES[0] = pool.RATES(0);
        RATES[1] = pool.RATES(1);
        RATES[2] = pool.RATES(2);

        tokenLP = address(pool.token());
    }

    function add_liquidity(uint256[N_COINS] memory amounts) public {
        // Mint
        deal(tokenA, liquidityProvider, amounts[0]);
        deal(tokenB, liquidityProvider, amounts[1]);
        deal(tokenC, liquidityProvider, amounts[2]);

        vm.startPrank(liquidityProvider);

        // Approve
        IERC20(tokenA).approve(address(pool), amounts[0]);
        IERC20(tokenB).approve(address(pool), amounts[1]);
        IERC20(tokenC).approve(address(pool), amounts[2]);

        // Add Liquidity
        pool.add_liquidity(amounts, 0);

        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    function exchange(uint256 i, uint256 j, uint256 dx) public {
        // Condition
        i = bound(i, 0, 2);
        j = bound(j, 0, 2);
        vm.assume(i != j);
        uint256[N_COINS] memory old_balances;
        for (uint16 ii = 0; ii < N_COINS; ii++) {
            old_balances[ii] = pool.balances(ii);
        }
        vm.assume(dx < old_balances[i]);

        // Mint
        deal(coins[i], user, dx);

        // exchange
        vm.startPrank(user);
        IERC20(coins[i]).approve(address(pool), dx);
        pool.exchange(i, j, dx, 0);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    function remove_liquidity(uint256 _amount) public {
        // Condition
        vm.assume(_amount <= IERC20(tokenLP).balanceOf(liquidityProvider));

        // Remove Liquidity
        vm.startPrank(liquidityProvider);
        pool.remove_liquidity(_amount, [uint256(0), uint256(0), uint256(0)]);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    function remove_liquidity_imbalance(
        uint256[N_COINS] memory amounts
    ) public {
        // Condition
        uint256[N_COINS] memory balances;
        for (uint16 ii = 0; ii < N_COINS; ii++)
            balances[ii] = pool.balances(ii);
        for (uint16 i = 0; i < N_COINS; i++)
            vm.assume(balances[i] >= amounts[i]);

        // Remove Liquidity Imbalance
        vm.startPrank(liquidityProvider);
        uint256 max_burn_amount = IERC20(tokenLP).balanceOf(liquidityProvider);
        pool.remove_liquidity_imbalance(amounts, max_burn_amount);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i
    ) public {
        // Condition
        vm.assume(
            _token_amount <= IERC20(tokenLP).balanceOf(liquidityProvider)
        );

        // Remove Liquidity One Coin
        vm.prank(liquidityProvider);
        pool.remove_liquidity_one_coin(_token_amount, i, 0);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    /*//////////////////////////////////////////////////////////////
                    HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _xp_mem(
        uint256[N_COINS] memory _balances
    ) internal view returns (uint256[N_COINS] memory result) {
        result = RATES;
        for (uint256 i = 0; i < N_COINS; i++) {
            result[i] = (result[i] * _balances[i]) / PRECISION;
        }
    }

    function get_xp() public view returns (uint256[N_COINS] memory result) {
        uint256[N_COINS] memory balances;
        for (uint16 ii = 0; ii < N_COINS; ii++) {
            balances[ii] = pool.balances(ii);
        }
        result = RATES;
        for (uint16 ii = 0; ii < N_COINS; ii++) {
            result[ii] = (result[ii] * balances[ii]) / PRECISION;
        }
    }

    function get_A() public view returns (uint256) {
        return pool.A();
    }

    function get_y(
        uint256 i,
        uint256 j,
        uint256 x,
        uint256[N_COINS] memory xp_
    ) external view returns (uint256) {
        // x in the input is converted to the same price/precision
        require(
            (i != j) && (i < N_COINS) && (j < N_COINS),
            "Illegal parameter"
        );
        uint256 amp = get_A();
        uint256 D = get_D(xp_, amp);
        uint256 c = D;
        uint256 S_;
        uint256 Ann = amp * N_COINS;

        uint256 _x;
        for (uint256 k = 0; k < N_COINS; k++) {
            if (k == i) {
                _x = x;
            } else if (k != j) {
                _x = xp_[k];
            } else {
                continue;
            }
            S_ += _x;
            c = (c * D) / (_x * N_COINS);
        }
        c = (c * D) / (Ann * N_COINS);
        uint256 b = S_ + D / Ann; // - D
        uint256 y_prev;
        uint256 y = D;

        for (uint256 m = 0; m < 255; m++) {
            y_prev = y;
            y = (y * y + c) / (2 * y + b - D);
            // Equality with the precision of 1
            if (y > y_prev) {
                if (y - y_prev <= 1) {
                    break;
                }
            } else {
                if (y_prev - y <= 1) {
                    break;
                }
            }
        }
        return y;
    }

    function get_D(
        uint256[N_COINS] memory xp,
        uint256 amp
    ) public pure returns (uint256) {
        uint256 S;
        for (uint256 i = 0; i < N_COINS; i++) {
            S += xp[i];
        }
        if (S == 0) {
            return 0;
        }

        uint256 Dprev;
        uint256 D = S;
        uint256 Ann = amp * N_COINS;
        for (uint256 j = 0; j < 255; j++) {
            uint256 D_P = D;
            for (uint256 k = 0; k < N_COINS; k++) {
                D_P = (D_P * D) / (xp[k] * N_COINS); // If division by 0, this will be borked: only withdrawal will work. And that is good
            }
            Dprev = D;
            D =
                ((Ann * S + D_P * N_COINS) * D) /
                ((Ann - 1) * D + (N_COINS + 1) * D_P);
            // Equality with the precision of 1
            if (D > Dprev) {
                if (D - Dprev <= 1) {
                    break;
                }
            } else {
                if (Dprev - D <= 1) {
                    break;
                }
            }
        }
        return D;
    }

    function get_pool_D() public view returns (uint256) {
        uint256 amp = pool.A();
        uint256[N_COINS] memory xp = get_xp();
        uint256 S;
        for (uint256 i = 0; i < N_COINS; i++) {
            S += xp[i];
        }
        if (S == 0) {
            return 0;
        }

        uint256 Dprev;
        uint256 D = S;
        uint256 Ann = amp * N_COINS;
        for (uint256 j = 0; j < 255; j++) {
            uint256 D_P = D;
            for (uint256 k = 0; k < N_COINS; k++) {
                D_P = (D_P * D) / (xp[k] * N_COINS); // If division by 0, this will be borked: only withdrawal will work. And that is good
            }
            Dprev = D;
            D =
                ((Ann * S + D_P * N_COINS) * D) /
                ((Ann - 1) * D + (N_COINS + 1) * D_P);
            // Equality with the precision of 1
            if (D > Dprev) {
                if (D - Dprev <= 1) {
                    break;
                }
            } else {
                if (Dprev - D <= 1) {
                    break;
                }
            }
        }
        return D;
    }
}
