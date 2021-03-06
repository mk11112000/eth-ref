pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";



contract MultiSig is Ownable{

    address[] private parties;
    mapping (address => uint256) public balances; //to get balances of a particular address
    uint256 public totalBalance;
    event WithdrawalRequest(uint256 requestId, address requester);
    event WithdrawalConfirmed(uint256 requestId, uint256 amount);
    event ConfirmationSigRecieved(uint indexed uniqueID, address signer);
    event NewDeposit(uint depositAmount, address depositor);

    mapping(address => uint256) requestId;  // store requestId against requesting address
    mapping(uint256 => uint256) requestedWithdrawals; // map requested withdrawal amounts against request Id
    mapping(uint256 => mapping(address => bool)) requestConfirmations;
    mapping(uint256 => bool) requestWithdrawn; // to check if a request has been completed or withdrawn completed
    mapping(uint256 => address) requestID_ToAddress; //map of requestID to request creator's address


    uint256 requestCounter;

    modifier onlyParticipant() {
        bool found = false;
        for (uint i = 0; i<parties.length; i++) {
            if (parties[i] == msg.sender) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert('Message sender not a participant');
        }
        _;
    }


    modifier requestNotComplete(uint _requestId) {
        require(requestWithdrawn[_requestId]==false);
        _;
    }



    modifier withDrawalValid(address withdrawingParty, uint256 amount ){

        require(totalBalance >= amount);
        require(balances[withdrawingParty] >= amount);
        _;

    }



    constructor(address[] memory participants) public {
        for (uint i=0; i<participants.length; i++) {
            parties.push(participants[i]);
        }
        parties.push(msg.sender);
        requestCounter = 0;
    }

    function deposit(uint256 amount) public onlyParticipant  {

        balances[msg.sender] += amount;
        totalBalance += amount;

        emit NewDeposit(amount,msg.sender);


    }

    function confirmRequestId(uint256 _requestId) public onlyParticipant {
        requestConfirmations[_requestId][msg.sender] = true;
        /*
        uint256 total_parties = parties.length;
        uint8 num_confirmations;
        for (uint8 idx=0; idx<total_parties; idx++) {
            if (requestConfirmations[_requestId][parties[idx]]) {
                num_confirmations += 1;
                if (num_confirmations >= total_parties/2) {
                     emit WithdrawalConfirmed(_requestId, requestedWithdrawals[_requestId]);
                    break;
                }
            }
        }
        */
        if (isRequestConfirmed(_requestId)) {
            emit WithdrawalConfirmed(_requestId, requestedWithdrawals[_requestId]);
            return;
        }

    }

     // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function confirmRequestWithSignature(uint256 _requestId, bytes memory signatureObject) requestNotComplete(_requestId)
    public {
        // @dev confirm a requestId by sending a signed message object that acts as an authorized note
        // @param _requestId The request ID to be confirmed
        // @param signatureObject an array of bytes representing the ECDSA signed message object.
        // @notice expectedMessageString = requestId + currentContractAddress | messageHash = keccak256(expectedMessageString) | signatureObject = ECDSA_Sign(messageHash)
        // @notice the expected message is a concatenation of a unique ID and the present contract address of this code
        // construct the expected message object locally

        bytes memory expectedFormat = abi.encodePacked(_requestId, address(this));
        bytes32 message = prefixed(keccak256(expectedFormat));

        // run the same signing algorithm on the hashed 32-byte message, and recover the public key from the Signed Object
        address signer = recoverSigner(message, signatureObject);
        bool found = false;
        for (uint i = 0; i<parties.length; i++) {
            if (parties[i] == signer) {
                found = true;
                break;
            }
        }
        if (!found) {
            // transaction is reverted and does not proceed further
            revert('Message signer not a participant');
        }
        // set request confirmation for the message signer
        requestConfirmations[_requestId][signer] = true;
        if (isRequestConfirmed(_requestId)) {
            emit ConfirmationSigRecieved(_requestId, signer);
            emit WithdrawalConfirmed(_requestId, requestedWithdrawals[_requestId]);
            requestWithdrawn[_requestId] = true;
            totalBalance -= requestedWithdrawals[_requestId];
            balances[requestID_ToAddress[_requestId]] -= requestedWithdrawals[_requestId];
        }
    }

    function withdraw(uint256 amount) public onlyParticipant withDrawalValid(msg.sender,amount){
        requestCounter += 1;
        requestId[msg.sender] = requestCounter;
        requestedWithdrawals[requestCounter] = amount;
        requestID_ToAddress[requestCounter] = msg.sender;
        emit WithdrawalRequest(requestCounter, msg.sender);
    }


    function getRequestConfirmationStatus(uint256 _requestId, address participant)
    public view
    returns (bool)
    {
        return requestConfirmations[_requestId][participant];

    }





    function getRequestConfirmationStatusForAllAddress(uint256 _requestId)
    public view
    returns (address[] memory)
    {
        uint j=0;
        address[] memory allAddressWhoConfirmed;
        for(uint i=0;i<parties.length;i++ ){
            if(requestConfirmations[_requestId][parties[i]]){
                allAddressWhoConfirmed[j++]=parties[i];
            }
        }

    return allAddressWhoConfirmed;


    }





    function recoverSigner(bytes32 message, bytes memory sig) internal pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        // returns you the public key (in this case, public Ethereum address) with which the message object was signed
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    // uint256 represents 256-bit unsigned integers. uint8 represents 8-bit unsigned integer.
    returns (uint8, bytes32, bytes32)
    {
        // a total ECDSA signed object is 65-bytes long
        require(sig.length == 65);

        bytes32 r; // 32 bytes
        bytes32 s;  // 32 bytes
        uint8 v; // 1 byte (8 bit)



        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function isRequestConfirmed(uint256 _requestId) internal view returns (bool) {
        // count number of confirmations so far
        uint256 total_parties = parties.length;
        uint8 num_confirmations;
        for (uint8 idx=0; idx<total_parties; idx++) {
            if (requestConfirmations[_requestId][parties[idx]]) {
                num_confirmations += 1;
                if (num_confirmations >= total_parties/2) {
                    return true;
                }
            }
        }
        return false;
    }




}
