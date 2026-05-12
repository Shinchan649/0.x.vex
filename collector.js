const { ethers } = require('ethers');

async function collectDust(rpcUrl, privateKeys, destinationAddress, providerOverride = null) {
    const provider = providerOverride || new ethers.JsonRpcProvider(rpcUrl);
    const results = [];

    for (const privateKey of privateKeys) {
        try {
            const wallet = new ethers.Wallet(privateKey.trim(), provider);
            const balance = await provider.getBalance(wallet.address);
            const feeData = await provider.getFeeData();

            // Estimate gas for a simple transfer
            const gasLimit = 21000n;
            const gasPrice = feeData.gasPrice || 0n;
            const gasCost = gasLimit * gasPrice;

            if (balance > gasCost) {
                const amountToSend = balance - gasCost;
                console.log(`Sending ${ethers.formatEther(amountToSend)} ETH from ${wallet.address} to ${destinationAddress}`);

                const tx = await wallet.sendTransaction({
                    to: destinationAddress,
                    value: amountToSend,
                    gasLimit: gasLimit,
                    gasPrice: gasPrice
                });

                await tx.wait();
                results.push({ address: wallet.address, status: 'success', amount: ethers.formatEther(amountToSend), txHash: tx.hash });
            } else {
                results.push({ address: wallet.address, status: 'skipped', reason: 'Insufficient balance to cover gas' });
            }
        } catch (error) {
            results.push({ address: 'unknown', status: 'error', error: error.message });
        }
    }
    return results;
}

module.exports = { collectDust };
