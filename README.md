### Compile
npx hardhat compile

### Start a local node
npx hardhat node

### Deploy to a local node
npx hardhat run --network localhost dev-scripts/deploy.js

### Deploy to Testnet
npx hardhat run --network rinkeby dev-scripts/deploy.js

### Deploy to Mainnet
npx hardhat run --network ethereum scripts/deploy.js

## setup forge test
install usbmodule
`git submodule add URL`
install submodules
`git submodule update --init`
install cargo
`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh`
run test with specific network
`forge test -f https://rpc.api.moonbase.moonbeam.network -vvv --force`
run specific test
`forge test --match-contract IFOTest`
run gas costs
`forge test --gas-report`

## setup seed data / subgraph
-run yarn install and forge install and whatever else to setup project
-then run yarn dev:seed
--this will start a local hardhat node with seed data from the first 2 and a few other unfinished sceanrios (sceanrio 3 almost finished)

-after start local hardhat node with seed data the logs printed out will give you an rpc address to your hardhat rpc (should look like this: http://127.0.0.1:8545/

-go to subgraph directory and update the docker-compose.yml file "ethereum" environment variable to point to your local hardhat RPC. it should look like this: 'mainnet:http://host.docker.internal:8545'

-subgraph should be connected to local hardhat node and should start reading event data