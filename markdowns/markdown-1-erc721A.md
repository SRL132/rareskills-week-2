# ERC721A
## Overview
- ERC721A from Azuki ([link](https://www.azuki.com/erc721a))

## How does ERC721A save gas?

ERC721A saves gas in the following situations:

**Minting tokens** 
It allows saving gas when minting multiple tokens in a single transaction. They achieved this by removing redundant storage implemented by ERC721 Enumerable. They also update the balance and owner data in the storage once per mint request instead of every time per minted NFT to save storage write operations.

## Where does it add cost?
It adds cost when: 

**Transfering tokens**
The drawback of these savings in storage operations is that they were there in the first place to make transfers efficient, especially in the sense of checking token ownership and updating it.