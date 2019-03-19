# Blockchain-based Decentralized Smart Warranty Application 

## Project overview

In this project, the smart contracts and DApp of decentralized smart warranty application has been created for energy storage supply chain and its warranty management.
The smart contract is to be deployed on the public testnet Rinkeby. 
The blockchain identity to secure digital assets is managed on the Ethereum platform using a smart contract using Solidity.

## Deploy smart contract on Public Test Network (Rinkeby)

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
0x0a3dfc696707b927b58be5E26B771527f0d23617

https://rinkeby.etherscan.io/address/0x0a3dfc696707b927b58be5e26b771527f0d23617

### contract hash
0xd8e4dfe96d443ac3a0bf0d5acb6e635687dc984f9addefd7f61aa20c060c71ed

https://rinkeby.etherscan.io/tx/0xd8e4dfe96d443ac3a0bf0d5acb6e635687dc984f9addefd7f61aa20c060c71ed

### createStar() Transaction
Test Input: ["name", "story", "dec", "mag", "ra" ]

0xa2e1ccd63d2339fd9028bc8f8c898223a793dbe97fd15de0ecc833b5188c74e5

https://rinkeby.etherscan.io/tx/0xa2e1ccd63d2339fd9028bc8f8c898223a793dbe97fd15de0ecc833b5188c74e5

### putStarUpForSale() Transaction
Test Input: [1 ,2]

0x2b7bb82873c6723efadd94e0f9251792a95afadb71207f5573846ac94f6f1cee

https://rinkeby.etherscan.io/tx/0x2b7bb82873c6723efadd94e0f9251792a95afadb71207f5573846ac94f6f1cee



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

Access http://localhost:8545 and input necessary information.

