module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,        // Le port Ganache GUI
      network_id: "*",   // Accepte toutes les blockchains locales
    },
  },

  contracts_build_directory: "./src/artifacts/",

  compilers: {
    solc: {
      version: "0.8.21",
      optimizer: {
        enabled: false,
        runs: 200
      },
      evmVersion: "byzantium"
    }
  }
};
