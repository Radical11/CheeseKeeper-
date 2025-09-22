import { ethers } from "ethers";

// Usage: node scripts/fund-address.js 0xAddress 1.0
// Sends <amount> ETH from Ganache account[0] to 0xAddress

async function main() {
  const [addr, amountEth] = process.argv.slice(2);
  if (!addr || !amountEth) {
    console.error("Usage: node scripts/fund-address.js 0xAddress 1.0");
    process.exit(1);
  }

  const rpc = process.env.RPC_URL || "http://127.0.0.1:8545";
  const provider = new ethers.JsonRpcProvider(rpc);

  // Default Ganache with the mnemonic provided in README has this first private key:
  // For safety, fetch the first unlocked account via provider and use impersonation when possible.
  // But Ganache unlocks accounts by default, so we can just use a well-known private key from the mnemonic.
  // If this ever fails, copy a private key from Ganache output and set PRIVATE_KEY env.

  let wallet;
  if (process.env.PRIVATE_KEY) {
    wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  } else {
    // Private key for account[0] when using the specified mnemonic
    // Mnemonic: candy maple cake sugar pudding cream honey rich smooth crumble sweet treat
    const pk0 = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d";
    wallet = new ethers.Wallet(pk0, provider);
  }

  const to = ethers.getAddress(addr);
  const amountWei = ethers.parseEther(amountEth);

  console.log(`Funding ${to} with ${amountEth} ETH from ${await wallet.getAddress()}`);
  const tx = await wallet.sendTransaction({ to, value: amountWei });
  console.log("Sent, tx hash:", tx.hash);
  const rcpt = await tx.wait();
  console.log("Confirmed in block:", rcpt.blockNumber);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
