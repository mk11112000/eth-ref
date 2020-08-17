const { ethers } = require("ethers");
const Accounts = require("web3-eth-accounts");

const accounts = new Accounts("http://asasas:8545");

const sign_confirmation = async (data, private_key) => {
  console.log(data);
  let pre_hash = ethers.utils.solidityKeccak256(["string"], [data]);
  let msg_hash = accounts.hashMessage(pre_hash);
  let signingKey = new ethers.utils.SigningKey(private_key);
  let signed_msg = signingKey.signDigest(msg_hash);
  signed_msg = ethers.utils.joinSignature(signed_msg);
  console.log(" message hash   \n", msg_hash);
  console.log("Signed message hash   \n", signed_msg);
};

sign_confirmation({ data }, { private_key });

//Contract with function to verify
// pass in msg_hash and signed_msg to function

// pragma solidity ^0.5.0;

// /**
//  * Based upon ECDSA library from OpenZeppelin Solidity
//  * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/cryptography/ECDSA.sol
//  */

// contract Verification {

//   /**
//    * @dev Recover signer address from a message by using their signature
//    * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
//    * @param signature bytes signature, the signature is generated using web3.eth.sign()
//    */
//   function recover(bytes32 hash, bytes memory signature)
//     public
//     pure
//     returns (address)
//   {
//     bytes32 r;
//     bytes32 s;
//     uint8 v;

//     // Check the signature length
//     if (signature.length != 65) {
//       return (address(0));
//     }

//     // Divide the signature in r, s and v variables
//     // ecrecover takes the signature parameters, and the only way to get them
//     // currently is to use assembly.
//     // solium-disable-next-line security/no-inline-assembly
//     assembly {
//       r := mload(add(signature, 0x20))
//       s := mload(add(signature, 0x40))
//       v := byte(0, mload(add(signature, 0x60)))
//     }

//     // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
//     if (v < 27) {
//       v += 27;
//     }

//     // If the version is correct return the signer address
//     if (v != 27 && v != 28) {
//       return (address(0));
//     } else {
//       // solium-disable-next-line arg-overflow
//       return ecrecover(hash, v, r, s);
//     }
//   }
// }
