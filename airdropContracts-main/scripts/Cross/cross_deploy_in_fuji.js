const { BigNumber } = require("ethers");
const hre = require("hardhat");

async function main() {

  const [deployer] = await ethers.getSigners()
  console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

  const balance = (await deployer.getBalance()).toString()
  console.log("Account balance:", balance, balance > 0)
  if (balance === 0) {
    throw (`Not enough eth`)
  }

  const AdminInFuji = await ethers.getContractFactory("AdminInEth_Gen");
  const adminInFuji = await AdminInFuji.deploy("0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706")  // endpoint = ILayerZeroEndpoint(_endpoint);
  await adminInFuji.deployTransaction.wait()
  console.log("adminInfuji address:", adminInFuji.address)
  

  const DepositInFuji = await ethers.getContractFactory("DepositInEth");
  const depositInFuji = await DepositInFuji.deploy(
    adminInFuji.address    //base = IERC721A(_base);
  );
  await depositInFuji.deployTransaction.wait()
  console.log("depositInfuji address:", depositInFuji.address)


  await depositInFuji.setWhitelist(adminInFuji.address, true) //设置白名单
  await sleep(5000)
  await adminInFuji.setdepositAddress(depositInFuji.address)
  await sleep(5000)
  await depositInFuji.setOperator(adminInFuji.address)      //把设置为存储合约的appove 

}

function sleep(millisecond) {
  return new Promise(resolve => {
      setTimeout(() => {
          resolve()
      }, millisecond)
  })
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
