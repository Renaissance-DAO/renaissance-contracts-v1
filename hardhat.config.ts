// https://github.com/wighawag/hardhat-deploy#2-extra-hardhatconfig-networks-options
import "dotenv/config";
import { HardhatUserConfig } from "hardhat/types";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "solidity-coverage";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-interface-generator";
import "hardhat-contract-sizer";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.11",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: +process.env.LOCAL_CHAINID!,
      saveDeployments: false,
      gasPrice: 200000000000,
      gas: 30000000,
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/7p4KzWgfAW2gU_4xOoPT5mpxDdOgFycO"
      }
    },
    rinkeby: {
      url: process.env.TEST_URI,
      chainId: +process.env.TEST_CHAINID!,
      accounts: [`${process.env.TEST_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 2000000000,
      gas: 8000000,
      saveDeployments: false,
    },
    ethereum: {
      url: process.env.MAIN_URI,
      chainId: +process.env.MAIN_CHAINID!,
      accounts: [`${process.env.MAIN_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 2000000000,
      gas: 8000000,
      saveDeployments: true,
    }
  },
  paths: {
    sources: "./src/contracts",
    artifacts: "./build/artifacts",
    cache: "./build/cache",
  },
  namedAccounts: {
    deployer: 0,
    WETH: {
      hardhat: '0x000000000000000000000000000000000000000a',
      rinkeby: '0x000000000000000000000000000000000000000b',
      ethereum: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    },
    TREASURY: {
      default: '0x0000000000000000000000000000000000000001a',
    },
    UNISWAP_V2_FACTORY: {
      hardhat: '0x000000000000000000000000000000000000000a',
      rinkeby: '0x000000000000000000000000000000000000000b',
      ethereum: '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f',
    },
  },
};

export default config;
