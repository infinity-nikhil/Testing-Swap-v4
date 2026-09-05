## Read commit by commit for better unnderstanding

Yo guys so i know the dex aggregator is still complete but i am learning something new in btwn...so here what we are going to do is test a swap contract on uniswap.....

### So Here are the steps what we are going to do 
[ ] Install/compile Miniswap
        ↓
[ ] Get Sepolia ETH
        ↓
[ ] Deploy TokenA
        ↓
[ ] Deploy TokenB
        ↓
[ ] Create PoolKey
        ↓
[ ] Initialize pool through PoolManager
        ↓
[ ] Add liquidity through PoolModifyLiquidityTest
        ↓
[ ] Test swap through PoolSwapTest
        ↓
[ ] Deploy Miniswap
        ↓
[ ] approve(TokenA, Miniswap)
        ↓
[ ] Miniswap.swap(...)
        ↓
[ ] TokenB arrives in your wallet
        ↓
[ ] Test Slippage()
        ↓
[ ] Test Expired()
        ↓
[ ] Test NotPoolManager()

These are the steps in this we are going to deploy 2 tokens MTK and MPK:
In src you can see the script and the script file contains the test file, when you run with a command like:

forge script script/DeployToken.s.sol:DeployToken \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --private-key $PRIVATE_KEY \
  --broadcast

Then the token will be minted to the owner of the pvt key of the wallet 
run it twice and there you go you have 2 token on to you wallet. 
