const { ethers } = require("ethers");
const [contractAddress, ownerAddress] = process.argv.slice(2);
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const abi = [
  "function balanceOf(address owner) view returns (uint256)",
  "function tokenOfOwnerByIndex(address owner, uint256 index) view returns (uint256)"
];
async function main() {
  const contract = new ethers.Contract(contractAddress, abi, provider);
  const balance = await contract.balanceOf(ownerAddress);
  console.log(\`\${ownerAddress} owns \${balance.toString()} NFT(s)\`);
  for (let i = 0; i < balance; i++) {
    const tokenId = await contract.tokenOfOwnerByIndex(ownerAddress, i);
    console.log(\`Token #\${tokenId}\`);
  }
}
main();
