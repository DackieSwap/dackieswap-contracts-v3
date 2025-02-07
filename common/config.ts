export const configs = {
  goerli: {
    WNATIVE: '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6',
    nativeCurrencyLabel: 'GOR',
    v2Factory: '0x1097053Fd2ea711dad45caCcc45EfF7548fCB362',
    stableFactory: '0x0000000000000000000000000000000000000000',
    stableInfo: '0x0000000000000000000000000000000000000000',
    cake: '0xc2C3eAbE0368a2Ea97f485b03D1098cdD7d0c081',
    smartRouterHelper: '0xdAecee3C08e953Bd5f89A5Cc90ac560413d709E3',
    scan: '',
    quack: '',
  },
  baseGoerli: {
    WNATIVE: '0x4200000000000000000000000000000000000006',
    nativeCurrencyLabel: 'ETH',
    v2Factory: '0x66139f664B7eC8F34A07236bc8450a9462F27a33',
    stableFactory: '0x0000000000000000000000000000000000000000',
    stableInfo: '0x0000000000000000000000000000000000000000',
    cake: '0xcf8E7e6b26F407dEE615fc4Db18Bf829E7Aa8C09',
    smartRouterHelper: '0x0000000000000000000000000000000000000000',
    scan: 'https://goerli.basescan.org/tx/',
    claimReward: {
      startBlock: 8538813,
      vestingDuration: 5400,
      vestingReleaseFrequency: 1800,
      vestingStartTime: 1692271221,
      tokenAddress: '0xcf8E7e6b26F407dEE615fc4Db18Bf829E7Aa8C09'
    },
    quack: '0xa6502d582268F05b3bCcE2a15dd44c21b0219340'
  },
  baseMainnet: {
    WNATIVE: '0x4200000000000000000000000000000000000006',
    nativeCurrencyLabel: 'ETH',
    v2Factory: '0x591f122D1df761E616c13d265006fcbf4c6d6551',
    stableFactory: '0x0000000000000000000000000000000000000000',
    stableInfo: '0x0000000000000000000000000000000000000000',
    cake: '0xc2BC7A73613B9bD5F373FE10B55C59a69F4D617B',
    smartRouterHelper: '0x0000000000000000000000000000000000000000',
    scan: 'https://basescan.org/tx/',
    claimReward: {
      startBlock: 2790730,
      vestingDuration: 15552000,
      vestingReleaseFrequency: 2592000,
      vestingStartTime: 1692370822,
      tokenAddress: '0xc2BC7A73613B9bD5F373FE10B55C59a69F4D617B'
    },
    quack: '0x639C0D019C257966C4907bD4E68E3F349bB58109'
  },
} as const
