import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import { configDotenv } from "dotenv";

configDotenv()

const config: HardhatUserConfig = {
  solidity: "0.8.1",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.InfuraKey}`,
      accounts: [process.env.PrivateKey || ''],
    },
  },
  etherscan: {
    apiKey: process.env.EtherscanApiKey
  }
};

export default config;
