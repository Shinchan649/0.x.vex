# 0.x.vex - Crypto Dust Collector

A simple tool to collect "dust" (small amounts of crypto) from multiple wallets and send them to a single destination address.

## Features
- Collects remaining balances from multiple EVM-compatible wallets.
- Automatically calculates gas fees to ensure transfers are profitable.
- Supports any EVM-compatible network (Ethereum, Polygon, BSC, etc.).

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment variables:**
   - Copy `.env.example` to `.env`.
   - Add your RPC URL, private keys (comma-separated), and destination address.
   ```bash
   cp .env.example .env
   ```

3. **Run the collector:**
   ```bash
   npm start
   ```

## Usage

Ensure you have enough balance in the source wallets to cover the gas fees for the transfer. The tool will skip wallets where the balance is less than the estimated gas cost.

## Warning

**Never share your private keys.** Keep your `.env` file secure and never commit it to version control.
