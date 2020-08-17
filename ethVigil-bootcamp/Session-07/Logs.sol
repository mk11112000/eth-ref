pragma solidity ^0.5.0;

contract Logs {
    uint256 logCount;

    struct TransferLog {
        address from;
        address to;
        uint256 amount;
    }

    constructor() public {
        logCount = 0;
    }

    mapping(uint256 => TransferLog) public TransferLogs;

    function addLog(
        address from,
        address to,
        uint256 amount
    ) public {
        TransferLogs[logCount++] = TransferLog(from, to, amount);
    }
}
