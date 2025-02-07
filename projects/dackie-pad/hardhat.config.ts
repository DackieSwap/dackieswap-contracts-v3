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
  version: '0.6.12',
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
  version: '0.6.12',
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
  version: '0.6.12',
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
  accounts: [process.env.KEY_MAINNET!],
  gasPrice: 100000000
}

const baseSepolia: NetworkUserConfig = {
  url: "https://sepolia.base.org",
  chainId: 84532,
  accounts: [process.env.KEY_TESTNET!],
}

const scrollMainnet: NetworkUserConfig = {
  url: 'https://rpc.scroll.io/',
  chainId: 534352,
  accounts: [process.env.KEY_MAINNET!]
}

const goerli: NetworkUserConfig = {
  url: 'https://goerli.blockpi.network/v1/rpc/public/',
  chainId: 5,
  accounts: [process.env.KEY_TESTNET!]
}

const vicTestnet: NetworkUserConfig = {
  url: "https://rpc-testnet.viction.xyz",
  chainId: 89,
  accounts: [process.env.KEY_TESTNET!],
};

const vicMainnet: NetworkUserConfig = {
  url: "https://rpc.viction.xyz",
  chainId: 88,
  accounts: [process.env.KEY_MAINNET!],
};

const x1Testnet: NetworkUserConfig = {
  url: "https://testrpc.x1.tech",
  chainId: 195,
  accounts: [process.env.KEY_TESTNET!],
};

const xLayerMainnet: NetworkUserConfig = {
  url: "https://rpc.xlayer.tech",
  chainId: 196,
  accounts: [process.env.KEY_MAINNET!],
};

const modeMainnet: NetworkUserConfig = {
  url: "https://mainnet.mode.network",
  chainId: 34443,
  accounts: [process.env.KEY_MAINNET!],
};

const modeTestnet: NetworkUserConfig = {
  url: "https://sepolia.mode.network",
  chainId: 919,
  accounts: [process.env.KEY_TESTNET!],
};

const mantaNetwork: NetworkUserConfig = {
  url: "https://pacific-rpc.manta.network/http",
  chainId: 169,
  accounts: [process.env.KEY_MAINNET!],
};

const opMainnet: NetworkUserConfig = {
  url: "https://mainnet.optimism.io",
  chainId: 10,
  accounts: [process.env.KEY_MAINNET!],
};

const zetaMainnet: NetworkUserConfig = {
  // url: "https://zetachain-mainnet-archive.allthatnode.com:8545",
  url: "https://zetachain-evm.blockpi.network:443/v1/rpc/public",
  chainId: 7000,
  accounts: [process.env.KEY_MAINNET!],
};

const arbitrum: NetworkUserConfig = {
  url: "https://arb1.arbitrum.io/rpc",
  chainId: 42161,
  accounts: [process.env.KEY_MAINNET!],
};

const blastMainnet: NetworkUserConfig = {
  url: "https://blast.blockpi.network/v1/rpc/public",
  chainId: 81457,
  accounts: [process.env.KEY_MAINNET!],
};

const inEVM: NetworkUserConfig = {
  url: "https://mainnet.rpc.inevm.com/http",
  chainId: 2525,
  accounts: [process.env.KEY_MAINNET!],
};

const lineaMainnet: NetworkUserConfig = {
  url: "https://rpc.linea.build",
  chainId: 59144,
  accounts: [process.env.KEY_MAINNET!],
};

const mantleMainnet: NetworkUserConfig = {
  url: "https://rpc.mantle.xyz",
  chainId: 5000,
  accounts: [process.env.KEY_MAINNET!],
};

