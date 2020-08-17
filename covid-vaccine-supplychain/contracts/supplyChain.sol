

/**
 * Created on:  20/04/2020
 * First Update: 07/05/2020
 * Second Update: 09/05/2020
 * @summary: This is a supply chain management smart contract that overcomes the pitfalls of unsecure supply chains
 * @author: Aaryamann Challani
 */
pragma solidity 0.6.7;

contract supplyChain{
    uint32 public loads_sent=0;
    uint32 public loads_received=0;
    address public admin;
    struct Load{
        uint256 vaccine_units;
        string from_address;
        string to_address;
        bool Load_Received;
        string secretPhrase;
        address sender;
        address receiver;
    }
    mapping(uint32=>Load) private load;
    uint32[] private vaccine_loads;
    address[] public distributers;
    address[] public receivers;

/**
 * 
 */
    constructor() public{
        admin=msg.sender;
    }
    modifier onlyAdmin(){
        require(msg.sender==admin,"Only Admin has access to this function");_;
    }

    event load_Sent(
        uint32 load_number,
        uint256 vaccine_units,
        string from,
        string to,
        address Receiver
        );

    event distributer_Set(
        address distributer
        );

    event receiver_Set(
        address receiver);

    event load_Received(
        uint32 load_number
        );


/**
 * 
 * @param  _vaccine_units :  Number of Vaccine Units being loads_sent
 * @param _from_address :  The Address of Origin
 * @param _to_address :  The Address of Destination
 * @param _secretPhrase :  The secret phrase attached to the Load of Vaccine
 * @param _receiver :  Ethereum address of the receiver
 */
    function sendLoad(uint256 _vaccine_units, string memory _from_address, string memory _to_address,string memory _secretPhrase,address _receiver) public
    {
        require(checkDistributer(msg.sender),"Only distributers have access to this function");
        loads_sent++;
        Load storage Vaccine=load[loads_sent];
        Vaccine.vaccine_units=_vaccine_units;
        Vaccine.from_address=_from_address;
        Vaccine.to_address=_to_address;
        Vaccine.secretPhrase=_secretPhrase;
        Vaccine.sender=msg.sender;
        Vaccine.receiver=_receiver;
        vaccine_loads.push(loads_sent);
        emit load_Sent(loads_sent,_vaccine_units,_from_address,_to_address,_receiver);
    }
/**
 * 
 * @param  _load_number :  Load Number of the Vaccine Load
 * @param _secretPhrase :  secret phrase to match with that of the secret phrase of the load
 * @return :
 */
    function confirmLoadReceived(uint32 _load_number,string memory _secretPhrase) public returns(bool)
    {
        require(checkReceiver(msg.sender),"Only receivers have access to this function");
        require(hashCompareWithLengthCheck(_secretPhrase,load[_load_number].secretPhrase),"Incorrect Secret Phrase");
     //   require(keccak256(abi.encodePacked(_secretPhrase))==keccak256(abi.encodePacked(load[_load_number].secretPhrase)),"Incorrect Secret Phrase");
        require(_load_number>0,"Invalid Load Number");
        require(msg.sender==load[_load_number].receiver,"Invalid Receiver");
        load[_load_number].Load_Received=true;
        loads_received++;
        emit load_Received(_load_number);
        return(load[_load_number].Load_Received);

    }
/**
 * 
 * @param  _address :  Ethereum Address of distributer
 */
    function setDistributer(address _address) onlyAdmin() public{
        distributers.push(_address);
        emit distributer_Set(_address);
    }
/**
 * 
 * @param  _address :  Ethereum Address of Receiver
 */
    function setReceiver(address _address) onlyAdmin() public{
        receivers.push(_address);
        emit receiver_Set(_address);
    }
/**
 * 
 * @param  _address : Ethereum Address of distributer
 * @return : true/false depending on the nature of given address
 */
    function checkDistributer(address _address) public view returns(bool){
        bool c=false;
        for(uint32 i=0;i<distributers.length;i++){
            if(_address==distributers[i])
              c=true;
        }
        return(c);
    }
/**
 * 
 * @param  _address :  Ethereum Address of receiver
 * @return : true/false depending on the nature of given address
 */
    function checkReceiver(address _address) public view returns(bool){
        bool c=false;
        for(uint32 i=0;i<receivers.length;i++){
            if(_address==receivers[i])
              c=true;
        }
        return(c);
    }
/**
 * 
 * @param a :  Input Secret phrase
 * @param b :  Secret Phrase attached to load
 * @return :
 */
    function hashCompareWithLengthCheck(string memory a,string memory b) private pure returns(bool){
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
}