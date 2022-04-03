require("@nomiclabs/hardhat-waffle");
require("dotenv").config({path: ".env"});

const ALCHEMY_API_URL = process.env.ALCHEMY_API_KEY_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: ALCHEMY_API_URL,
      accounts: [PRIVATE_KEY]
    }
  }
};
