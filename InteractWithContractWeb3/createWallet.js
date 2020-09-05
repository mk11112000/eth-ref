const Web3 = require("web3");
const web3 = new Web3("http://127.0.0.1:7545");
const fs = require("fs");
const wallet = web3.eth.accounts.wallet.create(1);

const account = wallet["0"];

const encryptedWallet = wallet.encrypt("password");

console.log(account);

fs.writeFileSync("safe.wallet", JSON.stringify(encryptedWallet));
