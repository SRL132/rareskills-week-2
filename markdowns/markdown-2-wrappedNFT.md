# Wrapped NFTs
## Overview
- Wrapped NFT from OZ ([link](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Wrapper.sol))
- Wrapped Penguin Story ([link](https://www.coindesk.com/business/2022/01/07/pudgy-penguins-nft-project-ousts-founders-as-mood-turns-icy/))

## Besides the examples listed in the code and the reading, what might the wrapped NFT pattern be used for?

Wrapped NFT can be used in the following situations:

**Bridging tokens** 
Imagine you have an NFT in Sepolia, but you also want to operate with it in Mumbai. Thye are different networks, so to operate there you have to use a wrap that represents that NFT.

**Extending token functionality** 
You can wrap an NFT as a base, but extend some extra functionality in that wrapped token, per example allow an NFT to be rented via the wrapped NFT even if the original NFT did not have that functionality.
