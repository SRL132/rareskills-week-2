# Opensea Events
## Overview
- Events ([link](https://www.rareskills.io/post/ethereum-events))

## How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? 

OpenSea uses events the following way to keep track of which NFTs an Address owns:

**Events** 
Every time a transaction is made or an NFT is minted, an event is thrown to log the relevant data. OpenSea can query such events (which get stored in the receipts) in order to render such data in the front-end for the user to see. The same applies to other interactions, such as listing items/delisting items, etc.

## Explain how you would accomplish this if you were creating an NFT marketplace
I would create events for all relevant interactions, such as: 

1- Listing/Unlisting NFTs
2- NFT transfers
3- Staking NFTs
4- Lending NFTs

I would implement an indexer, such as The Graph to allow the front-end to query the data, and a use a library such as web3.js for direct interaction with the deployed smart contract functions.

