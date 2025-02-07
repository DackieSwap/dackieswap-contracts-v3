# 🦆 DackieSwap Protocol

<div align="center">
  <img src="https://dackieswap.xyz/logo.png" alt="DackieSwap Logo" width="200"/>
  
  [![Twitter Follow](https://img.shields.io/twitter/follow/DackieSwap?style=social)](https://twitter.com/DackieSwap)
  [![Discord](https://img.shields.io/discord/your-discord-server-id?style=flat-square)](http://discord.gg/dackieofficial)
</div>

## 📝 Overview

DackieSwap is The Premier Superchain DEX with AI Agent Technology (DeFAI)., offering advanced trading features including:

- 🔄 Automated Market Making (AMM)
- 💧 Concentrated Liquidity
- 🌾 Yield Farming & Staking
- 🎯 Token Launchpad
- 🔒 Advanced Security Features

## 🏗️ Protocol Architecture

The DackieSwap protocol consists of multiple smart contract projects:

| Project                                                             | Description                                        | Solidity Version |
| ------------------------------------------------------------------- | -------------------------------------------------- | ---------------- |
| [dackie-pad](./projects/dackie-pad/README.md)                       | Token launchpad platform for new project launches  | 0.6.12           |
| [masterchef-v2](./projects/masterchef-v2/README.md)                 | Advanced farming mechanism for liquidity providers | 0.6.12           |
| [v2-contracts](./projects/v2-contracts/README.md)                   | Core AMM contracts for DackieSwap V2               | 0.7.6            |
| [v3-core](./projects/v3-core/README.md)                             | Core concentrated liquidity contracts              | 0.7.6            |
| [v3-lm-pool](./projects/v3-lm-pool/README.md)                       | Liquidity mining implementation for V3             | 0.7.6            |
| [v3-periphery](./projects/v3-periphery/README.md)                   | Peripheral smart contracts for V3                  | 0.7.6            |
| [router](./projects/router/README.md)                               | Smart order routing between pools                  | 0.7.6            |
| [masterchef-v3](./projects/masterchef-v3/README.md)                 | Next generation farming for V3 LPs                 | 0.7.6            |
| [pools](./projects/pools/README.md)                                 | Flexible staking pool implementations              | 0.8.12           |
| [idackie](./projects/idackie/README.md)                             | Governance token contracts                         | 0.8.12           |
| [dackie-token-migrator](./projects/dackie-token-migrator/README.md) | Token migration utility                            | 0.8.25           |



## 🌐 Official Links

- 🦆 [Website](http://dackieswap.xyz)
- 🐦 [Twitter](https://twitter.com/DackieSwap)
- 🎮 [Discord](http://discord.gg/dackieofficial)
- 🎯 [Zealy](http://zealy.io/c/dackieswap)
- 🌟 [Galxe](http://galxe.com/DackieSwap)
- 📚 [Documentation](https://docs.dackieswap.xyz)

---

<div align="center">
  <strong>Built with 🦆 by the Dackie Labs</strong>
</div>

## How to compile

Prepare file `.env` in root directory with your private keys.

Execute:
```
yarn install 

yarn compile
```
