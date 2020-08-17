import React, { Component } from "react";
import "./App.css";
import Navbar from "./components/navbar";
import initialize from "./initialiseWeb3";
import Main from "./components/main";
import Web3 from "web3";
class App extends Component {
  state = {};

  async componentWillMount() {
    const data = await initialize();

    this.setState({
      account: data.account,
      ethBalance: data.balance,
      token: data.token,
      ethSwap: data.ethSwap,
    });

    const tokenBalance = await this.state.token.methods
      .balanceOf(this.state.account)
      .call();

    this.setState({ tokenBalance });

    console.log("state log in App.js componentwillMount");
    console.log(this.state);
  }

  buyTokens = (etherAmount) => {
    this.state.ethSwap.methods
      .buyTokens()
      .send({ value: etherAmount, from: this.state.account })
      .on("transactionHash", (hash) => {
        console.log(hash);
      });
  };

  render() {
    return (
      <div className="App">
        <Navbar accountAddress={this.state.account} />
        <Main
          ethBalance={this.state.ethBalance}
          tokenBalance={this.state.tokenBalance}
          buyTokens={this.buyTokens}
        />
      </div>
    );
  }
}

export default App;
