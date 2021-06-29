const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
 
module.exports = { 
 networks: {
   development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "5777",       // Any network (default: none)
   },
   rinkeby: {
    // SimpleStorage Rinkeby deployed at: 0xFA870462FeaA51d6f7F3cEa7aB907917dF0b4aC6
    provider: function() {
       return new HDWalletProvider(`${process.env.MNEMONIC}`, `wss://rinkeby.infura.io/ws/v3/${process.env.INFURA_KEY}`)
     },
     network_id: 4
   },
   ropsten: {
    // SimpleStorage Ropsten deployed at: 0xFA0E2856e6cfA63A835dE4DAD29AD32d9DF0Ab7d
    provider: function() {
       return new HDWalletProvider(`${process.env.MNEMONIC}`, `https://ropsten.infura.io/v3/${process.env.INFURA_KEY}`)
     },
     gas: 5500000,
     network_id: 3,
     networkCheckTimeout: 1000000,
     timeoutBlocks: 200
   }
 },
 
 // Set default mocha options here, use special reporters etc.
 mocha: {
   // timeout: 100000
 },
 
 // Configure your compilers
 compilers: {
   solc: {
     version: "^0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
     // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
     settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
       enabled: false,
       runs: 200
       },
     evmVersion: "byzantium"
     }
   },
 }
};
