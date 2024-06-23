
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
NFT.withdrawFunds() (src/NFT.sol#189-191) ignores return value by address(msg.sender).call{value: address(this).balance}() (src/NFT.sol#190)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-low-level-calls
INFO:Detectors:
NFTTest.testGetRoyaltyInfo() (test/NFT.t.sol#260-270) ignores return value by nft.royaltyInfo(MOCK_TOKEN_ID,100) (test/NFT.t.sol#263)
StakingHandlerTest.testOnERC721ReceivedRevertsIfNotNFT() (test/StakingHandler.t.sol#212-220) ignores return value by stakingHandler.onERC721Received(owner,owner,0,0x0) (test/StakingHandler.t.sol#218)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return