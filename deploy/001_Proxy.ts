import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts, ethers} = hre;
  
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();

  const signer = await ethers.getSigner(deployer)  
  
  // deploy the deployer
  const deployerResult = await deploy('Deployer', {
    from: deployer,
    log: true,
  });
  const deployerContract = new ethers.Contract(
    deployerResult.address,
    deployerResult.abi
  );

  // deploy the proxy controller
  const multiProxyControllerResult = await deploy('MultiProxyController', {
    from: deployer,
    args: [[], [], deployerResult.address]
  });

  // connect proxy controller w/ deployer contract
  await deployerContract.connect(signer).setProxyController(
    multiProxyControllerResult.address
  );

};
func.tags = ['main', 'local', 'seed'];
export default func;