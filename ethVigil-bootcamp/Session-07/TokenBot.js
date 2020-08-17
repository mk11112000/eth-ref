const axios = require("axios").default;
const WebSocket = require("ws");
const config = require("./config.js");

//Call the script from CLI like this: node tokenBot.js address1 address2
var myArgs = process.argv.slice(2);
const ws = new WebSocket(config.wsUrl);
const from = myArgs[0];
const to = myArgs[1];
const amount = myArgs[2];

// console.log(
//   "sending " + amount + " token() from " + address1 + " to " + address2
// );

if (!from || !to || !amount ) {
  console.error("Please specify complete data to make a Tx");
  process.exit(1)
}

const logsInstance = axios.create({
  baseURL: config.apiPrefix + config.transferLogContractAddress,
  timeout: 5000,
  headers: { "X-API-KEY": config.apiKey },
});
const tokenInstance = axios.create({
  baseURL: config.apiPrefix + config.ERC20MintableAddress,
  timeout: 5000,
  headers: { "X-API-KEY": config.apiKey },
});
var wsSessionID, gotEvent;

/*
	Make the transfer from address 1 to address 2 - complete this code (1)
*/

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
  console.log("message:");

  data = JSON.parse(data);

  if (data.command == "register:nack") {
    console.error("Bad apiKey set!");
  } else if (data.command == "register:ack") {
    console.log("recieving data");
  }
  if (data["event_name"] == "Transfer") {
    console.log("Got Transfer data", data);
    console.log(
      data.event_data.from +
        " sent " +
        data.event_data.value +
        "  EthToken to " +
        data.event_data.to
    );
    logsInstance.post("/addLog", { from: from, to: to, amount: amount })
    .then((response)=>{
        console.log(response.data);
        process.exit(0);
    }).catch((e)=>{
      if(e.response.data){
      		console.error(e.response.data.error);
            }else{
              console.log(e.response);
              
            }            
                  
                  process.exit(0);
    });
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

tokenInstance
  .post("/transferFrom", { from: from, to: to, value: amount })
  .then((n) => {    
    console.log(n["data"]);
  })
.catch((e)=>{
      if(e.response.data){
      		console.error(e.response.data.error);
            }else{
              console.log(e.response);
              
            }            
             process.exit(0);
    });//something like: tokenInstance.post('/<methodname>', inputs)

/*
	Track transfer event - complete this code (2)
	Hint: use the websocket code from Session 3
*/

// //if (data.type == 'event' && data.event_name == '<eventname>')
