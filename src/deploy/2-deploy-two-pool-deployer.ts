import { ethers, upgrades } from "hardhat";
import * as dotenv from "dotenv";
import { writeToEnvFile } from "../utils/helper";

dotenv.config();

async function deploy() {

    const stableSwapTwoPoolDeployerFactory = await ethers.getContractFactory("StableSwapTwoPoolDeployer");
    const stableSwapTwoPoolDeployerContract = await stableSwapTwoPoolDeployerFactory.deploy();
    await stableSwapTwoPoolDeployerContract.deployed();
    
    console.log("Two pool deployer deploy at: ", stableSwapTwoPoolDeployerContract.address);

    writeToEnvFile("STABLE_SWAP_TWO_POOL_DEPLOYER", stableSwapTwoPoolDeployerContract.address);
    console.log("Success deploy");
}

async function setUp() {
    var two_pool_deployer = await ethers.getContractAt("StableSwapTwoPoolDeployer", process.env.STABLE_SWAP_TWO_POOL_DEPLOYER!);
    var stable_swap_factory_address = process.env.STABLE_SWAP_FACTORY!;

    var tx = await two_pool_deployer.transferOwnership(stable_swap_factory_address);
    console.log("transferOwnership success!", tx.hash);
}


async function main() {
    await deploy();
    // await setUp();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });