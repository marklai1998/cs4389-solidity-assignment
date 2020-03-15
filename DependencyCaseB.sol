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

contract C4 is IC4 {
    event Addresses(string given_address, string checksum_address);

    function() external payable {}
    
    function getAddress(address given_address) public returns (string memory) {
        IC3 c3Instance = new C3();
        string memory addressString = c3Instance.address2String(given_address);
        bytes memory addressByte = bytes(addressString);
        bytes memory addressForHashing = new bytes(40);
        for(uint i=0;i<40;i++){
            addressForHashing[i] = bytes(addressByte)[i+2];
        }
        uint hashedInt = uint(keccak256(addressForHashing));
        
        bytes memory checksumAddressBytes = new bytes(42);
        checksumAddressBytes[0] = "0";
        checksumAddressBytes[1] = "x";
        for (uint i = 2; i < 42; i++) {
            bytes1 char = addressForHashing[i-2];
            if(uint8(char) > 96 && ((hashedInt/(2**(4*(65-i))))%16)>7){
                char = byte(uint8(char)-32);
            }
            checksumAddressBytes[i]= char;
        }
        emit Addresses(addressString, string(checksumAddressBytes));
        return string(checksumAddressBytes);
    }
}