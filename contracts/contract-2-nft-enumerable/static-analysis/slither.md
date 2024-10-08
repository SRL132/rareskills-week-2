## FALSE POSITIVES
Parameter EnumerableNFT.mint(address,uint256)._to (src/EnumerableNFT.sol#39) is not in mixedCase
Parameter EnumerableNFT.mint(address,uint256)._tokenId (src/EnumerableNFT.sol#39) is not in mixedCase
Parameter EnumerableNFT.tokenOfOwnerByIndex(address,uint256)._owner (src/EnumerableNFT.sol#60) is not in mixedCase
Parameter EnumerableNFT.tokenOfOwnerByIndex(address,uint256)._index (src/EnumerableNFT.sol#61) is not in mixedCase
Parameter EnumerableNFT.tokenByIndex(uint256)._index (src/EnumerableNFT.sol#74) is not in mixedCase
Parameter EnumerableNFT.getOwnedTokens(address)._owner (src/EnumerableNFT.sol#87) is not in mixedCase
Variable EnumerableNFT.s_ownedTokens (src/EnumerableNFT.sol#16) is not in mixedCase
Variable EnumerableNFT.s_ownedTokensIndex (src/EnumerableNFT.sol#17) is not in mixedCase
Variable EnumerableNFT.s_allTokens (src/EnumerableNFT.sol#18) is not in mixedCase
Variable EnumerableNFT.s_allTokensIndex (src/EnumerableNFT.sol#19) is not in mixedCase
Parameter NFTInfo.primeBalanceOf(address)._account (src/NFTInfo.sol#25) is not in mixedCase
Variable NFTInfo.i_nft (src/NFTInfo.sol#12) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

INFO:Detectors:
Reentrancy in EnumerableNFT.mint(address,uint256) (src/EnumerableNFT.sol#39-52):
        External calls:
        - _safeMint(_to,_tokenId) (src/EnumerableNFT.sol#47)
                - IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        State variables written after the call(s):
        - s_allTokens.push(_tokenId) (src/EnumerableNFT.sol#49)
        EnumerableNFT.s_allTokens (src/EnumerableNFT.sol#18) can be used in cross function reentrancies:
        - EnumerableNFT.mint(address,uint256) (src/EnumerableNFT.sol#39-52)
        - EnumerableNFT.tokenByIndex(uint256) (src/EnumerableNFT.sol#73-80)
        - EnumerableNFT.totalSupply() (src/EnumerableNFT.sol#31-33)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1