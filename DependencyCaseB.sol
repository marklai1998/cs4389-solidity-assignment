pragma solidity ^0.5.12;

interface IC3 {
    function address2String(address) external pure returns(string memory);
    function pay (uint , address) external;
}

interface IC4 {
    // uncomment one of the following two lines
    // function getAddress() external returns (string memory);
    function getAddress(address given_address) external returns (string memory);
} 


contract C3 is IC3 {
    function() external payable{}
    
    function address2String(address inputAddress) pure external returns (string memory) {
        bytes memory addressBytes = new bytes(42);
        addressBytes[0] = "0";
        addressBytes[1] = "x";
        uint addressInt = uint(inputAddress);
        for (uint i = 2; i < 42; i++) {
            uint x = (addressInt / (16**(41 - i))) %16;
            if (x<10) x+=48; // number ASCII offset
            else x+=87; // alpherbat ASCII offest
            addressBytes[i] = byte(uint8(x));
        }
        return string(addressBytes);
    }
    
    function pay(uint x, address y) external {
        IC4 c4Instance = IC4(y);
        string memory addressString = c4Instance.getAddress(address(this));
        address convertedAddress = string2Address(addressString);
        address payable payableAddress= address(uint160(convertedAddress));
        payableAddress.transfer(x);
    }
    
     function string2Address(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}

contract Rewards {
    mapping (address=>uint) rewards_ledger;
    address[] clients_list;
    uint reward_ratio;
    
    constructor(uint r) public { reward_ratio = r; }
    
    function earnRewards(address current_client, uint spending) external returns (bool status) {
        bool alreadyExist = false;
        for(uint i = 0; i < clients_list.length; i++){
            if(clients_list[i] == current_client){
                alreadyExist = true;
            }
        }
        if(alreadyExist) return true;
        clients_list[clients_list.length] = current_client;
        uint rewardPt = spending * reward_ratio;
        rewards_ledger[current_client] = rewardPt;
        return false;
    }
    
    function redeemRewards(address current_client, uint points) external returns (bool status) {
        uint clientPoint = rewards_ledger[current_client];
        if(clientPoint < points) return false;
        rewards_ledger[current_client] = clientPoint - points;
        msg.sender.transfer(points);
        return true;
    }
    
    function getRewardRatio() public view returns (uint) { return reward_ratio; }
}
