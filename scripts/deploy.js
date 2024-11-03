// deploy.js
const { ethers } = require("hardhat");

async function main() {
    // Адрес OCEAN токена в Sapphire testnet
    const oceanTokenAddress = "0x973e69303259B0c2543a38665122b773D28405fB";

    // Деплоим Nicknames
    const Nicknames = await ethers.getContractFactory("Nicknames");
    const nicknames = await Nicknames.deploy();
    await nicknames.waitForDeployment();
    
    const nicknamesAddress = await nicknames.getAddress();
    console.log("Nicknames deployed to:", nicknamesAddress);

    // Деплоим KingOfTheHill
    const KingOfTheHill = await ethers.getContractFactory("KingOfTheHill");
    const kingOfTheHill = await KingOfTheHill.deploy(
        oceanTokenAddress, 
        nicknamesAddress
    );
    await kingOfTheHill.waitForDeployment();

    const kingAddress = await kingOfTheHill.getAddress();
    console.log("KingOfTheHill deployed to:", kingAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });