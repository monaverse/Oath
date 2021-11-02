const HDWalletProvider = require('@truffle/hdwallet-provider')

const { INFURA_CLIENT_ID, ETHEREUM_ACCOUNT_KEY } = process.env

const getInfuraProvider = network => () =>
  new HDWalletProvider({
    privateKeys: [ETHEREUM_ACCOUNT_KEY],
    providerOrUrl: `https://${network}.infura.io/v3/${INFURA_CLIENT_ID}`,
  })

const from = '0x247C6Efc48DCcdE4Ed92bD11b6aE6c0dDF05B811'

module.exports = {
  networks: {
    development: {
      from,
      provider: () =>
        new HDWalletProvider({
          privateKeys: [ETHEREUM_ACCOUNT_KEY],
          providerOrUrl: `http://localhost:8545`,
        }),
      gas: 5000000,
      network_id: 1337, // Match any network id
    },
    polygon: {
      from,
      provider: getInfuraProvider('polygon-mainnet'),
      gas: 5000000,
      network_id: 137,
    },
    mumbai: {
      from,
      provider: getInfuraProvider('polygon-mumbai'),
      gas: 5000000,
      network_id: 80001,
    },
    rinkeby: {
      from,
      provider: getInfuraProvider('rinkeby'),
      gas: 5000000,
      network_id: 4,
    },
    ethereum: {
      from,
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
