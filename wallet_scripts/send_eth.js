const { ethers } = require("ethers");
const [from, to, amount] = process.argv.slice(2);
const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);
async function main() {
  try {
    const tx = await wallet.sendTransaction({
      to,
      value: ethers.parseEther(amount)
    });
    console.log("Sending ETH... TX Hash:", tx.hash);
    await tx.wait();
    console.log("Payment sent successfully!");
  } catch (err) {
    console.error("Payment failed:", err);
  }
}
main();
