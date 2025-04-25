const { ethers } = require("ethers");

const [marketplaceAddress, nftContractAddress, tokenId, price] = process.argv.slice(2);
const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);

// Replace with actual marketplace ABI
const marketplaceAbi = [
  "function listItem(address nftAddress, uint256 tokenId, uint256 price) external"
];

async function main() {
  const contract = new ethers.Contract(marketplaceAddress, marketplaceAbi, wallet);
  try {
    const priceInWei = ethers.parseEther(price);
    const tx = await contract.listItem(nftContractAddress, tokenId, priceInWei);
    console.log("Listing asset... TX Hash:", tx.hash);
    await tx.wait();
    console.log("Asset listed!");
  } catch (err) {
    console.error("Listing failed:", err);
  }
}
main();
