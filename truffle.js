const HDWalletProvider = require('@truffle/hdwallet-provider')

const { INFURA_CLIENT_ID, ETHEREUM_ACCOUNT_KEY } = process.env

const getInfuraProvider = network => () =>
  new HDWalletProvider({
    privateKeys: [ETHEREUM_ACCOUNT_KEY],
    providerOrUrl: `https://${network}.infura.io/v3/${INFURA_CLIENT_ID}`,
  })

module.exports = {
  networks: {
    development: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [ETHEREUM_ACCOUNT_KEY],
          providerOrUrl: `http://localhost:8545`,
        }),
      gas: 5000000,
      network_id: 4224, // Match any network id
    },
    polygon: {
      provider: getInfuraProvider('polygon-mainnet'),
      gas: 5000000,
      network_id: 137,
    },
    mumbai: {
      provider: getInfuraProvider('polygon-mumbai'),
      gas: 5000000,
      network_id: 80001,
    },
    rinkeby: {
      provider: getInfuraProvider('rinkeby'),
      gas: 5000000,
      network_id: 4,
    },
    ethereum: {
      network_id: 1,
      provider: getInfuraProvider('mainnet'),
      gas: 5000000,
      gasPrice: 5000000000,
    },
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD',
      gasPrice: 2,
    },
  },
  compilers: {
    solc: {
      version: '^0.8.0',
      settings: {
        optimizer: {
          enabled: true,
          runs: 20, // Optimize for how many times you intend to run the code
        },
      },
    },
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: 'ETHERSCAN_API_KEY_FOR_VERIFICATION',
  },
}
