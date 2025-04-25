const { ethers } = require("ethers");
const [contractAddress, address] = process.argv.slice(2);
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const abi = [
  "function balanceOf(address account) view returns (uint256)"
];
async function main() {
  const contract = new ethers.Contract(contractAddress, abi, provider);
  try {
    const balance = await contract.balanceOf(address);
    console.log("Token Balance:", ethers.formatUnits(balance, 18));
  } catch (err) {
    console.error("Failed to get balance:", err);
  }
}
main();
