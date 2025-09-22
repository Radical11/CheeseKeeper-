# CheeseKeeper - Ganache Setup Guide

This guide will help you properly set up and use Ganache with your CheeseKeeper Flutter app.

## Prerequisites

1. **Install Ganache CLI** (recommended for consistency):
   ```bash
   npm install -g ganache-cli
   ```
   
   Or download **Ganache GUI** from [trufflesuite.com](https://trufflesuite.com/ganache/)

## Step 1: Start Ganache

### Option A: Using Ganache CLI (Recommended)
```bash
ganache-cli --host 0.0.0.0 --port 8545 --accounts 10 --deterministic
```

This command:
- `--host 0.0.0.0`: Allows connections from any IP (needed for phone to connect to laptop)
- `--port 8545`: Uses standard Ethereum port
- `--accounts 10`: Creates 10 accounts with 100 ETH each
- `--deterministic`: Uses the same accounts every time (consistent mnemonic)

### Option B: Using Ganache GUI
1. Open Ganache GUI
2. Click "New Workspace"
3. Set:
   - Port: `8545`
   - Network ID: `1337` (default)
   - Host: `0.0.0.0`
4. Click "Save Workspace"

## Step 2: Note Your Ganache Details

When Ganache starts, it will show:
- **Mnemonic**: A 12-word seed phrase
- **Available Accounts**: List of addresses with private keys
- **Network ID**: Usually `1337`
- **RPC Server**: `http://127.0.0.1:8545` or `http://0.0.0.0:8545`

**Example output:**
```
Available Accounts
==================
(0) 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1 (100 ETH)
(1) 0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0 (100 ETH)
...

Private Keys
============
(0) 0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
(1) 0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1
...
```

## Step 3: Configure Your App

### Method 1: Import Ganache Private Key (Recommended)

1. **During Setup**:
   - When your app shows "Choose wallet source"
   - Select "Use Ganache key"
   - Copy the private key from your Ganache console (e.g., the first account)
   - Paste it into the app: `0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d`
   - Click "Import and derive address"

2. **Configure RPC URL**:
   - Go to Profile page in your app
   - Find "RPC URL (Ganache)" section
   - Enter: `http://YOUR_LAPTOP_IP:8545`
   - Click "Save"

### Method 2: Generate New Key (Not Recommended for Testing)
- This creates a random key that won't have ETH in Ganache
- You'd need to manually send ETH from Ganache accounts to your generated address

## Step 4: Find Your Laptop's IP Address

Since your Flutter app might run on a phone/emulator, you need your laptop's IP:

### Windows:
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

### macOS/Linux:
```bash
ifconfig
```
Look for your network interface (usually `en0` or `wlan0`).

**Example**: If your laptop IP is `192.168.1.100`, use:
```
http://192.168.1.100:8545
```

## Step 5: Test the Connection

1. **Check RPC Connection**:
   - In your app, try viewing your balance
   - It should show ~100 ETH if using a Ganache account

2. **Send a Test Transaction**:
   - Try transferring some ETH to another address
   - Check Ganache console for transaction logs

## Troubleshooting

### Problem: "Connection refused" or "Network error"
**Solutions**:
1. Ensure Ganache is running with `--host 0.0.0.0`
2. Check firewall settings (allow port 8545)
3. Verify the IP address is correct
4. Try `http://localhost:8545` if running on the same machine

### Problem: "Insufficient funds"
**Solutions**:
1. Make sure you're using a Ganache private key (not a generated one)
2. Verify the RPC URL is correct
3. Check that Ganache is running and accessible

### Problem: "Invalid private key"
**Solutions**:
1. Ensure the private key is exactly 64 hex characters (without 0x prefix in the app)
2. Copy the full private key from Ganache
3. The app provides the example key for account[0]: `0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d`

### Problem: Transactions not appearing in Ganache
**Solutions**:
1. Double-check the RPC URL in app settings
2. Ensure Ganache is running and accessible
3. Check that the chainId matches (should be 1337 for Ganache)

## Best Practices

1. **Use Deterministic Mode**: Always start Ganache with `--deterministic` for consistent accounts
2. **Document Your Setup**: Note down the mnemonic and account details for future reference
3. **Network Security**: Only use `--host 0.0.0.0` in development environments
4. **Port Conflicts**: If port 8545 is busy, use `--port 8546` and update your app config

## Example Complete Setup

1. **Start Ganache**:
   ```bash
   ganache-cli --host 0.0.0.0 --port 8545 --accounts 10 --deterministic
   ```

2. **Note the details**:
   - Account 0: `0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1`
   - Private Key: `0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d`
   - RPC: `http://192.168.1.100:8545`

3. **Configure app**:
   - Import private key: `4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d`
   - Set RPC URL: `http://192.168.1.100:8545`

4. **Test**: Check balance should show ~100 ETH

Your CheeseKeeper app is already well-configured for Ganache! The issue you're experiencing is likely just a matter of properly configuring the RPC URL and using the correct Ganache private keys.