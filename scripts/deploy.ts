import { formatEther, parseEther } from "viem";
import hre from "hardhat";
import { configDotenv } from "dotenv";

configDotenv()
async function main() {
  const erc721Contract = await hre.viem.deployContract("ERC721Royalties", [process.env.ContractName, process.env.ContractSymbol, process.env.BaseURI, process.env.NotRevealedURI]);

  console.log(`ERC721 contract deployed to ${erc721Contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
