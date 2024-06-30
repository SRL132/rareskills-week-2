
INFO:Detectors:
StakingHandlerTest.testCanReceiveNFT() (test/StakingHandler.t.sol#48-54) uses arbitrary from in transferFrom: nft.transferFrom(user,address(stakingHandler),0) (test/StakingHandler.t.sol#51)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#arbitrary-from-in-transferfrom

INFO:Detectors:
IRewardToken (src/interfaces/IRewardToken.sol#4-8) has incorrect ERC20 function interface:IRewardToken.transfer(address,uint256) (src/interfaces/IRewardToken.sol#7)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-erc20-interface
INFO:Detectors:
Reentrancy in StakingHandler._updateRewards(bool) (src/StakingHandler.sol#206-232):
        External calls:
        - IRewardToken(i_rewardToken).mint(address(this),rewardToMint) (src/StakingHandler.sol#230)
        State variables written after the call(s):
        - s_lastRewardBlock = block.number (src/StakingHandler.sol#231)
        StakingHandler.s_lastRewardBlock (src/StakingHandler.sol#31) can be used in cross function reentrancies:
        - StakingHandler._updateRewards(bool) (src/StakingHandler.sol#206-232)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1
INFO:Detectors:

## Useful addition
NFT.withdrawFunds() (src/NFT.sol#189-191) ignores return value by address(msg.sender).call{value: address(this).balance}() (src/NFT.sol#190)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-low-level-calls
INFO:Detectors:
NFTTest.testGetRoyaltyInfo() (test/NFT.t.sol#260-270) ignores return value by nft.royaltyInfo(MOCK_TOKEN_ID,100) (test/NFT.t.sol#263)
StakingHandlerTest.testOnERC721ReceivedRevertsIfNotNFT() (test/StakingHandler.t.sol#212-220) ignores return value by stakingHandler.onERC721Received(owner,owner,0,0x0) (test/StakingHandler.t.sol#218)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return



## REVISING



INFO:Detectors:
Low level call in NFT.withdrawFunds() (src/NFT.sol#189-195):
        - (success) = address(msg.sender).call{value: address(this).balance}() (src/NFT.sol#190-192)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

INFO:Detectors:
RewardToken (src/RewardToken.sol#10-49) should inherit from IRewardToken (src/interfaces/IRewardToken.sol#4-8)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-inheritance

## FALSE POSITIVES
INFO:Detectors:
Parameter NFT.setStakingHandler(address)._stakingHandler (src/NFT.sol#104) is not in mixedCase
Parameter NFT.buy(uint256)._tokenId (src/NFT.sol#112) is not in mixedCase
Parameter NFT.buyWithDiscount(uint256,uint256,bytes32[])._tokenId (src/NFT.sol#125) is not in mixedCase
Parameter NFT.buyWithDiscount(uint256,uint256,bytes32[])._index (src/NFT.sol#126) is not in mixedCase
Parameter NFT.buyWithDiscount(uint256,uint256,bytes32[])._proof (src/NFT.sol#127) is not in mixedCase
Parameter NFT.buyAndStake(uint256)._tokenId (src/NFT.sol#150) is not in mixedCase
Parameter NFT.buyWithDiscountAndStake(uint256,uint256,bytes32[])._tokenId (src/NFT.sol#164) is not in mixedCase
Parameter NFT.buyWithDiscountAndStake(uint256,uint256,bytes32[])._index (src/NFT.sol#165) is not in mixedCase
Parameter NFT.buyWithDiscountAndStake(uint256,uint256,bytes32[])._proof (src/NFT.sol#166) is not in mixedCase
Parameter NFT.supportsInterface(bytes4)._interfaceId (src/NFT.sol#201) is not in mixedCase
Parameter NFT.isClaimed(uint256)._index (src/NFT.sol#209) is not in mixedCase
Variable NFT.i_merkleRoot (src/NFT.sol#32) is not in mixedCase
Variable NFT.s_claimedBitMap (src/NFT.sol#35) is not in mixedCase
Variable NFT.s_stakingHandler (src/NFT.sol#51) is not in mixedCase
Parameter RewardToken.mint(address,uint256)._to (src/RewardToken.sol#27) is not in mixedCase
Parameter RewardToken.mint(address,uint256)._amount (src/RewardToken.sol#27) is not in mixedCase
Parameter RewardToken.setStakingHandler(address)._stakingHandler (src/RewardToken.sol#37) is not in mixedCase
Variable RewardToken.i_owner (src/RewardToken.sol#14) is not in mixedCase
Variable RewardToken.s_stakingHandler (src/RewardToken.sol#15) is not in mixedCase
Parameter StakingHandler.onERC721Received(address,address,uint256,bytes)._operator (src/StakingHandler.sol#86) is not in mixedCase
Parameter StakingHandler.onERC721Received(address,address,uint256,bytes)._tokenId (src/StakingHandler.sol#88) is not in mixedCase
Parameter StakingHandler.withdrawNFT(uint256)._tokenId (src/StakingHandler.sol#135) is not in mixedCase
Parameter StakingHandler.getStakedTokens(address)._user (src/StakingHandler.sol#197) is not in mixedCase
Variable StakingHandler.i_nft (src/StakingHandler.sol#22) is not in mixedCase
Variable StakingHandler.i_rewardToken (src/StakingHandler.sol#23) is not in mixedCase
Variable StakingHandler.s_lastRewardBlock (src/StakingHandler.sol#31) is not in mixedCase
Variable StakingHandler.s_accRewardPerToken (src/StakingHandler.sol#32) is not in mixedCase
Variable StakingHandler.s_userToStakedTokens (src/StakingHandler.sol#36) is not in mixedCase
Variable StakingHandler.s_allStakedTokensIndex (src/StakingHandler.sol#38) is not in mixedCase
Variable StakingHandler.s_allStakedTokens (src/StakingHandler.sol#40) is not in mixedCase
Variable StakingHandler.s_ownedStakedTokensIndex (src/StakingHandler.sol#42) is not in mixedCase
Variable StakingHandler.s_userToAccumulatedRewardDebt (src/StakingHandler.sol#44) is not in mixedCase
Variable StakingHandler.s_tokenToStaker (src/StakingHandler.sol#46) is not in mixedCase

INFO:Detectors:
NFT.setStakingHandler(address)._stakingHandler (src/NFT.sol#104) lacks a zero-check on :
                - s_stakingHandler = _stakingHandler (src/NFT.sol#105)
RewardToken.setStakingHandler(address)._stakingHandler (src/RewardToken.sol#37) lacks a zero-check on :
                - s_stakingHandler = _stakingHandler (src/RewardToken.sol#41)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

INFO:Detectors:
Reentrancy in StakingHandler.onERC721Received(address,address,uint256,bytes) (src/StakingHandler.sol#85-111):
        External calls:
        - _updateRewards(true) (src/StakingHandler.sol#95)
                - IRewardToken(i_rewardToken).mint(address(this),rewardToMint) (src/StakingHandler.sol#230)
        State variables written after the call(s):
        - s_allStakedTokens.push(_tokenId) (src/StakingHandler.sol#102)
        - s_allStakedTokensIndex[_tokenId] = s_allStakedTokens.length (src/StakingHandler.sol#101)
        - s_ownedStakedTokensIndex[_tokenId] = s_userToStakedTokens[_operator].length - 1 (src/StakingHandler.sol#103-105)
        - s_tokenToStaker[_tokenId] = _operator (src/StakingHandler.sol#97)
        - s_userToAccumulatedRewardDebt[_operator] += s_accRewardPerToken (src/StakingHandler.sol#107)
        - s_userToStakedTokens[_operator].push(_tokenId) (src/StakingHandler.sol#99)
  
  INFO:Detectors:
Reentrancy in NFT.buy(uint256) (src/NFT.sol#111-117):
        External calls:
        - _safeMint(msg.sender,_tokenId) (src/NFT.sol#114)
                - IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        Event emitted after the call(s):
        - Bought(msg.sender,_tokenId,msg.value) (src/NFT.sol#116)
Reentrancy in NFT.buyAndStake(uint256) (src/NFT.sol#149-156):
        External calls:
        - _safeTransfer(address(this),address(s_stakingHandler),_tokenId) (src/NFT.sol#153)
                - IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        Event emitted after the call(s):
        - BoughtAndStaked(msg.sender,_tokenId,msg.value) (src/NFT.sol#155)
Reentrancy in NFT.buyWithDiscount(uint256,uint256,bytes32[]) (src/NFT.sol#124-144):
        External calls:
        - _safeMint(msg.sender,_tokenId) (src/NFT.sol#142)
                - IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        Event emitted after the call(s):
        - BoughtWithDiscount(msg.sender,_tokenId,msg.value) (src/NFT.sol#143)
Reentrancy in NFT.buyWithDiscountAndStake(uint256,uint256,bytes32[]) (src/NFT.sol#163-185):
        External calls:
        - _safeTransfer(address(this),address(s_stakingHandler),_tokenId) (src/NFT.sol#182)
                - IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        Event emitted after the call(s):
        - BoughtAndStaked(msg.sender,_tokenId,msg.value) (src/NFT.sol#184)
