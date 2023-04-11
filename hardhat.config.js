require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "D5hgUPR9tK2V-WPEUIYxJ42kh-E3So_D";

const GOERLI_PRIVATE_KEY = "da631310b5cb4756b07e5b276af9d6d81c497e369b637f6a85395c9757553cd1";
// const GOERLI_PRIVATE_KEY = "e0756009bbaa408b1a6443a02940f35d63c7d91cc83740d4e94de6d1fb74ad28";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.18",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    networks: {
        goerli: {
            url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
            accounts: [GOERLI_PRIVATE_KEY]
        }
    }
};
