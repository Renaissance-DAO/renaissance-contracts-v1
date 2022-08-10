## Compile
- Run <br/>
`npx hardhat compile`

## Start a local node
- Run <br/>
`npx hardhat node`

## Deploy
- Deploy to a local node<br />
`npx hardhat deploy --tags seed --network hardhat`

- Deploy to a testnet<br />
`npx hardhat deploy --tags seed --network rinkeby`

- Deploy to a testnet<br />
`npx hardhat deploy --tags main --network ethereum`

## Setup forge test
- Install submodule<br />
`git submodule add URL`

- Install submodules<br />
`git submodule update --init`

- Install cargo<br />
`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh`

- Run test with specific network<br />
`forge test -f https://rpc.api.moonbase.moonbeam.network -vvv --force`

- Run specific test<br />
`forge test --match-contract IFOTest`

- Run gas costs<br />
`forge test --gas-report`

## Setup seed data / subgraph
- Run <br/>
`yarn install`

- Run <br/>
`yarn dev:seed` <br/>
(this will start a local hardhat node with seed data)

- after start local hardhat node with seed data the logs printed out will give you an rpc address to your hardhat rpc (should look like this: http://127.0.0.1:8545/

- go to subgraph directory and update the docker-compose.yml file "ethereum" environment variable to point to your local hardhat RPC. it should look like this: 'mainnet:http://host.docker.internal:8545'

- subgraph should be connected to local hardhat node and should start reading event data