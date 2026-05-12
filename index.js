const config = require('./config');
const { collectDust } = require('./collector');

async function main() {
    console.log('Starting Crypto Dust Collector...');

    if (!config.rpcUrl || config.privateKeys.length === 0 || !config.destinationAddress) {
        console.error('Error: Missing configuration. Please check your .env file.');
        process.exit(1);
    }

    try {
        const results = await collectDust(config.rpcUrl, config.privateKeys, config.destinationAddress);
        console.log('\nResults:');
        console.table(results);
    } catch (error) {
        console.error('An error occurred during the collection process:', error.message);
    }
}

main();