const config = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    baseMainnet: baseMainnet,
    baseSepolia,
    goerli: goerli,
    scrollMainnet: scrollMainnet,
    vicTestnet: vicTestnet,
    vicMainnet: vicMainnet,
    x1Testnet: x1Testnet,
    opMainnet: opMainnet,
    mantaNetwork: mantaNetwork,
    zetaMainnet,
    arbitrum,
    blastMainnet,
    inEVM,
    xLayerMainnet,
    modeMainnet,
    modeTestnet,
    lineaMainnet,
    mantleMainnet,
  },
  etherscan: {
    apiKey: {
      'baseMainnet': process.env.BASE_ETHERSCAN_API_KEY!,
      'baseSepolia': process.env.BASE_SEPOLIA_API_KEY!,
    },
    customChains: [
      {
        network: 'scrollMainnet',
        chainId: 534352,
        urls: {
          apiURL: 'https://api.scrollscan.com/api',
          browserURL: 'https://scrollscan.com'
        }
      },
      {
        network: 'baseSepolia',
        chainId: 84532,
        urls: {
          apiURL: "https://base-sepolia.blockscout.com/api",
          browserURL: "https://base-sepolia.blockscout.com/",
        }
      },
      {
        network: 'baseMainnet',
        chainId: 8453,
        urls: {
          apiURL: 'https://api.basescan.org/api',
          browserURL: 'https://basescan.org'
        }
      },
      {
        network: "vicMainnet",
        chainId: 88, // for mainnet
        urls: {
          apiURL: "https://www.vicscan.xyz/api/contract/hardhat/verify", // for mainnet
          browserURL: "https://vicscan.xyz", // for mainnet
        }
      },
      {
        network: "vicTestnet",
        chainId: 89, // for testnet
        urls: {
          apiURL: "https://scan-api-testnet.viction.xyz/api/contract/hardhat/verify", // for testnet
          browserURL: "https://www.testnet.vicscan.xyz", // for testnet
        }
      },
      {
        network: "x1Testnet",
        chainId: 195, // for testnet
        urls: {
          apiURL: "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/x1_test",
          browserURL: "https://www.oklink.com/x1-test"
        }
      },
      {
        network: "opMainnet",
        chainId: 10, // for testnet
        urls: {
          apiURL: "https://api-optimistic.etherscan.io/api",
          browserURL: "https://optimistic.etherscan.io/",
        }
      },
      {
        network: "zetaMainnet",
        chainId: 7000,
        urls: {
          apiURL: "???",
          browserURL: "https://explorer.zetachain.com/",
        }
      },
      {
        network: "arbitrum",
        chainId: 42161,
        urls: {
          apiURL: "https://api.arbiscan.io/api",
          browserURL: "https://arbiscan.io/",
        }
      },
      {
        network: "blastMainnet",
        chainId: 81457,
        urls: {
          apiURL: "https://api.blastscan.io/api",
          browserURL: "https://blastscan.io/",
        }
      },
      {
        network: "inEVM",
        chainId: 2525,
        urls: {
          apiURL: "https://explorer.inevm.com/api",
          browserURL: "https://explorer.inevm.com/",
        }
      },
      {
        network: "xLayerMainnet",
        chainId: 196,
        urls: {
          apiURL: "https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER",
          browserURL: "https://www.oklink.com/xlayer"
        }
      },
      {
        network: "modeMainnet",
        chainId: 34443,
        urls: {
          apiURL: "https://explorer.mode.network/api",
          browserURL: "https://explorer.mode.network/"
        }
      },
      {
        network: "modeTestnet",
        chainId: 919,
        urls: {
          apiURL: "https://sepolia.explorer.mode.network/api",
          browserURL: "https://sepolia.explorer.mode.network/"
        }
      },
      {
        network: "lineaMainnet",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build/"
        }
      },
      {
        network: "mantleMainnet",
        chainId: 5000,
        urls: {
          apiURL: "https://api.mantlescan.xyz/api",
          browserURL: "https://mantlescan.xyz/"
        }
      },
    ]
  },
  solidity: {
    compilers: [LOWEST_OPTIMIZER_COMPILER_SETTINGS],
  },
  paths: {
    sources: './contracts',
    cache: './cache',
    artifacts: './artifacts',
  },
}
export default config