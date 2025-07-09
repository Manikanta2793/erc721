
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


contract ERC20Token{
    string public name;
    string public symbol;
    address public owner;
    uint public totalSupply;


    mapping(address => uint) public address_balance;
    //mapping(address=>uint)allowance;
    mapping(address => mapping(address => uint value)) Allowance;
constructor(string memory _name,string memory _symbol){ 
    
    name = _name;
    symbol = _symbol; 
    owner = msg.sender;  
}
modifier onlyOwner() {
    require(owner == msg.sender, "only owner can Access");
    
    _;
}

function mint(address to, uint amount) public onlyOwner(){
    require(amount > 0,"amount should be greater than 0");
    require(to != address(0) ,"address should not be empty");
    
    address_balance[to] += amount;
    totalSupply += amount;
}
event transferDetails(address to,address indexed recepient,uint amount);

function transfer(address recepient  , uint amount ) public {
    
    require(recepient != address(0),"Invalid address");
    require(amount > 0,"transfer amount should be greater than 0");
    require(address_balance[msg.sender]>=amount, "Insufficient funds to transfer" );
    address_balance[recepient] += amount;
    address_balance[msg.sender] -= amount;
    emit transferDetails(msg.sender, recepient, amount);


}
function approve( address whom, uint amount) public  returns(bool status){
    require(address_balance[msg.sender]>= amount,"Insufficient funds to approve");
    Allowance[msg.sender][whom] +=amount;
    return true;
    
}
function transferFrom(address sender, address recipient,  uint amount) public {

    require(Allowance[sender][msg.sender]>= amount,"Insufficient funds");
    address_balance[recipient] += amount;
    Allowance[sender][msg.sender] -= amount;
    address_balance[sender] -= amount;
}

function burn(address account , uint value)public{


    require(account != address(0),"Invalid address");
    require(address_balance[account] >= value,"Insufficient funds to transfer");

    address_balance[account] -= value;
    address_balance[address(0)] += value;

}

}
