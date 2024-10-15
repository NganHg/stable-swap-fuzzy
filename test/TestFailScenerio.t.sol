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

contract TestFailScenerio is Test {
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

    StableSwapThreePool pool;

    address liquidityProvider = makeAddr("liquidityProvider");

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
        vm.stopPrank();
        vm.warp(block.timestamp + 1); 
    }

    function test_add_liquidity() public {
      // uint256[3] memory liquidity = [uint256(926463188431538531875562013941), uint256(59634126022363693379124138257717725227645731828336323240415905418791019383), uint256(1091094202544652076012869)];
      // uint256[3] memory liquidity = [uint256(56375997912), uint256(56121354), uint256(152745063003592899)];
      uint256[3] memory liquidity = [uint256(1e6 * 1e18), uint256(1e6 * 1e6), uint256(1e6 * 1e6)];
      _addLiquidity(pool, liquidity);
    }

    function _addLiquidity(
        StableSwapThreePool _threePool,
        uint256[3] memory liquidityAmount
    ) private {
        address _tokenA = _threePool.coins(0);
        address _tokenB = _threePool.coins(1);
        address _tokenC = _threePool.coins(2);
        deal(_tokenA, liquidityProvider, liquidityAmount[0]);
        deal(_tokenB, liquidityProvider, liquidityAmount[1]);
        deal(_tokenC, liquidityProvider, liquidityAmount[2]);

        vm.startPrank(liquidityProvider);
        IERC20(_tokenA).approve(address(_threePool), liquidityAmount[0]);
        IERC20(_tokenB).approve(address(_threePool), liquidityAmount[1]);
        IERC20(_tokenC).approve(address(_threePool), liquidityAmount[2]);
        _threePool.add_liquidity(liquidityAmount, 0);
        vm.stopPrank();
    }
}
