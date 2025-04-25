const { ethers } = require("ethers");
const [contractAddress, from, amountOrTokenId] = process.argv.slice(2);
const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);
const abi = [
  "function burn(uint256 amount) public",
  "function burn(uint256 tokenId) public",
];
async function main() {
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  try {
    const tx = await contract.burn(amountOrTokenId);
    console.log("Burning... TX Hash:", tx.hash);
    await tx.wait();
    console.log("Burned successfully!");
  } catch (err) {
    console.error("Burn failed:", err);
  }
}
main();
