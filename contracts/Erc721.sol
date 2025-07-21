// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MyToken {
    address public owner;
    uint private tokenId;
    string public name = "MyToken";
    string public symbol = "MTK";

    mapping(uint => address) public ownerOf;
    mapping(uint => string) public tokenURI;
    mapping(uint => address) public tokenApprovals;
    mapping(address => mapping(address => bool)) public operatorApprovals;
    mapping(address => uint) public balances;

    enum Status { PAUSE, UNPAUSE }
    Status public currentStatus;

    constructor() {
        owner = msg.sender;
        currentStatus = Status.UNPAUSE;
    }

    function pause() public {
        require(msg.sender == owner, "Only owner can pause");
        currentStatus = Status.PAUSE;
    }

    function unPause() public {
        require(msg.sender == owner, "Only owner can unpause");
        currentStatus = Status.UNPAUSE;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }

    function safeMint(address to, string memory uri) public {
        require(msg.sender == owner, "Only owner can mint");
        require(to != address(0), "Invalid address");
        require(currentStatus == Status.UNPAUSE, "Minting is paused");

        tokenId++;
        ownerOf[tokenId] = to;
        tokenURI[tokenId] = uri;
        balances[to]++;
    }

    function balanceOf(address user) public view returns (uint) {
        require(user != address(0), "Invalid address");
        return balances[user];
    }

    function approve(address to, uint _tokenId) public {
        address tokenOwner = ownerOf[_tokenId];
        require(tokenOwner != address(0), "Token doesn't exist");
        require(to != tokenOwner, "Cannot approve current owner");
        require(msg.sender == tokenOwner , "Not authorized");

        tokenApprovals[_tokenId] = to;
    }

    function getApproved(uint _tokenId) public view returns (address) {
        require(ownerOf[_tokenId] != address(0), "Token doesn't exist");
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Cannot approve yourself");
        operatorApprovals[msg.sender][operator] = approved;
    }

    function isApprovedForAll(address _owner, address operator) public view returns (bool) {
        return operatorApprovals[_owner][operator];
    }

    function transferFrom(address from, address to, uint _tokenId) public {
        address tokenOwner = ownerOf[_tokenId];
        require(tokenOwner != address(0), "Token doesn't exist");
        require(to != address(0), "Invalid recipient");
        require(
            msg.sender == tokenOwner ||
            tokenApprovals[_tokenId] == msg.sender ||
            operatorApprovals[tokenOwner][msg.sender],
            "Not authorized"
        );
        require(tokenOwner == from, "From is not the owner");

        
        ownerOf[_tokenId] = to;
        balances[from]--;
        balances[to]++;
        
    }

    function safeTransferFrom(address from, address to, uint _tokenId) public {
        transferFrom(from, to, _tokenId);
    }

    function tokenURIof(uint _tokenId) public view returns (string memory) {
        require(ownerOf[_tokenId] != address(0), "Token doesn't exist");
        return tokenURI[_tokenId];
    }
}
