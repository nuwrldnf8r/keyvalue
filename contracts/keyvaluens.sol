// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IKeyValue{
    function set(string memory key, string memory value) external;
    function set(bytes32 key, string memory value) external;
    function get(string memory key) external view returns (string memory);
    function get(bytes32 key) external view returns (string memory);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract KeyValueNS is ERC721Enumerable, Ownable{
    address _keyValueContract;
    string _baseUri;
    uint256 _price;
    address _paymentToken;
    address _paymentAddress;

    constructor(address keyValueContract, address paymentToken, address paymentAddress, uint256 price) ERC721("Key-Value Ownership Token","KVOT"){
        _keyValueContract = keyValueContract;
        _price = price;
        _paymentToken = paymentToken;
        _paymentAddress = paymentAddress;
    }

    function setPrice(uint256 price) public onlyOwner(){
        _price = price;
    }

    function createPrice() public view returns (uint256){
        return _price;
    }

    function setBaseUri(string memory baseUri) public onlyOwner{
        _baseUri = baseUri;
    }

    function tokenId(string memory key) public pure returns(uint256){
        return uint256(keccak256(abi.encode(key)));
    }

    function tokenId(bytes32 key) public pure returns(uint256){
        return uint256(keccak256(abi.encode(key)));
    }

    function create(string calldata key, string calldata value) public { //later make this payable
        create(key,value,"",_msgSender());
    }

    function create(bytes32 key, string calldata value) public { //later make this payable
        create(key,value,"",_msgSender());
    }

    function create(string calldata key, string calldata value, address assignTo) public { //later make this payable
        create(key,value,"",assignTo);
    }

    function create(bytes32 key, string calldata value, address assignTo) public { //later make this payable
        create(key,value,"",assignTo);
    }

    function create(string calldata key, string calldata value,string memory CID, address assignTo) public {
        uint256 _tokenId = tokenId(key);
        require(!_exists(_tokenId),"Key already exists");
        if(_price>0) _doPayment();
        if(bytes(CID).length>0) _setTokenCID(_tokenId,CID);
        _mint(assignTo,_tokenId);
        IKeyValue kv = IKeyValue(_keyValueContract);
        kv.set(key,value);
    }

    function create(bytes32 key, string calldata value, string memory CID, address assignTo) public {
        uint256 _tokenId = tokenId(key);
        require(!_exists(_tokenId),"Key already exists");
        if(_price>0) _doPayment();
        bytes memory b = bytes(CID);
        if(b.length>0) _setTokenCID(_tokenId,CID);
        _mint(assignTo,_tokenId);
        IKeyValue kv = IKeyValue(_keyValueContract);
        kv.set(key,value);
    }

    function set(string calldata key, string calldata value) public {
        uint256 _tokenId = tokenId(key);
        if(!_exists(_tokenId)) return create(key,value);
        require(ownerOf(_tokenId)==_msgSender(),"Not authorised to set this key");
        //do payment
        IKeyValue kv = IKeyValue(_keyValueContract);
        kv.set(key,value);
    }

    function set(bytes32 key, string calldata value) public {
        uint256 _tokenId = tokenId(key);
        if(!_exists(_tokenId)) return create(key,value);
        require(ownerOf(_tokenId)==_msgSender(),"Not authorised to set this key");
        //do payment
        IKeyValue kv = IKeyValue(_keyValueContract);
        kv.set(key,value);
    }

    function get(string calldata key) public view returns (string memory){
        IKeyValue kv = IKeyValue(_keyValueContract);
        return kv.get(key);
    }

    function get(bytes32 key) public view returns (string memory){
        IKeyValue kv = IKeyValue(_keyValueContract);
        return kv.get(key);
    }

    function ownerOf(string memory key) public view returns (address){
        uint256 _tokenId = tokenId(key);
        if(!_exists(_tokenId)) return address(0);
        return ownerOf(_tokenId);
    }

    function ownerOf(bytes32 key) public view returns (address){
        uint256 _tokenId = tokenId(key);
        if(!_exists(_tokenId)) return address(0);
        return ownerOf(_tokenId);
    }

    function testReturnHash(string memory key) public pure returns (bytes32){
        return keccak256(abi.encode(key));
    }

    function _setTokenCID(uint256 tokenID, string memory CID) private {
        string memory prefix = "tid_cid";
        bytes32 key = keccak256(abi.encode(prefix,tokenID));
        IKeyValue kv = IKeyValue(_keyValueContract);
        kv.set(key,CID);
    }

    function _doPayment() private {
        if(_msgSender()==owner()) return;
        IERC20 stable = IERC20(_paymentToken);
        require(stable.allowance(_msgSender(),address(this))>=_price,"Insufficient allowance");
        stable.transferFrom(_msgSender(),_paymentAddress,_price);
    }

}
