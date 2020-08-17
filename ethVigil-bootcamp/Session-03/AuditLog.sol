pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;


contract myAuditLog {
    address[] public whiteList;

    /*
    modifier onlyWhiteListed (address _to_be_checked_address) {
        uint i = 0;
        for (i = 0 ; i < whiteList.length; i++) {
            if (whiteList[i] == _to_be_checked_address) {
                break;
            }
        }
        if (i == whiteList.length - 1) {
            revert();
        }
        _;
    }
    */

    struct AuditLog {
        string note;
        uint256 incrementedValue;
        uint256 timestamp;
    }

    mapping(address => AuditLog[]) public storedAuditLogs;


    constructor() public {

    }
    /*
    function addToWhitelist(address _allowedAddr) public {
        uint i = 0;
        for (i = 0 ; i < whiteList.length; i++) {
            if (whiteList[i] == _allowedAddr) {
                revert();
            }
        }
        whiteList.push(_allowedAddr);
    }
    */

    function addAuditLog(string memory _newNote, address _changedBy, uint256 _incrementValue, uint256 _timestamp)
    public {
        // logic
        AuditLog memory _a;
        _a.note = _newNote;
        _a.incrementedValue = _incrementValue;
        _a.timestamp = _timestamp;
        storedAuditLogs[_changedBy].push(_a);
    }

    function getLogsBySender(address _sender) public view returns (AuditLog[] memory logs) {

        return storedAuditLogs[_sender];

    }

}
