import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {testnets} from '../utils/constants';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();
  const chainId = await hre.getChainId();

  if (testnets.includes(chainId)) {

    await deploy('WETH', {
      from: deployer,
      args: [1_000_000_000],
      log: true,
      autoMine: true,
    });
  }

};

func.tags = ['local', 'seed'];
export default func;