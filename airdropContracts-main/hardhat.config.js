require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");


/** @type import('hardhat/config').HardhatUserConfig */


module.exports = {
  solidity: "0.8.12",
  networks: {
    hardhat: {
      gas: 2100000,
      gasPrice: 30000000000,
      blockGasLimit: 100000000429720 // whatever you want here
    },
    mumbai: {
      url: "https://polygon-testnet.public.blastapi.io",
      chainId: 80001,
      gas: 3100000,
      gasPrice: 6000000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    'mumbai-mainnet': {
      url: "https://polygon-rpc.com",
      chainId: 137,
      gasPrice: 40000000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    'bsc-test': {
      url: "https://bsctestapi.terminet.io/rpc",
      chainId: 97,
      gasPrice: 20000000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    fuji: {
      url: "https://ava-testnet.public.blastapi.io/ext/bc/C/rpc",
      chainId: 43113,
      gas: 4100000,
      gasPrice: 60000000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    fantom: {
      url: "https://rpc.ankr.com/fantom_testnet",
      gas: 2100000,
      gasPrice: 3000000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: `https://goerli.blockpi.network/v1/rpc/public`,
      gas: 2100000,
      gasPrice: 3000000000,
      chainId: 5,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};