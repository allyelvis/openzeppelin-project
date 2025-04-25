const { ethers } = require("ethers");
const [contractAddress, to, amountOrTokenId] = process.argv.slice(2);
const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);
const abi = [
  "function mint(address to, uint256 amount) public",
  "function safeMint(address to, uint256 tokenId) public",
];
async function main() {
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  try {
    const isNFT = parseInt(amountOrTokenId) < 100000;
    const tx = isNFT
      ? await contract.safeMint(to, amountOrTokenId)
      : await contract.mint(to, amountOrTokenId);
    console.log("Minting... TX Hash:", tx.hash);
    await tx.wait();
    console.log("Minted successfully!");
  } catch (err) {
    console.error("Mint failed:", err);
  }
}
main();
