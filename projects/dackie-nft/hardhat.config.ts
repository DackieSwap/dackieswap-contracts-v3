import type { HardhatUserConfig, NetworkUserConfig } from 'hardhat/types'
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "solidity-coverage";
import "solidity-docgen";
import "dotenv/config";
require('dotenv').config({ path: require('find-config')('.env') })

const LOW_OPTIMIZER_COMPILER_SETTINGS = {
  version: '0.8.12',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 2_000,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}

const LOWEST_OPTIMIZER_COMPILER_SETTINGS = {
  version: '0.8.12',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 400,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.12',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 1_000_000,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}
const baseMainnet: NetworkUserConfig = {
  url: "https://mainnet.base.org/",
  chainId: 8453,
  accounts: [process.env.KEY_MAINNET_NFT!],
  gasPrice: 100000000
};

const baseGoerli: NetworkUserConfig = {
  url: "https://goerli.base.org/",
  chainId: 84531,
  accounts: [process.env.KEY_TESTNET!],
  gasPrice: 100000000
};

const goerli: NetworkUserConfig = {
  url: "https://goerli.blockpi.network/v1/rpc/public/",
  chainId: 5,
  accounts: [process.env.KEY_TESTNET!],
};

const config = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    baseMainnet: baseMainnet,
    baseGoerli: baseGoerli,
    goerli: goerli,
  },
  etherscan: {
    apiKey: {
      "baseGoerli": process.env.ETHERSCAN_API_KEY!,
      "baseMainnet": process.env.BASE_ETHERSCAN_API_KEY!
    },
    customChains: [
      {
        network: "baseGoerli",
        chainId: 84531,
        urls: {
          apiURL: "https://api-goerli.basescan.org/api",
          browserURL: "https://goerli.basescan.org"
        }
      },
      {
        network: "baseMainnet",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      }
    ]
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
    overrides: {
      'contracts/DackieNFT.sol': LOWEST_OPTIMIZER_COMPILER_SETTINGS,
      'contracts/DackiEggNFT.sol': LOWEST_OPTIMIZER_COMPILER_SETTINGS,
    },
  },
  paths: {
    sources: './contracts',
    cache: './cache',
    artifacts: './artifacts',
  },
}
export default config