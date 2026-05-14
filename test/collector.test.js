const { expect } = require('chai');
const { collectDust } = require('../collector');
const { ethers } = require('ethers');

// Mock Provider
class MockProvider {
    async getBalance(address) {
        if (address === '0x70997970C51812dc3A010C7d01b50e0d17dc79C8') {
            return ethers.parseEther('1.0');
        }
        return 0n;
    }

    async getFeeData() {
        return {
            gasPrice: ethers.parseUnits('10', 'gwei'),
            maxFeePerGas: null,
            maxPriorityFeePerGas: null
        };
    }
}

describe('Collector logic', () => {
    it('should be able to import collectDust', () => {
        expect(collectDust).to.be.a('function');
    });

    it('should handle empty private keys list', async () => {
        const results = await collectDust('http://localhost:8545', [], '0x...');
        expect(results).to.be.an('array').that.is.empty;
    });

    it('should skip wallet with insufficient balance', async () => {
        const mockProvider = new MockProvider();
        // A wallet that will have 0 balance in MockProvider
        const privateKey = ethers.Wallet.createRandom().privateKey;
        const results = await collectDust('http://localhost:8545', [privateKey], '0x...', mockProvider);
        expect(results[0].status).to.equal('skipped');
        expect(results[0].reason).to.equal('Insufficient balance to cover gas');
    });
});
