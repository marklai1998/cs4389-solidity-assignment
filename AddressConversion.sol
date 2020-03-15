pragma solidity ^0.5.12;

contract C1 {
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
}

contract C2 {
    event Addresses(string given_address, string checksum_address);

    function() external payable {}
    
    function getAddress() public returns (string memory) {
        C1 x = new C1();
        string memory addressString = x.address2String(address(this));
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
            if(char>='a' && ((hashedInt/(16**(42-i)))%16)>=8){
                char = byte(uint8(char)-32);
            }
            checksumAddressBytes[i]= char;
        }
        emit Addresses(addressString, string(checksumAddressBytes));
        return string(checksumAddressBytes);
    }
}
