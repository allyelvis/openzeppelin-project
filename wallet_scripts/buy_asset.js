const { ethers } = require("ethers");

const [marketplaceAddress, nftContractAddress, tokenId, price] = process.argv.slice(2);
const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);

const abi = [
  "function buyItem(address nftAddress, uint256 tokenId) external payable"
];

async function main() {
  const contract = new ethers.Contract(marketplaceAddress, abi, wallet);
  try {
    const tx = await contract.buyItem(nftContractAddress, tokenId, {
      value: ethers.parseEther(price)
    });
    console.log("Buying asset... TX Hash:", tx.hash);
    await tx.wait();
    console.log("Asset purchased!");
  } catch (err) {
    console.error("Purchase failed:", err);
  }
}
main();
