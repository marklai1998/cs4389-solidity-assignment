pragma solidity ^0.5.12;

interface IC3 {
    function address2String(address) external pure returns (string memory);
    function pay(uint256, address) external;
}

interface IC5 {
    function address2String(address) external pure returns (string memory);
    function pay(uint256, Rewards) external;
}

interface IC4 {
    // uncomment one of the following two lines
    function getAddress() external returns (string memory);
    // function getAddress(address given_address) external returns (string memory);
}

contract C3 is IC3 {
    function() external payable {}

    function address2String(address inputAddress)
        external
        pure
        returns (string memory)
    {
        bytes memory addressBytes = new bytes(42);
        addressBytes[0] = "0";
        addressBytes[1] = "x";
        uint256 addressInt = uint256(inputAddress);
        for (uint256 i = 2; i < 42; i++) {
            uint256 x = (addressInt / (16**(41 - i))) % 16;
            if (x < 10)
                x += 48; // number ASCII offset
            else x += 87; // alpherbat ASCII offest
            addressBytes[i] = bytes1(uint8(x));
        }
        return string(addressBytes);
    }

    function pay(uint256 x, address y) external {
        IC4 c4Instance = IC4(y);
        string memory addressString = c4Instance.getAddress();
        address convertedAddress = string2Address(addressString);
        address payable payableAddress = address(uint160(convertedAddress));
        payableAddress.transfer(x);
    }

    function string2Address(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
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

contract C4 is IC4 {
    event Addresses(string given_address, string checksum_address);

    function() external payable {}

    function getAddress() public returns (string memory) {
        C3 c3Instance = new C3();
        string memory addressString = c3Instance.address2String(
            address(c3Instance)
        );
        bytes memory addressByte = bytes(addressString);
        bytes memory addressForHashing = new bytes(40);
        for (uint256 i = 0; i < 40; i++) {
            addressForHashing[i] = bytes(addressByte)[i + 2];
        }
        uint256 hashedInt = uint256(keccak256(addressForHashing));

        bytes memory checksumAddressBytes = new bytes(42);
        checksumAddressBytes[0] = "0";
        checksumAddressBytes[1] = "x";
        for (uint256 i = 2; i < 42; i++) {
            bytes1 char = addressForHashing[i - 2];
            if (
                uint8(char) > 96 && ((hashedInt / (2**(4 * (65 - i)))) % 16) > 7
            ) {
                char = bytes1(uint8(char) - 32);
            }
            checksumAddressBytes[i] = char;
        }
        emit Addresses(addressString, string(checksumAddressBytes));
        return string(checksumAddressBytes);
    }
}

contract Rewards {
    mapping(address => uint256) rewards_ledger;
    address[] clients_list;
    uint256 reward_ratio;

    function() external payable {}
    constructor(uint256 r) public {
        reward_ratio = r;
    }

    function earnRewards(address current_client, uint256 spending)
        external
        returns (bool status)
    {
        bool alreadyExist = false;
        for (uint256 i = 0; i < clients_list.length; i++) {
            if (clients_list[i] == current_client) {
                alreadyExist = true;
                break;
            }
        }
        if (alreadyExist) return true;
        clients_list.push(current_client);
        uint256 rewardPt = spending * reward_ratio;
        rewards_ledger[current_client] = rewardPt;
        return false;
    }

    function redeemRewards(address current_client, uint256 points)
        external
        returns (bool status)
    {
        uint256 clientPoint = rewards_ledger[current_client];
        if (clientPoint < points) return false;
        rewards_ledger[current_client] = clientPoint - points;
        msg.sender.transfer(points);
        return true;
    }

    function getRewardRatio() public view returns (uint256) {
        return reward_ratio;
    }
}

contract C5 is IC5 {
    function() external payable {}

    function address2String(address inputAddress)
        external
        pure
        returns (string memory)
    {
        bytes memory addressBytes = new bytes(42);
        addressBytes[0] = "0";
        addressBytes[1] = "x";
        uint256 addressInt = uint256(inputAddress);
        for (uint256 i = 2; i < 42; i++) {
            uint256 x = (addressInt / (16**(41 - i))) % 16;
            if (x < 10)
                x += 48; // number ASCII offset
            else x += 87; // alpherbat ASCII offest
            addressBytes[i] = bytes1(uint8(x));
        }
        return string(addressBytes);
    }

    function pay(uint256 x, Rewards rw) external {
        address(rw).transfer(x);
        rw.earnRewards(address(this), x);
        uint256 ratio = rw.getRewardRatio();
        uint256 points = x - (x * ratio);
        rw.redeemRewards(address(this), points);
    }

    function string2Address(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
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
