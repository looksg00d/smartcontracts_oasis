const { ethers } = require("hardhat");

async function main() {
    const kingOfTheHill = await ethers.getContractAt(
        "KingOfTheHill",
        "0x845e301402Ba655b51bd308363fa1dD0741B56dd"
    );

    const oceanToken = await ethers.getContractAt(
        "IERC20Template",
        "0x1B083D8584dd3e6Ff37d04a6e7e82b5F622f3985" // Убедитесь, что это правильный адрес для Sepolia
    );

    const signer = (await ethers.getSigners())[0];
    const yourAddress = signer.address;

    // Проверяем баланс
    const balance = await oceanToken.balanceOf(yourAddress);
    console.log("Balance:", ethers.utils.formatEther(balance));

    // Проверяем allowance
    let allowance = await oceanToken.allowance(yourAddress, kingOfTheHill.address);
    console.log("Initial Allowance:", ethers.utils.formatEther(allowance));

    // Если allowance недостаточен, увеличиваем его
    if (allowance.lt(ethers.utils.parseEther("10"))) {
        const tx = await oceanToken.approve(kingOfTheHill.address, ethers.utils.parseEther("500"));
        await tx.wait();
        console.log("Approved 500 OCEAN tokens");

        // Проверяем allowance снова
        allowance = await oceanToken.allowance(yourAddress, kingOfTheHill.address);
        console.log("Updated Allowance:", ethers.utils.formatEther(allowance));
    }

    // Становимся королём
    await kingOfTheHill.claimThrone(ethers.utils.parseEther("1"));

    // Получаем информацию о текущем короле
    const kingInfo = await kingOfTheHill.getKingInfo();
    console.log("Current King:", kingInfo);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });