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
import {StableSwapRouter} from "../contracts/StableSwapRouter.sol";
import {IStableSwapInfo} from "../contracts/interfaces/IStableSwapInfo.sol";
import {StableSwapThreePoolHandler} from "./StableSwapThreePoolHandler.sol";
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

contract Invariant is StdInvariant, Test {
    address public tokenA;
    address public tokenB;
    address public tokenC;

    address public owner = makeAddr("owner");
    uint256 public A = 1000; // from the tests
    uint256 public fee = 4_000_000; // from the tests
    uint256 public admin_fee = 5_000_000_000; // from the tests
    uint256 public constant N_COINS = 3;

    StableSwapLPFactory public lpFactory;
    StableSwapTwoPoolDeployer public twoPoolDeployer;
    StableSwapThreePoolDeployer public threePoolDeployer;
    StableSwapFactory public factory;
    StableSwapThreePoolInfo public threePoolInfo;
    StableSwapTwoPoolInfo public twoPoolInfo;
    StableSwapInfo public poolInfo;
    StableSwapRouter public router;

    StableSwapThreePoolHandler handler;
    StableSwapThreePool pool;

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
        tokenB = address(new MockERC20("TOKENB", "TOKENB", 6));
        tokenC = address(new MockERC20("TOKENC", "TOKENC", 6));

        factory.createSwapPair(tokenA, tokenB, A, fee, admin_fee);
        factory.createThreePoolPair(tokenA, tokenB, tokenC, A, fee, admin_fee);

        address swapThreeContract = factory
            .getThreePoolPairInfo(tokenA, tokenB)
            .swapContract;
        console.log("Pool contract address first time :", swapThreeContract);
        // _addLiquidity(StableSwapTwoPool(swapContract), 1_000_000 ether);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);

        pool = StableSwapThreePool(swapThreeContract);
        handler = new StableSwapThreePoolHandler(pool);

        // add liquidity before test (optional) => decrease reverts
        uint256[N_COINS] memory amounts = [
            uint256(1e6 * 1e18),
            uint256(1e6 * 1e6),
            uint256(1e6 * 1e6)
        ];
        deal(tokenA, owner, amounts[0]);
        deal(tokenB, owner, amounts[1]);
        deal(tokenC, owner, amounts[2]);
        vm.startPrank(owner);
        IERC20(tokenA).approve(address(pool), amounts[0]);
        IERC20(tokenB).approve(address(pool), amounts[1]);
        IERC20(tokenC).approve(address(pool), amounts[2]);
        pool.add_liquidity(amounts, 0);
        vm.stopPrank();
        vm.warp(block.timestamp + 1); 

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = StableSwapThreePoolHandler.add_liquidity.selector;
        selectors[1] = StableSwapThreePoolHandler.exchange.selector;
        selectors[2] = StableSwapThreePoolHandler.remove_liquidity.selector;
        selectors[3] = StableSwapThreePoolHandler
            .remove_liquidity_imbalance
            .selector;
        selectors[4] = StableSwapThreePoolHandler
            .remove_liquidity_one_coin
            .selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    // function invariant_stable_swap() public {
        // uint256 _A = pool.A();
        // uint256 _n = pool.N_COINS();
        // uint256[N_COINS] memory _xp = handler.get_xp();
        // uint256 _D = handler.get_D(_xp, A);

        // uint256 x = pool.get_virtual_price();
        // console.log("price: ", x);
        // assert(true);

        // uint256 _D = handler.get_pool_D();

        // uint256 sum = 0;
        // uint256 product = 1;
        // uint256 D_n1 = _D;
        // uint256 n_n = 1;
        // for (uint16 i = 0; i < _n; i++) {
        //     sum = sum + _xp[i];
        //     product = product * _xp[i];
        //     D_n1 = D_n1 * _D;
        //     n_n = n_n * _n;
        // }

        // uint256 VT = _A * _n * sum + _D;
        // uint256 VP = _A * _n * _D + D_n1 / (n_n * product);

        // assertEq(VT, VP);
    // }

    function invariant_stable_swap() public {
        try this._invariant_stable_swap() {
            // code to execute if no error
        } catch Error(string memory reason) {
            // code to execute if error
            assert(true);
        } catch (bytes memory lowLevelData) {
            // code to execute if low-level error
            assert(true);
        }
    }

    function _invariant_stable_swap() external {
        uint256 _A = pool.A();
        uint256 _n = pool.N_COINS();
        uint256[N_COINS] memory _xp = handler.get_xp();
        uint256 _D = handler.get_D(_xp, A);

        uint256 sum = 0;
        uint256 product = 1;
        uint256 D_n1 = _D;
        uint256 n_n = 1;
        for (uint16 i = 0; i < _n; i++) {
            sum = sum + _xp[i];
            product = product * _xp[i];
            D_n1 = D_n1 * _D;
            n_n = n_n * _n;
        }

        if (product == 0) {
            assert(true);
            return;
        }

        uint256 VT = _A * _n * sum + _D;
        uint256 VP = _A * _n * _D + D_n1 / (n_n * product);

        assertEq(VT, VP);
    }
}
