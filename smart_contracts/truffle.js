/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */
var HDWalletProvider = require('truffle-hdwallet-provider');
var mnemonic = 'spirit supply whale amount human item harsh scare congress discover talent hamster';
var endpoint = 'https://rinkeby.infura.io/v3/cb2b1d810efb480da18c306da6b9455c'

module.exports = {
    networks: { 
        development: {
            host: '127.0.0.1',
            port: 8545,
            network_id: "*"
        }, 
        rinkeby: {
            provider: function() { 
                return new HDWalletProvider(mnemonic, endpoint) 
            },
            network_id: 4,
            gas: 4500000,
            gasPrice: 10000000000,
        }
    }
};