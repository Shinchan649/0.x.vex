require('dotenv').config();

module.exports = {
    rpcUrl: process.env.RPC_URL,
    privateKeys: process.env.PRIVATE_KEYS ? process.env.PRIVATE_KEYS.split(',') : [],
    destinationAddress: process.env.DESTINATION_ADDRESS,
};
