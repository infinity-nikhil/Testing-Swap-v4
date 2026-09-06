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

### Ok now folks since we have created out token now it's time to create a pool for them 
by the command 

forge script script/InitializePool.s.sol:InitializePool \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --private-key $PRIVATE_KEY \
  --broadcast

By the script file we litterly said that "Hey Uniswap's existing PoolManager on Sepolia, initialize a pool with this configuration."

The flow 

Your wallet
    │
    │ transaction
    ▼
Your InitializePool script
    │
    │ calls initialize(...)
    ▼
Uniswap v4 PoolManager
    │
    │ creates/records the pool
    ▼
MPK / MTK pool initialized

But here's the important part 🚨

The pool currently has no liquidity.
If it has no liquidity then what the fahhh did we did just rn ????

we have just initalized the pool, the pool manager now has a pool as 
MPK
MTK
fee = 3000
tickSpacing = 60
hooks = address(0)
### Nobody can meaningfully swap MPK ↔ MTK yet because we haven't put MPK and MTK into the pool.

## That's our next step: adding liquidity.
But before we begin if you have done everything correctly till now you might think ok we initialized the pool it might not have the liquidity for now but where is the address of our pool ?? the pool key isn't it supposed to be an address ?? Through which we point in the pool manager saying that look mf this is my pool. 

That's where the catch is in v4 we don't have particular address for a particular pool. There is a single pool i.e. pool manager that has an address inside that every pool lives with or without liquiduty. 

Then if not the address then what is the pool key ??

--->it potenially looks something like: 
PoolKey({
    currency0: MPK,
    currency1: MTK,
    fee: 3000,
    tickSpacing: 60,
    hooks: address(0)
});

### Now on to the topic i.e. adding liquidity 
So, i have am done being researching about the adding liquidity feature and tbh it is complex 
It's like things are happening but don't know how ??
You will also have to take some good amount of time learning the inital concepts .... for know you can read the code base and try to understand whatever i have wrote .........