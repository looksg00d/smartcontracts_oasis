require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomicfoundation/hardhat-ethers");
require("hardhat-gas-reporter");
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.12",
      },
      {
        version: "0.8.0",
      }
    ],
  },
  networks: {
    sapphire_testnet: {
      url: "https://testnet.sapphire.oasis.dev",
      chainId: 23295,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};