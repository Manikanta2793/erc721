const {ethers} = require("hardhat");
const {except} = require("chai");


describe("Should check all my test cases",async function() {

let Token, token ,owner, addr1,addr2;

beforeEach(async function () {
Token = await ethers.getContractFactory();
        [owner,addr1,addr2] = await ethers.getSigners();
        token = await Token.deploy("MyToken","MTK");
        // await token.waitForDeployment();
        // console.log(token.getAddress())
    const deployedAddress = await token.getAddress();
    console.log("Contract Address:", deployedAddress);



    
})






    
})

