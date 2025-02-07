import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@typechain/hardhat'
import 'dotenv/config'
import { NetworkUserConfig } from 'hardhat/types'
import 'solidity-docgen';
require('dotenv').config({ path: require('find-config')('.env') })

const baseMainnet: NetworkUserConfig = {
  url: "https://developer-access-mainnet.base.org/",
  chainId: 8453,
  accounts: [process.env.KEY_MAINNET!],
  gasPrice: 100000000
};

const baseGoerli: NetworkUserConfig = {
  url: "https://goerli.base.org/",
  chainId: 84531,
  accounts: [process.env.KEY_TESTNET!],
  gasPrice: 100000000
};

const config: HardhatUserConfig = {
  solidity: {
    version: '0.7.6',
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    baseMainnet: baseMainnet,
    baseGoerli: baseGoerli
  },
  etherscan: {
    apiKey: {
      'baseMainnet': process.env.BASE_ETHERSCAN_API_KEY!,
      'baseSepolia': process.env.BASE_SEPOLIA_API_KEY!,
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
  paths: {
    sources: './contracts/',
    cache: './cache',
    artifacts: './artifacts',
  },
}
export default config
