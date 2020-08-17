const config = require("./config.js");
const axios = require("axios").default;
const Accounts = require("web3-eth-accounts");
const accounts = new Accounts("http://asasas:8545");
const ethers = require("ethers");
const WebSocket = require("ws");
const ws = new WebSocket(config.wsUrl);

var wsSessionID, gotEvent;

const erc20Instance = axios.create({
  baseURL: config.apiPrefix + config.ERC20MintableAddress,
  timeout: 10000,
  headers: { "X-API-KEY": config.apiKey },
});

const multiSigInstance = axios.create({
  baseURL: config.apiPrefix + config.multisigContractAddress,
  timeout: 10000,
  headers: { "X-API-KEY": config.apiKey },
});

const approveSignedObject = async (spender, amount, private_key) => {
  console.log("Signing data with spender, amount...", spender, amount);
  let pre_hash = ethers.utils.solidityKeccak256(
    ["address", "uint256"],
    [spender, amount]
  );
  let msg_hash = accounts.hashMessage(pre_hash);
  let signingKey = new ethers.utils.SigningKey(private_key);
  let signed_msg = signingKey.signDigest(msg_hash);
  signed_msg = ethers.utils.joinSignature(signed_msg);
  console.log("Signed message hash", signed_msg);
  return signed_msg;
};

const approveRequestWithSignature = async (spender, amount, private_key) => {
  let constructed_sig_obj = await approveSignedObject(
    spender,
    amount,
    private_key
  );
  const res = await erc20Instance.post("/approveWithSignature", {
    spender: spender,
    amount: amount,
    ownerSignedMessageObject: constructed_sig_obj,
  });

  console.log(res.data);
};

const depositSignedObject = (multiSigContractAddress, amount, private_key) => {
  let pre_hash = ethers.utils.solidityKeccak256(
    ["uint256", "address"],
    [amount, multiSigContractAddress]
  );
  let msg_hash = accounts.hashMessage(pre_hash);
  let signingKey = new ethers.utils.SigningKey(private_key);
  let signed_msg = signingKey.signDigest(msg_hash);
  signed_msg = ethers.utils.joinSignature(signed_msg);
  console.log("Signed message hash", signed_msg);
  return signed_msg;
};

const depositRequestWithSignature = async (
  multiSigContractAddress,
  amount,
  private_key
) => {
  let constructed_sig_obj = depositSignedObject(
    multiSigContractAddress,
    amount,
    private_key
  );
  const res = await multiSigInstance.post("/depositWithSignature", {
    amount: amount,
    signedDepositObject: constructed_sig_obj,
  });
  console.log(res.data);
};
ws.on("open", function open() {
  console.log("ws open");

  setTimeout(heartbeat, 30000);

  ws.send(
    JSON.stringify({
      command: "register",
      key: config.apiKey,
    })
  );
});

ws.on("message", function incoming(data) {
  console.log("message recieved");

  data = JSON.parse(data);

  if (data.command == "register:nack") {
    console.error("Bad apiKey set!");
  } else if (data.command == "register:ack") {
    console.log("recieved data");
  }
  if (data["event_name"] == "Transfer") {
    console.log("Got Transfer data", data);
  }
});

ws.on("close", function close() {
  console.log("ws closed");

  //Websocket will auto disconnect if you do not send heartbeat.
  if (gotEvent) {
    console.log("WS disconnected");
  } else {
    console.error(
      "WS disconnected before we could receive an event - this should not have happened! Reach out to hello@blockvigil.com."
    );
  }
});

function heartbeat() {
  console.log("heartbeat");

  ws.send(
    JSON.stringify({
      command: "heartbeat",
      sessionID: wsSessionID,
    })
  );
}

const private_key =
  "0xA316BEF07E0D702DD155FC11C242A84383190B769472C023D17D9AD54C93D7AA";

approveRequestWithSignature(
  config.multisigContractAddress,
  10000000,
  private_key
);

depositRequestWithSignature(config.multisigContractAddress, 1000, private_key);
