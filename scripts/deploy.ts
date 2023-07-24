import { ethers, network, run } from "hardhat";

async function main() {

  const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const _ZRO = await ethers.getContractFactory("Zero");
    const ZeroToken = await _ZRO.deploy();


  
    console.log("ZERO Contract deployed at: ", await ZeroToken.address);


    console.log("Deploying DEX with the account: ", deployer.address);
    
  
    const _Dex = await ethers.getContractFactory("DecentralizedExchange");

    console.log("Deploying DEX contract with Zero Token Address: ", await ZeroToken.address)
    
    const ZroAddress = await ZeroToken.address;
    
    const DEX = await _Dex.deploy(ZroAddress);
    

    console.log("DEX Contract deployed at: ", await DEX.address);



    if(!["hardhat", "localhost"].includes(network.name) && (process.env.ETHERSCAN_API_KEY)){
        console.log("Verifying contract.....")
        try{
            await run("verify:verify", {
                address: DEX.address, 
            })
            await run("verify:verify", {
              address: ZeroToken.address, 
          })
        }catch (e : any) {
        if (e.message.toLowerCase().includes("already verified")){
            console.log("Contract Already Verified")
        }else{ console.log(e) }
        }
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
