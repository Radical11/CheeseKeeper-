# Ganache local devnet for CheeseKeeper

This folder contains a minimal setup to run a local Ethereum-like blockchain using Ganache, and a helper script to fund your phone wallets for testing.

Prerequisites (Windows PowerShell)
- Node.js LTS installed (check: node -v, npm -v)

Install Ganache (globally)
- npm i -g ganache

Start Ganache (bind to all interfaces so your phone can reach it)
- ganache --host 0.0.0.0 --port 8545 --chainId 1337 --mnemonic "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat"

Notes
- The mnemonic above is a public test mnemonic used for local development only. It creates deterministic accounts with ETH pre-funded.
- Ganache UI will print the 10 accounts and private keys. The first account will be used by the fund script.

Open Windows Firewall for ports (once, admin PS)
- New-NetFirewallRule -DisplayName "Ganache 8545" -Direction Inbound -Protocol TCP -LocalPort 8545 -Action Allow

Find your laptop IP (to configure the app RPC URL)
- ipconfig  # use the IPv4 Address of your Wi-Fi adapter, e.g., 192.168.1.50
- In the app file lib/core/services/blockchain_service.dart, set rpcUrl = 'http://<YOUR_LAPTOP_IP>:8545'

Fund your phone wallet address (so it can pay gas)
- npm install
- node scripts/fund-address.js 0xYourPhoneAddress 1.0
  - Sends 1.0 ETH (test) from Ganache account[0] to the given address.
  - You can call this multiple times or fund multiple addresses.

Test connectivity from Android
- Ensure your phone is on the same Wi-Fi as your laptop.
- In the app, after setup, go to Send and try a small transfer between two phones.

Troubleshooting
- If Android cannot connect, re-check:
  - Ganache is running with --host 0.0.0.0 and port 8545
  - Laptop IP is reachable from phone (try browsing http://<ip>:8545 and you should see a JSON-RPC error page)
  - Windows Firewall rule is added
