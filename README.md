# Blockchain-based Decentralized Smart Warranty Application 

## Project overview

In this project, the smart contracts and DApp of decentralized smart warranty application has been created for energy storage supply chain and its warranty management.
The smart contract is to be deployed on the public testnet Rinkeby. 
The blockchain identity to secure digital assets is managed on the Ethereum platform using a smart contract using Solidity.

## Deploy smart contract on Public Test Network (Rinkeby)

# Install it from npm
```
npm install -g truffle-export-abi
```

# Run it in your truffle project
```
truffle-export-abi
```
You will see, ABI extracted and output file wrote to: build/ABI.json, so that you can check the ABI there.


```
truffle migrate --reset --compile-all —-network rinkeby
```

Using network 'rinkeby'.

Running migration: 1_initial_migration.js
  
  Deploying Migrations...

  ... 0x0a3dfc696707b927b58be5E26B771527f0d23617
  
  ...

## Record of Transactions

### contract address
coming soon ...

https://rinkeby.etherscan.io/address/0x0...

### contract hash
coming soon

https://rinkeby.etherscan.io/tx/0x...


## Client Code to interact with Smart Contract

Install following dependencies.

```
npm install --save hapi
```

```
npm install --save inert
```

```
node server.js
```

Access http://localhost:8080 and input necessary information.

