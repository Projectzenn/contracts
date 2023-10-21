## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy
forge create ... --rpc-url=https://sepolia-rpc.scroll.io/ --legacy
```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
$ forge script script/GroupToken.s.sol:GroupTokenScript --rpc-url https://sepolia.scroll.io --legacy
forge scr

forge script script/GroupToken.s.sol:GroupTokenScript --rpc-url https://sepolia.scroll.io --broadcast --verify -vvvv
forge script script/GroupToken.s.sol:GroupTokenScript --rpc-url $MUMBAI_RPC_URL  --broadcast --verify -vvvv

```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

```shell
forge create src/ProjectRegistry.sol:ProjectRegistry \\
 --rpc-url https://sepolia-rpc.scroll.io/ \\
--constructor-args "ForgeUSD" "FUSD" 18 1000000000000000000000 \\
--private-key $DEV_PRIVATE_KEY --legacy

forge create src/GroupRegistry.sol:GroupRegistry --rpc-url $MUMBAI_RPC_URL --constructor-args "0x02101dfB77FDE026414827Fdc604ddAF224F0921" "0x2d25602551487c3f3354dd80d76d54383a243358" --private-key $DEV_PRIVATE_KEY --optimizer

forge create src/GroupRegistry.sol:GroupRegistry --rpc-url $MUMBAI_RPC_URL --arguments --private-key $DEV_PRIVATE_KEY --legacy

% forge script script/GroupToken.s.sol:GroupTokenScript --rpc-url $MUMBAI_RPC_URL --etherscan-api-key  $POLYSCAN_API_KEY --broadcast --verify -vvvv  
forge script script/Group.s.sol:Group --rpc-url $MUMBAI_RPC_URL --etherscan-api-key  $POLYSCAN_API_KEY --broadcast --verify -vvvv     
forge script script/ProjectRegistry.s.sol:ProjectRegistryScript --rpc-url $MUMBAI_RPC_URL --etherscan-api-key  $POLYSCAN_API_KEY --broadcast --verify -vvvv     

```
