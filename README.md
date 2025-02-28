## NFT marketplace submission

This project uses [foundry](https://github.com/foundry-rs/foundry) and [bulloak](https://github.com/alexfertel/bulloak). The script is configured to use the [first default address](.env) from anvil. 

## Instructions

If you don't have foundry run:
```shell
curl -L https://foundry.paradigm.xyz | bash
```
then run:
```shell
foundryup
```

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Anvil

Before running the script start anvil in a separate terminal, which will spin up a local network.

```shell
anvil
```

### Deploy marketplace and list NFT
The script is using `create2` so the deploy addresses are deterministic and makes the integration into the provided webshop easier.

Note: if you would like to re-run the script you have to restart `anvil`.
```shell
forge script script/DeployAndListNft.s.sol:DeployAndListNft --broadcast --rpc-url 127.0.0.1:8545 -vvvvv
```

### Gas snapshot check
Snapshots can be found in [snapshots](/snapshots/) folder
```shell
FORGE_SNAPSHOT_CHECK=true FOUNDRY_NO_MATCH_TEST=DISABLE forge test --isolate --mt testGas -vvv
```

### Additional info

CI provided for:
- bulloak
- gas check
- linting
- tests