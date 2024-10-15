// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {StableSwapLP} from "../contracts/stableSwap/StableSwapLP.sol";
import {StableSwapFactory} from "../contracts/stableSwap/StableSwapFactory.sol";
import {StableSwapLPFactory} from "../contracts/stableSwap/StableSwapLPFactory.sol";
import {StableSwapTwoPool} from "../contracts/stableSwap/plain-pools/StableSwapTwoPool.sol";
import {StableSwapThreePool} from "../contracts/stableSwap/plain-pools/StableSwapThreePool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint8 public _decimals;

    constructor(string memory name, string memory symbol, uint8 newDecimals) ERC20(name, symbol) {
        _decimals = newDecimals;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

contract Report29 is Test {
    StableSwapLP public lp;
    address public tokenA;
    address public tokenB;
    StableSwapTwoPool public pool;
    address public owner = makeAddr("owner");
    uint256 public A = 1000; // from the tests
    uint256 public fee = 4_000_000; // from the tests
    uint256 public admin_fee = 5_000_000_000; // from the tests
    address public actor = makeAddr("actor"); // malicious actor
    address public user = makeAddr("user"); // normal user
    uint256 public decimals = 18;

    function setUp() public {
        lp = new StableSwapLP();

        tokenA = address(new MockERC20("TOKENA", "TOKENA", 18));
        tokenB = address(new MockERC20("TOKENB", "TOKENB", uint8(decimals)));

        pool = new StableSwapTwoPool();
        pool.initialize([tokenA, tokenB], A, fee, admin_fee, owner, address(lp));

        lp.setMinter(address(pool));
    }

    function test_POCDecimals() public {
        uint256 userInitLiq = 10_000_000;
        deal(tokenA, user, userInitLiq * 10 ** 18);
        deal(tokenB, user, userInitLiq * 10 ** decimals);

        vm.startPrank(user);
        IERC20(tokenA).approve(address(pool), userInitLiq * 10 ** 18);
        IERC20(tokenB).approve(address(pool), userInitLiq * 10 ** decimals);
        pool.add_liquidity([userInitLiq * 10 ** 18, userInitLiq * 10 ** decimals], 0);
        vm.stopPrank();

        console.log("TokenA balance of lp  :", IERC20(tokenA).balanceOf(address(pool)) / 1e18);
        console.log("TokenB balance of lp  :", IERC20(tokenB).balanceOf(address(pool)) / (10 ** decimals));

        address trader = makeAddr("trader");
        uint256 amountToTrade = 100 ether;

        deal(tokenA, trader, amountToTrade);
        vm.startPrank(trader);
        IERC20(tokenA).approve(address(pool), amountToTrade);
        pool.exchange(0, 1, amountToTrade, 0);
        vm.stopPrank();

        console.log("TokenB balance of lp  :", IERC20(tokenB).balanceOf(trader));
    }
}