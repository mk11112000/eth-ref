import React, { Component } from "react";
//Only Implemented for purchasing tokens
class Main extends Component {
  state = {
    ethValue: 0,
    tokenValue: 0,
  };

  render() {
    return (
      <form
        className="card"
        onSubmit={(event) => {
          event.preventDefault();

          let etherAmount = this.state.ethValue.toString();
          etherAmount = window.web3.utils.toWei(etherAmount, "Ether");
          this.props.buyTokens(etherAmount);
          console.log(etherAmount);
        }}
      >
        <h5 className="card-title">Exchange</h5>
        <div className="card-body">
          <div className="card-text">
            <div className="container">
              <h6 className="card-subtitle mb-2 text-muted">
                Balance ETH : {this.props.ethBalance}
              </h6>
            </div>
            <div className="input-group mb-3">
              <input
                aria-label="Amount"
                aria-describedby="basic-addon2"
                className="form-control"
                placeholder="Amount"
                onChange={(event) => {
                  console.log(event.target.value);
                  this.setState({
                    ethValue: event.target.value,
                    tokenValue: event.target.value * 100,
                  });
                }}
                type="number"
                value={this.state.ethValue}
              />
              <div className="input-group-append">
                <span className="input-group-text" id="basic-addon2">
                  ETH
                </span>
              </div>
            </div>
            <div className="container">
              <h6 class="card-subtitle mb-2 text-muted">
                Token Balance : {this.props.tokenBalance}
              </h6>
            </div>
            <div class="input-group mb-3">
              <input
                aria-label="Amount"
                aria-describedby="basic-addon2"
                disabled
                className="form-control"
                placeholder="Amount"
                type="text"
                value={this.state.tokenValue}
              />
              <div className="input-group-append">
                <span className="input-group-text" id="basic-addon2">
                  Tokens
                </span>
              </div>
            </div>
          </div>
          <button
            type="submit"
            className="btn btn-primary"
            onClick={() => {
              console.log(this.state.ethValue);
            }}
          >
            Exchange
          </button>
        </div>
      </form>
    );
  }
}

export default Main;
