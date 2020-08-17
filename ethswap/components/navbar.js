import React, { Component } from "react";

class Navbar extends Component {
  render() {
    return (
      <nav className="navbar  navbar-expand-lg navbar-dark bg-dark">
        <a className="navbar-brand" href="#">
          ETHSWAP
        </a>

        <div className="navbar-nav  ml-auto">
          <span className="nav-item">
            <a className="nav-link" href="#">
              {this.props.accountAddress}
            </a>
          </span>
        </div>
      </nav>
    );
  }
}

export default Navbar;
