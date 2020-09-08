const Web3 = require("web3");

const web3 = new Web3("http://127.0.0.1:8545");

const address = "0x004ae0E0445FeFe4c3Da4AC092443C46B6CEc54d";

const data = "keshav";

const signature = web3.eth.accounts.sign(
  data,
  "0xc57f9b25ba89215b74e93e4ce85cf2ca0fe39076a1dc261cabb904ce568e313f"
);

console.log(signature);
