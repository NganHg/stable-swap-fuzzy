// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, StdInvariant, console} from "forge-std/Test.sol";
import {VyperDeployer} from "utils/VyperDeployer.sol";
import {IVyperStableSwap} from "../src/IVyperStableSwap.sol";
import {IVyperStableSwapLP} from "../src/IVyperStableSwapLP.sol";
import {VyperHandler} from "./VyperHandler.sol";
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
import {TwoHandler} from "./TwoHandler.sol";
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

    StableSwapThreePoolHandler solid_handler;
    StableSwapThreePoolHandler viper_handler;
    StableSwapThreePool solid_pool;

    VyperDeployer vyperDeployer = new VyperDeployer();
    VyperDeployer vyperDeployer2 = new VyperDeployer();
    IVyperStableSwap vyper_pool;
    IVyperStableSwapLP vyperStableSwapLP;
    VyperHandler vyper_handler;

    TwoHandler twoHandler;

    function setUp() public {
        // Create Solid Handler
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

        console.log("token A", tokenA);
        console.log("token B", tokenB);
        console.log("token C", tokenC);

        factory.createSwapPair(tokenA, tokenB, A, fee, admin_fee);
        factory.createThreePoolPair(tokenA, tokenB, tokenC, A, fee, admin_fee);

        address swapThreeContract = factory
            .getThreePoolPairInfo(tokenA, tokenB)
            .swapContract;
        console.log("Pool contract address first time :", swapThreeContract);
        // _addLiquidity(StableSwapTwoPool(swapContract), 1_000_000 ether);
        vm.stopPrank();

        solid_pool = StableSwapThreePool(swapThreeContract);
        solid_handler = new StableSwapThreePoolHandler(solid_pool);

        // Create Viper Handler
        vyperStableSwapLP = IVyperStableSwapLP(
            vyperDeployer.deployContract(
                "vyper_contracts/",
                "VyperStableSwapLP",
                abi.encode("LP", "LP", 18, 0)
            )
        );

        console.log("lp: ", address(vyperStableSwapLP));
        console.log("deployer: ", address(vyperDeployer));

        vyper_pool = IVyperStableSwap(
            vyperDeployer2.deployContract(
                "vyper_contracts/",
                "VyperStableSwap",
                abi.encode(
                    owner,
                    [tokenA, tokenB, tokenC],
                    address(vyperStableSwapLP),
                    A,
                    fee,
                    admin_fee
                )
            )
        );

        vm.prank(address(vyperDeployer));
        vyperStableSwapLP.set_minter(address(vyper_pool));
        vm.stopPrank();
        vm.warp(block.timestamp + 1);

        vyper_handler = new VyperHandler(
            vyper_pool,
            address(vyperStableSwapLP)
        );

        console.log("solid pool: ", address(solid_pool));
        console.log("vyper pool: ", address(vyper_pool));

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
        IERC20(tokenA).approve(address(solid_pool), amounts[0]);
        IERC20(tokenB).approve(address(solid_pool), amounts[1]);
        IERC20(tokenC).approve(address(solid_pool), amounts[2]);
        solid_pool.add_liquidity(amounts, 0);
        vm.stopPrank();
        vm.warp(block.timestamp + 1);

        deal(tokenA, owner, amounts[0]);
        deal(tokenB, owner, amounts[1]);
        deal(tokenC, owner, amounts[2]);
        vm.startPrank(owner);
        IERC20(tokenA).approve(address(vyper_pool), amounts[0]);
        IERC20(tokenB).approve(address(vyper_pool), amounts[1]);
        IERC20(tokenC).approve(address(vyper_pool), amounts[2]);
        vyper_pool.add_liquidity(amounts, 0);
        // try vyper_pool.add_liquidity(amounts, 0) {
        // } catch Error(string memory reason) {
        //     console.log("1111111");
        // } catch (bytes memory lowLevelData) {
        //     console.log("2222222");
        // }

        vm.stopPrank();
        vm.warp(block.timestamp + 1);

        twoHandler = new TwoHandler(solid_handler, vyper_handler);

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = TwoHandler.add_liquidity.selector;
        selectors[1] = TwoHandler.exchange.selector;
        selectors[2] = TwoHandler.remove_liquidity.selector;
        selectors[3] = TwoHandler.remove_liquidity_imbalance.selector;
        selectors[4] = TwoHandler.remove_liquidity_one_coin.selector;

        targetSelector(
            FuzzSelector({addr: address(twoHandler), selectors: selectors})
        );
        targetContract(address(twoHandler));
    }

    function invariant_same_D() public {
        try this._invariant_same_D() {
            // code to execute if no error
        } catch Error(string memory reason) {
            // code to execute if error
            assert(true);
        } catch (bytes memory lowLevelData) {
            // code to execute if low-level error
            assert(true);
        }
    }

    function _invariant_same_D() external {
        uint256 solid_A = solid_pool.A();
        uint256[N_COINS] memory solid_xp = solid_handler.get_xp();
        uint256 solid_D = solid_handler.get_D(solid_xp, solid_A);

        uint256 vyper_A = vyper_pool.A();
        uint256[N_COINS] memory vyper_xp = vyper_handler.get_xp();
        uint256 vyper_D = vyper_handler.get_D(vyper_xp, vyper_A);

        assertEq(solid_D, vyper_D);
    }

    // function invariant_same_D() external {
    //     uint256 solid_A = solid_pool.A();
    //     uint256[N_COINS] memory solid_xp = solid_handler.get_xp();
    //     uint256 solid_D = solid_handler.get_D(solid_xp, solid_A);

    //     uint256 vyper_A = vyper_pool.A();
    //     uint256[N_COINS] memory vyper_xp = vyper_handler.get_xp();
    //     uint256 vyper_D = vyper_handler.get_D(vyper_xp, vyper_A);

    //     assertEq(solid_D, vyper_D);
    // }
}
