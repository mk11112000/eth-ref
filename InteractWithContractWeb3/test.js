const Web3 = require("web3");
const web3 = new Web3("http://127.0.0.1:7545");
const fs = require("fs");
const privateKey =
  "8ba4ea40aa2a2b3ab7ea34a3e0f72d8aad8242f12d8c0ae320e83fc1f7a8b005";
// const account = web3.eth.accounts.privateKeyToAccount(privateKey);
const address = "0xBce28f125467102526275a1335cBc6CCDD049559";
const toAddress = "0xd7D774019Bd512aAba7A986ec1F7EB010f77E75D";
const abiString = fs.readFileSync("./abis/TokenMinatble.json", "utf8");
const abiJson = JSON.parse(abiString);
const abi = abiJson["abi"];
const contractAddress = abiJson["networks"]["5777"]["address"];

var contract = new web3.eth.Contract(abi, contractAddress);

const methods = contract.methods;

const transfer = methods.transfer(toAddress, 1000).encodeABI();

methods
  .transfer(toAddress, 1000)
  .send({ from: address })
  .then((result) => {
    console.log(result);
  })
  .catch((err) => {
    console.log(err);
  });

methods
  .balanceOf(address)
  .call({ from: address })
  .then((result) => {
    console.log(result);
  })
  .catch((err) => {
    console.log(err);
  });

contract.methods.name().call({ from: address }, (err, res) => {
  console.log(err, res);
});
