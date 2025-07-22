const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken NFT Contract Test Cases", function () {
  let Token, token, owner, addr1, addr2;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("MyToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    token = await Token.deploy();
    await token.waitForDeployment();
    const deployedAddress = await token.getAddress();
    console.log("Contract Address:", deployedAddress);
  });

  it("Should initialize the state variables correctly", async function () {
    const contractOwner = await token.owner();
    const name = await token.name();
    const symbol = await token.symbol();
    expect(contractOwner).to.equal(owner.address);
    expect(name).to.equal("MyToken");
    expect(symbol).to.equal("MTK");
  });

  it("Should mint a new token to a valid address", async function () {
    await token.safeMint(addr1.address, "ipfs://token1.json");
    const balance = await token.balanceOf(addr1.address);
    const uri = await token.tokenURIof(1);
    expect(balance).to.equal(1);
    expect(uri).to.equal("ipfs://token1.json");
    const ownerOfToken = await token.ownerOf(1);
    expect(ownerOfToken).to.equal(addr1.address);
  });

  it("Should not allow minting when paused", async function () {
    await token.pause();
    await expect(token.safeMint(addr1.address, "ipfs://token2.json")).to.be.revertedWith("Minting is paused");
  });

  it("Should not allow non-owners to mint", async function () {
    await expect(token.connect(addr1).safeMint(addr1.address, "ipfs://token3.json")).to.be.revertedWith("Only owner can mint");
  });

  it("Should pause and unpause correctly", async function () {
    await token.pause();
    let status = await token.currentStatus();
    expect(status).to.equal(0); // PAUSE

    await token.unPause();
    status = await token.currentStatus();
    expect(status).to.equal(1); // UNPAUSE
  });

  it("Should transfer ownership properly", async function () {
    await token.transferOwnership(addr1.address);
    const newOwner = await token.owner();
    expect(newOwner).to.equal(addr1.address);
  });

  it("Should approve and retrieve approved address for a token", async function () {
    await token.safeMint(addr1.address, "ipfs://token4.json");
    await token.connect(addr1).approve(addr2.address, 1);
    const approved = await token.getApproved(1);
    expect(approved).to.equal(addr2.address);
  });

  it("Should set and check operator approval", async function () {
    await token.setApprovalForAll(addr1.address, true);
    const isApproved = await token.isApprovedForAll(owner.address, addr1.address);
    expect(isApproved).to.equal(true);
  });

  it("Should transfer token with transferFrom by owner", async function () {
    await token.safeMint(owner.address, "ipfs://token5.json");
    await token.transferFrom(owner.address, addr1.address, 1);
    const newOwner = await token.ownerOf(1);
    expect(newOwner).to.equal(addr1.address);
  });

  it("Should transfer token with safeTransferFrom by approved address", async function () {
    await token.safeMint(owner.address, "ipfs://token6.json");
    await token.approve(addr1.address, 1);
    await token.connect(addr1).safeTransferFrom(owner.address, addr2.address, 1);
    const newOwner = await token.ownerOf(1);
    expect(newOwner).to.equal(addr2.address);
  });

  it("Should revert invalid transfer attempts", async function () {
    await token.safeMint(owner.address, "ipfs://token7.json");

    await expect(
      token.connect(addr1).transferFrom(owner.address, addr2.address, 1)
    ).to.be.revertedWith("Not authorized");

    await expect(
      token.transferFrom(owner.address, ethers.ZeroAddress, 1)
    ).to.be.revertedWith("Invalid recipient");
  });

  it("Should return token URI", async function () {
    await token.safeMint(owner.address, "ipfs://mytoken.json");
    const uri = await token.tokenURIof(1);
    expect(uri).to.equal("ipfs://mytoken.json");
  });

});
