// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

library StringUtils {
    /**
     * @dev Returns the length of a given string
     *
     * @param s The string to measure the length of
     * @return The length of the input string
     */
    function strlen(string memory s) internal pure returns (uint256) {
        uint256 len;
        uint256 i = 0;
        uint256 bytelength = bytes(s).length;
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }

    function stringToUint(string memory s)
        internal
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 length = strlen(s);
        uint256 i;
        result = 0;
        for (i = 0; i < length; i++) {
            uint c = uint8(b[i]);
            result = result * 10 + (c - 48);
        }
    }

    function isPureNumber(string memory s) 
        internal 
        pure 
        returns (bool) 
    {
        bytes memory b = bytes(s);
        uint256 length = strlen(s);
        uint256 i;
        for (i = 0; i < length; i++) {
            uint c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                continue;
            } else {
                return false;
            }
        }
        return true;
    }
}
