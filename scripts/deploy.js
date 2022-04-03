const {ethers} = require("hardhat");

const main = async () => {
  const c = await ethers.getContractFactory("Shitswap");
  const cd = await c.deploy();
  await cd.deployed();
  console.log("Contract Address: ", cd.address);
}

main()
.then( () => process.exit(0))
.catch( (err) => {
  console.log(err);
  process.exit(1);
})

//0x7CE3F8Cca7f6b0BC2ddb2dDc78c66E56031f9C4d