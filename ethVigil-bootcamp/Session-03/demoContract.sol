pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;

contract myDemoContract {

    struct ContractInfo {
        uint256 counter;
        string note;
        string contractLicenseId;
    }

    ContractInfo private contractInformation;

    event ContractIncremented(uint8 incrementedValue, address incrementedBy, string newNote);

    constructor(string memory initLicenseid, string memory initNote) public {
        contractInformation.counter = 0;
        contractInformation.note = initNote;
        contractInformation.contractLicenseId = initLicenseid;
    }

    function setContractInformation(uint8 incrValue, string memory _note) public {
        // counter = counter + 1;
        /*
        if (msg.sender == 0xsomeguyidontlike) {
            revert();
        }
        */
        require(keccak256(abi.encodePacked(_note)) != keccak256(abi.encodePacked(contractInformation.note)));
        contractInformation.counter += incrValue;
        contractInformation.note = _note;
        emit ContractIncremented(incrValue, msg.sender, _note);
    }

    function getCounter() public view returns (uint256 counterValue){
        //return counter;
        return contractInformation.counter;
    }

    function getContractInformation() public view returns
    (ContractInfo memory returnedContractInformation) {
        //counterValue = counter;
        //licenseId = contractLicenseId;
        // returnedNote = contractInformation.note;
        //return (counter, contractLicenseId);
        return contractInformation;
    }
}
