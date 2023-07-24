import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const zero = await deploy("Zero", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`Zero contract: `, zero.address);

  const DEX = await deploy("DecentralizedExchange", {
    from: deployer,
    args: [zero.address],
    log: true,
  });

  console.log(`Dex contract: `, DEX.address);
};

export default func;