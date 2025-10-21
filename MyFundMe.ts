import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();


describe("MyFundMe", function () {
  let deployer: any;
  let user1: any ;
  let user2 : any ;
  let user3: any ;
  const sendValue = ethers.parseEther("1");
  let fundMe : any;

  beforeEach(async function () {
    [deployer, user1, user2, user3] = await ethers.getSigners();
    const FundMe = await ethers.getContractFactory("MyFundMe");
    fundMe = (await FundMe.deploy()) ;
    await fundMe.waitForDeployment();
  });

  it("sets the deployer as owner", async function () {
    const owner = await fundMe.getOwner();
    expect(owner).to.equal(deployer.address);
  });

  it("allows funding and records the sender and amount", async function () {
    await fundMe.connect(user1).fund({ value: sendValue });
    const amountFunded = await fundMe.getAddressToAmountFunded(user1.address);
    expect(amountFunded).to.equal(sendValue);
    const firstFunder = await fundMe.getFunder(0);
    expect(firstFunder).to.equal(user1.address);
  });

  it("rejects funding below minimum", async function () {
    await expect(
      fundMe.connect(user1).fund({ value: ethers.parseEther("0.001") })
    ).to.be.revertedWithCustomError(fundMe, "fundedAmountLessThan$5");
  });

  it("only owner can withdraw", async function () {
    await fundMe.connect(user1).fund({ value: sendValue });
    await expect(fundMe.connect(user1).withdraw()).to.be.revertedWithCustomError(
      fundMe,
      "NotOwner"
    );
  });

  it("allows owner to withdraw and resets balances", async function () {
    await fundMe.connect(user1).fund({ value: sendValue });
    const startingOwnerBalance = await ethers.provider.getBalance(deployer.address);

    const txResponse = await fundMe.connect(deployer).withdraw();
    const txReceipt = await txResponse.wait();
    const gasUsed = txReceipt!.gasUsed * txReceipt!.gasPrice!;

    const endingOwnerBalance = await ethers.provider.getBalance(deployer.address);
    const endingContractBalance = await ethers.provider.getBalance(fundMe.target);

    expect(endingContractBalance).to.equal(0);
    expect(await fundMe.getAddressToAmountFunded(user1.address)).to.equal(0);
    expect(endingOwnerBalance).to.be.greaterThan(startingOwnerBalance - gasUsed);
  });

   it("allows owner to withdraw and resets all the balances", async function () {
        await fundMe.connect(user1).fund({value: sendValue});
        await fundMe.connect(deployer).withdraw();
        const endingContractBalance = await ethers.provider.getBalance(fundMe.target);
        expect(endingContractBalance).to.equal(0);
        const user1Balance = await fundMe.getAddressToAmountFunded(user1.address);
        expect(user1Balance).to.equal(0);
    });

    it("should not allow duplicate funders in the funders array", async function() {
      await fundMe.connect(user1).fund({value: sendValue});
      await fundMe.connect(user1).fund({value: sendValue});
      await fundMe.connect(user2).fund({value: sendValue});
      await fundMe.connect(user3).fund({value: sendValue});
      await fundMe.connect(user2).fund({value: sendValue});
      await fundMe.connect(user1).fund({value: sendValue});
      const firstFunder = await fundMe.getFunder(0);
      expect(firstFunder).to.equal(user1.address);
      const secondFunder = await fundMe.getFunder(1);
      expect(secondFunder).to.equal(user2.address);
      const thirdFunder = await fundMe.getFunder(2);
      expect(thirdFunder).to.equal(user3.address);
    })
    it("should increase in balance after multiple funding", async function() {
      await fundMe.connect(user1).fund({value: sendValue});
      await fundMe.connect(user1).fund({value: sendValue});
      await fundMe.connect(user2).fund({value: sendValue});
      await fundMe.connect(user3).fund({value: sendValue});
      await fundMe.connect(user2).fund({value: sendValue});
      await fundMe.connect(user1).fund({value: sendValue});
      const contracBalance = await ethers.provider.getBalance(fundMe.target);
      expect(contracBalance).to.equal((sendValue * 6n));

});
})
