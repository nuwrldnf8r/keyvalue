// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KeyValue {
     
    mapping (bytes32 => string) private _keyval;

    /**@dev
    * Sets value (data) with key
    **/
    function set(string memory key, string memory value) public{
        bytes memory b = bytes(key);
        require(b.length<=32,"Key too large");
        b = bytes(value);
        require(b.length<=64,"Value too large");
         _keyval[getKey(msg.sender,key)] = value;
    }

    /**@dev
    * Allows the owner of the data to get via key only
    **/
    function getKey(string memory key) public view returns (bytes32){
        return getKey(msg.sender,key);
    }

    /**@dev
    * returns a bytes32 key for a given key and owner address
    **/
    function getKey(address owner, string memory key) public pure returns (bytes32){
        return keccak256(abi.encode(owner,key));
    }

    /**@dev
    * returns data for a given key. Will only return correctly for the owner of the data
    **/
    function get(string memory key) public view returns (string memory){
        return _keyval[getKey(msg.sender,key)];
    }

    /**@dev
    * returns data for a given key and the address of the owner of the data
    **/
    function get(address owner, string memory key) public view returns (string memory){
        return _keyval[getKey(owner,key)];
    }

    /**@dev
    * returns data for a bytes32 key - returned by getKey(address owner, string memory key)
    **/
    function get(bytes32 key) public view returns (string memory){
        return _keyval[key];
    }

}
