import Web3 from "web3";

import EthSwap from "./abis/EthSwap.json";
import Token from "./abis/Token.json";

const initialize = async () => {
  if (window.ethereum) {
    window.web3 = new Web3(window.ethereum);
    try {
      // Request account access if needed
      await window.ethereum.enable();
      // Acccounts now exposed
    } catch (error) {
      // User denied account access...
      console.log(error);
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) {
    window.web3 = new Web3(window.web3.currentProvider);
    // Acccounts always exposed
  }
  // Non-dapp browsers...
  else {
    console.log(
      "Non-Ethereum browser detected. You should consider trying MetaMask!"
    );
  }

  const web3 = window.web3;

  const accounts = await web3.eth.getAccounts();

  const account = accounts[0];
  const accountBalance = await web3.eth.getBalance(account);
  const balance = web3.utils.fromWei(accountBalance, "ether");
  //   console.log(accounts, balance);

  const tokenAbi = Token.abi;
  const tokenAddress = Token.networks["5777"].address;

  const token = new web3.eth.Contract(tokenAbi, tokenAddress);

  const ethSwapAbi = EthSwap.abi;
  const ethSwapAddress = EthSwap.networks["5777"].address;

  const ethSwap = new web3.eth.Contract(ethSwapAbi, ethSwapAddress);

  //   console.log(address);
  return { account, balance, token, ethSwap };
};

export default initialize;
