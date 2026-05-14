# Crypto Dust Collector

The ultimate tool for consolidating small balances ("dust") from multiple wallets into a single destination.

## 🚀 Features

- **Multi-Chain Support**: Ethereum, Polygon, BSC.
- **Native & ERC20 Sweeping**: Automatically detects and sweeps native coins and common stablecoins (USDC, USDT, BUSD).
- **Pro Logic**:
    - **HD Wallets**: Generate or import wallets using BIP39 mnemonics.
    - **Gas Optimization**: Choose between Patient, Normal, and Aggressive gas strategies.
    - **1inch Integration**: Swap dust to stablecoins before sweeping (requires 1inch API key).
    - **NFT Support**: Safety-first NFT sweeping (ERC721).
    - **Security**: Revoke risky allowances with one click.
- **Platforms**:
    - **Node.js CLI**: For power users and automation.
    - **Flutter Mobile App**: For on-the-go management.

## 🛠 Setup (CLI)

1. `cd /app`
2. `npm install`
3. `cp .env.example .env` (Add your RPC URLs and Private Keys)
4. `node index.js`

## 📱 Mobile App (Flutter)

### Prerequisites
- Flutter SDK
- Android Studio / Xcode

### Local Build
1. `cd /app/mobile`
2. `flutter pub get`
3. `flutter run --release`

### Logic Verification
Run the comprehensive test suite:
`flutter test`

## 🛡 Security Note
This tool handles private keys. **Never** share your mnemonic or private keys with anyone. Use at your own risk.
