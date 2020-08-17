pragma solidity ^0.5.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";


contract MultiSig is Ownable{

    address[] private parties;
    mapping (address => uint256) deposits;
    uint256 private totalBalance;

    event WithdrawalRequest(uint256 requestId, address requester);
    event WithdrawalConfirmed(uint256 requestId, uint256 amount);
    event ConfirmationSigRecieved(uint indexed uniqueID, address signer);

    mapping(address => uint256) requestId;  // store requestId against requesting address
    mapping(uint256 => uint256) requestedWithdrawals; // map requested withdrawal amounts against request Id
    mapping(uint256 => mapping(address => bool)) requestConfirmations;
    //Map of requestID to a address to a booleanValue to check if a particular address has approved request

    uint256 requestCounter;

    modifier onlyParticipant() {
        bool found = false;
        for (uint i = 0; i < parties.length; i++) {
            if (parties[i] == msg.sender) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert("Message sender not a participant");
        }
        _;

    }

    modifier withDrawalValid(address withdrawingParty, uint256 amount ) {

        require(totalBalance <= amount);
        require(deposits[withdrawingParty] <= amount);
        _;

    }

    constructor(address[] memory participants) public {
        for (uint i=0; i < participants.length; i++) {
            parties.push(participants[i]);
        }
        parties.push(msg.sender);
        requestCounter = 0;

    }

    function addParticipants(address newParticipant) public onlyOwner {
        parties.push(newParticipant);

    }

    function deposit(uint256 amount) public onlyParticipant  {
        deposits[msg.sender] += amount;
        // record balance value in deposits against msg.sender

        totalBalance += amount;
        // and also add the same to totalBalance
    }

    function confirmRequestId(uint256 _requestId) public onlyParticipant {
        requestConfirmations[_requestId][msg.sender] = true;
        uint8 num_confirmations;
        for (uint8 idx=0; idx < parties.length; idx++) {
            if (requestConfirmations[_requestId][parties[idx]]) {
                num_confirmations += 1;
                if (num_confirmations >= parties.length/2) {
                    emit WithdrawalConfirmed(_requestId, requestedWithdrawals[_requestId]);
                    break;
                }
            }
        }
    }

    function confirmRequestWithSig(uint256 _requestId, bytes memory signatureObject) public
    {
        // @dev confirm a requestId by sending a signed message object that acts as an authorized note
        // @param _requestId The request ID to be confirmed
        // @param signatureObject an array of bytes representing the ECDSA signed message object.
        // @notice expectedMessageString = requestId + currentContractAddress | messageHash = keccak256(expectedMessageString) | signatureObject = ECDSA_Sign(messageHash)
        // @notice the expected message is a concatenation of a unique ID and the present contract address of this code

        // construct the expected message object locally
        bytes32 message = prefixed(keccak256(abi.encodePacked(_requestId, address(this))));
        // run the same signing algorithm on the hashed 32-byte message, and recover the public key from the Signed Object
        address signer = recoverSigner(message, signatureObject);
        bool found = false;
        for (uint i = 0; i < parties.length; i++) {
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
        if (isRequestConfirmed(_requestId))
            emit ConfirmationSigRecieved(_requestId, signer);

    }



    function isRequestConfirmed(uint256 _requestId) internal view returns (bool) {
        // count number of confirmations so far

        uint8 num_confirmations;
        for (uint8 idx=0; idx<parties.length; idx++) {
            if (requestConfirmations[_requestId][parties[idx]]) {
                num_confirmations += 1;
                if (num_confirmations >= parties.length/2) {
                    return true;
                }
            }
        }
        return false;
    }

        function getNumberOfRequestConfirmations(uint256 _requestId) public view returns (uint256 numConfirmations) {
            uint numConfirms=0;
            for(uint i=0; i<parties.length; i++ ){
                if(requestConfirmations[_requestId][parties[i]]){
                    numConfirms++;
                }
            }
            return numConfirms;

        }


        function withdraw(uint256 amount) public onlyParticipant withDrawalValid(msg.sender,amount){
        // check against totalBalance whether amount exceeds
        // check whether msg.sender has actually deposited that much amount so far
            requestCounter += 1;
            emit WithdrawalRequest(requestCounter, msg.sender);
    }


    function recoverSigner(bytes32 message, bytes memory sig) internal pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

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

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
