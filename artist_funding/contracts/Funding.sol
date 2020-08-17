pragma solidity >=0.4.21 <0.6.0;

/// @author Kevin McFarlane
/// @title Represents funding of an artist.
contract Funding {
    enum Tier { 
        Zero,
        EntryFan, 
        Groupie,
        TheWarningArmy,
        Artists,
        VIPFan,
        UltimateFan
    }
    
    uint constant ENTRY_FAN = 1;
    uint constant GROUPIE = 10;
    uint constant THE_WARNING_ARMY = 25;
    uint constant ARTISTS = 50;
    uint constant VIP_FAN = 100;
    uint constant ULTIMATE_FAN = 200;

    address public owner;
    uint public raised;
    mapping(address => uint) public balances;
    Tier tier;
    event Contributed(address from, uint amount, string tierDescription );

    constructor() public {
        // A sender of the message inside the constructor is a deployer.
        owner = msg.sender;
    }

    function donate() public payable {
        uint amount = msg.value;
        require(isValidDonation(amount), "Donation must match a tier amount.");

        balances[msg.sender] += amount;
        raised += amount;

        if (ENTRY_FAN <= amount && amount < GROUPIE) tier = Tier.EntryFan;
        else if (GROUPIE <= amount && amount < THE_WARNING_ARMY) tier = Tier.Groupie;
        else if (THE_WARNING_ARMY <= amount && amount < ARTISTS) tier = Tier.TheWarningArmy;
        else if (ARTISTS <= amount && amount < VIP_FAN) tier = Tier.Artists;
        else if (VIP_FAN <= amount && amount < ULTIMATE_FAN) tier = Tier.VIPFan;
        else tier = Tier.UltimateFan;

        string memory tierDescription = getTierDescription();

        emit Contributed(msg.sender, amount, tierDescription);
    }

    function isValidDonation(uint amount) private pure returns (bool) {
        return amount >= ENTRY_FAN;
    }

    function getTierDescription() private view returns (string memory) {
        if (tier == Tier.EntryFan) return "Entry Fan";
        if (tier == Tier.Groupie) return "Groupie";
        if (tier == Tier.TheWarningArmy) return "The Warning Army";
        if (tier == Tier.Artists) return "Artists";
        if (tier == Tier.VIPFan) return "VIP Fan";
        if (tier == Tier.UltimateFan) return "Ultimate Fan";
        
        return "";
    }
}
