import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { BigNumber, parseFixed } from "@ethersproject/bignumber";
import { ethers } from "hardhat";

/**
 *
 * SCENARIOS
 * 1.  NFT1 => FNFTCollection with 5 items
 * 2.  NFT2 => FNFTCollection with 1 item
 * 3.  NFT3 => FNFTCollection without an item
 * 4.  NFT4 => FNFTCollection with 5 items that has 3 items in bid
 * 5.  NFT5 => FNFTCollection with 5 items that has 2 items in bid and 2 items redeemed
 * 6.  NFT6 => FNFTCollection with 5 items that have no tokenURI
 * 7.  NFT7 => FNFTCollection with 50 items
 * 8.  NFT8 => FNFTCollection with 5 items, where 2 have been minted to a chosen (user) address
 * 9.  NFT9 => FNFTCollection that is undergoing IFO but not started
 * 10.  NFT10 => FNFTCollection that is undergoing IFO and has started with a few sales here and there
 * 11.  NFT11 => FNFTCollection that is undergoing IFO and is paused with a few sales here and there
 * 12.  NFT12 => FNFTCollection that has finished IFO with a few sales here and there
 */

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, ethers } = hre;
  const { deploy } = hre.deployments;
  const { deployer } = await getNamedAccounts();

  // NFT1
  const nft1Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT1 Name", "NFT1"],
    log: true,
    autoMine: true,
  });
  const nft1 = await ethers.getContractAt(nft1Info.abi, nft1Info.address);
  const setBaseURITx1 = await nft1.setBaseURI("ipfs://QmVTuf8VqSjJ6ma6ykTJiuVtvAY9CHJiJnXsgSMf5rBRtZ/");
  await setBaseURITx1.wait();

  // NFT2
  const nft2Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT2 Name", "NFT2"],
    log: true,
    autoMine: true,
  });
  const nft2 = await ethers.getContractAt(nft2Info.abi, nft2Info.address);
  const setBaseURITx2 = await nft2.setBaseURI("https://www.timelinetransit.xyz/metadata/");
  await setBaseURITx2.wait();

  // NFT3
  const nft3Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT3 Name", "NFT3"],
    log: true,
    autoMine: true,
  });
  const nft3 = await ethers.getContractAt(nft3Info.abi, nft3Info.address);
  const setBaseURITx3 = await nft3.setBaseURI("ipfs://bafybeie7oivvuqcmhjzvxbiezyz7sr4fxkcrutewmaoathfsvcwksqiyuy/");
  await setBaseURITx3.wait();

  // NFT4
  const nft4Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT4 Name", "NFT4"],
    log: true,
    autoMine: true,
  });
  const nft4 = await ethers.getContractAt(nft4Info.abi, nft4Info.address);
  const setBaseURITx4 = await nft4.setBaseURI("https://cdn.childrenofukiyo.com/metadata/");
  await setBaseURITx4.wait();

  // NFT5
  const nft5Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT5 Name", "NFT5"],
    log: true,
    autoMine: true,
  });
  const nft5 = await ethers.getContractAt(nft5Info.abi, nft5Info.address);
  const setBaseURITx5 = await nft5.setBaseURI(
    "https://chainbase-api.matrixlabs.org/metadata/api/v1/apps/ethereum:mainnet:bKPQsA_Ohnj1Ug0MvX39i/contracts/0x249aeAa7fA06a63Ea5389b72217476db881294df_ethereum/metadata/tokens/"
  );
  await setBaseURITx5.wait();

  // NFT6 (No TokenURI)
  const nft6Info = await deploy("NoURIMockNFT", {
    from: deployer,
    args: ["NFT6 Name", "NFT6"],
    log: true,
    autoMine: true,
  });
  const nft6 = await ethers.getContractAt(nft6Info.abi, nft6Info.address);

  // NFT7
  const nft7Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT7 Name", "NFT7"],
    log: true,
    autoMine: true,
  });
  const nft7 = await ethers.getContractAt(nft7Info.abi, nft7Info.address);
  const setBaseURITx7 = await nft7.setBaseURI("https://loremnft.com/nft/token/");
  await setBaseURITx7.wait();

  // NFT8
  const nft8Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT8 Name", "NFT8"],
    log: true,
    autoMine: true,
  });
  const nft8 = await ethers.getContractAt(nft8Info.abi, nft8Info.address);
  const setBaseURITx8 = await nft8.setBaseURI("ipfs://QmQNdnPx1K6a8jd5XJEJvGorx73U9pmpqU2YAhEfQZDwcw/");
  await setBaseURITx8.wait();

  // NFT9
  const nft9Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT9 Name", "NFT9"],
    log: true,
    autoMine: true,
  });
  const nft9 = await ethers.getContractAt(nft9Info.abi, nft9Info.address);
  const setBaseURITx9 = await nft9.setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
  await setBaseURITx9.wait();

  // NFT10
  const nft10Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT10 Name", "NFT10"],
    log: true,
    autoMine: true,
  });
  const nft10 = await ethers.getContractAt(nft10Info.abi, nft10Info.address);
  const setBaseURITx10 = await nft10.setBaseURI(
    "https://metadata.buildship.xyz/api/dummy-metadata-for/bafybeifuibkffbtlu4ttpb6c3tiyhezxoarxop5nuhr3ht3mdb7puumr2q/"
  );
  await setBaseURITx10.wait();

  // NFT11
  const nft11Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT11 Name", "NFT11"],
    log: true,
    autoMine: true,
  });
  const nft11 = await ethers.getContractAt(nft11Info.abi, nft11Info.address);
  const setBaseURITx11 = await nft11.setBaseURI("http://api.cyberfist.xyz/badges/metadata/");
  await setBaseURITx11.wait();

  // NFT12
  const nft12Info = await deploy("StandardMockNFT", {
    from: deployer,
    args: ["NFT12 Name", "NFT12"],
    log: true,
    autoMine: true,
  });
  const nft12 = await ethers.getContractAt(nft12Info.abi, nft12Info.address);
  const setBaseURITx12 = await nft12.setBaseURI(
    "https://gateway.pinata.cloud/ipfs/Qmdp8uFBrWq3CJmNHviq4QLZzbw5BchA7Xi99xTxuxoQjY/"
  );
  await setBaseURITx12.wait();

  for (let i = 1; i <= 5; i++) {
    // approve factory
    const mintTx1 = await nft1.mint(deployer, i);
    await mintTx1.wait();
    const mintTx2 = await nft2.mint(deployer, i);
    await mintTx2.wait();
    const mintTx3 = await nft3.mint(deployer, i);
    await mintTx3.wait();
    const mintTx4 = await nft4.mint(deployer, i);
    await mintTx4.wait();
    const mintTx5 = await nft5.mint(deployer, i);
    await mintTx5.wait();
    const mintTx6 = await nft6.mint(deployer, i);
    await mintTx6.wait();
    const mintTx7 = await nft7.mint(deployer, i);
    await mintTx7.wait();
    const mintTx8 = await nft8.mint(deployer, i);
    await mintTx8.wait();
    const mintTx9 = await nft9.mint(deployer, i);
    await mintTx9.wait();
    const mintTx10 = await nft10.mint(deployer, i);
    await mintTx10.wait();
    const mintTx11 = await nft11.mint(deployer, i);
    await mintTx11.wait();
    const mintTx12 = await nft12.mint(deployer, i);
    await mintTx12.wait();
  }

  for (let i = 6; i <= 50; i++) {
    const mintTx7 = await nft7.mint(deployer, i);
    await mintTx7.wait();
  }

  // fractionalize nfts
  const FNFTCollectionFactory = await getContract(hre, "FNFTCollectionFactory");

  // NFT1
  const fnftCollection1Receipt = await FNFTCollectionFactory.createVault(
    nft1Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 1", // name
    "FNFTC1" // symbol
  );
  await fnftCollection1Receipt.wait();

  // NFT2
  const fnftCollection2Receipt = await FNFTCollectionFactory.createVault(
    nft2Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 2", // name
    "FNFTC2" // symbol
  );
  await fnftCollection2Receipt.wait();

  // NFT3
  const fnftCollection3Receipt = await FNFTCollectionFactory.createVault(
    nft3Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 3", // name
    "FNFTC3" // symbol
  );
  await fnftCollection3Receipt.wait();

  // NFT4
  const fnftCollection4Receipt = await FNFTCollectionFactory.createVault(
    nft4Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 4", // name
    "FNFTC4" // symbol
  );
  await fnftCollection4Receipt.wait();

  // NFT5
  const fnftCollection5Receipt = await FNFTCollectionFactory.createVault(
    nft5Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 5", // name
    "FNFTC5" // symbol
  );
  await fnftCollection5Receipt.wait();

  // NFT6
  const fnftCollection6Receipt = await FNFTCollectionFactory.createVault(
    nft6Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 6", // name
    "FNFTC6" // symbol
  );
  await fnftCollection6Receipt.wait();

  // NFT7
  const fnftCollection7Receipt = await FNFTCollectionFactory.createVault(
    nft7Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 7", // name
    "FNFTC7" // symbol
  );
  await fnftCollection7Receipt.wait();

  // NFT8
  const fnftCollection8Receipt = await FNFTCollectionFactory.createVault(
    nft8Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 8", // name
    "FNFTC8" // symbol
  );
  await fnftCollection8Receipt.wait();

  // NFT9
  const fnftCollection9Receipt = await FNFTCollectionFactory.createVault(
    nft9Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 9", // name
    "FNFTC9" // symbol
  );
  await fnftCollection9Receipt.wait();

  // NFT10
  const fnftCollection10Receipt = await FNFTCollectionFactory.createVault(
    nft10Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 10", // name
    "FNFTC10" // symbol
  );
  await fnftCollection10Receipt.wait();

  // NFT11
  const fnftCollection11Receipt = await FNFTCollectionFactory.createVault(
    nft11Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 11", // name
    "FNFTC11" // symbol
  );
  await fnftCollection11Receipt.wait();

  // NFT12
  const fnftCollection12Receipt = await FNFTCollectionFactory.createVault(
    nft12Info.address, // collection address
    false, // is1155
    true, // allowAllItems
    "FNFT Collection 12", // name
    "FNFTC12" // symbol
  );
  await fnftCollection12Receipt.wait();

  const fnftCollection1Address = await getFNFTCollectionAddress(fnftCollection1Receipt);
  const fnftCollection2Address = await getFNFTCollectionAddress(fnftCollection2Receipt);
  const fnftCollection3Address = await getFNFTCollectionAddress(fnftCollection3Receipt);
  const fnftCollection4Address = await getFNFTCollectionAddress(fnftCollection4Receipt);
  const fnftCollection5Address = await getFNFTCollectionAddress(fnftCollection5Receipt);
  const fnftCollection6Address = await getFNFTCollectionAddress(fnftCollection6Receipt);
  const fnftCollection7Address = await getFNFTCollectionAddress(fnftCollection7Receipt);
  const fnftCollection8Address = await getFNFTCollectionAddress(fnftCollection8Receipt);
  const fnftCollection9Address = await getFNFTCollectionAddress(fnftCollection9Receipt);
  const fnftCollection10Address = await getFNFTCollectionAddress(fnftCollection10Receipt);
  const fnftCollection11Address = await getFNFTCollectionAddress(fnftCollection11Receipt);
  const fnftCollection12Address = await getFNFTCollectionAddress(fnftCollection12Receipt);

  const fnftCollection1 = await ethers.getContractAt("FNFTCollection", fnftCollection1Address);
  const fnftCollection2 = await ethers.getContractAt("FNFTCollection", fnftCollection2Address);
  const fnftCollection3 = await ethers.getContractAt("FNFTCollection", fnftCollection3Address);
  const fnftCollection4 = await ethers.getContractAt("FNFTCollection", fnftCollection4Address);
  const fnftCollection5 = await ethers.getContractAt("FNFTCollection", fnftCollection5Address);
  const fnftCollection6 = await ethers.getContractAt("FNFTCollection", fnftCollection6Address);
  const fnftCollection7 = await ethers.getContractAt("FNFTCollection", fnftCollection7Address);
  const fnftCollection8 = await ethers.getContractAt("FNFTCollection", fnftCollection8Address);
  const fnftCollection9 = await ethers.getContractAt("FNFTCollection", fnftCollection9Address);
  const fnftCollection10 = await ethers.getContractAt("FNFTCollection", fnftCollection10Address);
  const fnftCollection11 = await ethers.getContractAt("FNFTCollection", fnftCollection11Address);
  const fnftCollection12 = await ethers.getContractAt("FNFTCollection", fnftCollection12Address);

  const setApprovalForAllTx1 = await nft1.setApprovalForAll(fnftCollection1.address, true);
  await setApprovalForAllTx1.wait();
  const setApprovalForAllTx2 = await nft2.setApprovalForAll(fnftCollection2.address, true);
  await setApprovalForAllTx2.wait();
  const setApprovalForAllTx3 = await nft3.setApprovalForAll(fnftCollection3.address, true);
  await setApprovalForAllTx3.wait();
  const setApprovalForAllTx4 = await nft4.setApprovalForAll(fnftCollection4.address, true);
  await setApprovalForAllTx4.wait();
  const setApprovalForAllTx5 = await nft5.setApprovalForAll(fnftCollection5.address, true);
  await setApprovalForAllTx5.wait();
  const setApprovalForAllTx6 = await nft6.setApprovalForAll(fnftCollection6.address, true);
  await setApprovalForAllTx6.wait();
  const setApprovalForAllTx7 = await nft7.setApprovalForAll(fnftCollection7.address, true);
  await setApprovalForAllTx7.wait();
  const setApprovalForAllTx8 = await nft8.setApprovalForAll(fnftCollection8.address, true);
  await setApprovalForAllTx8.wait();
  const setApprovalForAllTx9 = await nft9.setApprovalForAll(fnftCollection9.address, true);
  await setApprovalForAllTx9.wait();
  const setApprovalForAllTx10 = await nft10.setApprovalForAll(fnftCollection10.address, true);
  await setApprovalForAllTx10.wait();
  const setApprovalForAllTx11 = await nft11.setApprovalForAll(fnftCollection11.address, true);
  await setApprovalForAllTx11.wait();
  const setApprovalForAllTx12 = await nft12.setApprovalForAll(fnftCollection12.address, true);
  await setApprovalForAllTx12.wait();

  const mintToTx1 = await fnftCollection1.mintTo([1, 2, 3, 4, 5], [], deployer);
  await mintToTx1.wait();
  const mintToTx2 = await fnftCollection2.mintTo([1], [], deployer);
  await mintToTx2.wait();
  //skip fnft 3 mint
  const mintToTx4 = await fnftCollection4.mintTo([1, 2, 3, 4, 5], [], deployer); // bid 3
  await mintToTx4.wait();
  const mintToTx5 = await fnftCollection5.mintTo([1, 2, 3, 4, 5], [], deployer); // bid 2 and redeem 2
  await mintToTx5.wait();
  const mintToTx6 = await fnftCollection6.mintTo([1, 2, 3, 4, 5], [], deployer); // no tokenURI
  await mintToTx6.wait();
  const mintToTx7 = await fnftCollection7.mintTo(
    Array.from({ length: 50 }, (_, i) => i + 1),
    [],
    deployer
  ); // mint 50
  await mintToTx7.wait();
  const mintToTx8a = await fnftCollection8.mintTo([1, 2, 3], [], deployer); // 3 mint to deployer
  await mintToTx8a.wait();
  const mintToTx8b = await fnftCollection8.mintTo([4, 5], [], deployer); // 2 mint to chosen (change address)
  await mintToTx8b.wait();
  const mintToTx9 = await fnftCollection9.mintTo([1, 2, 3, 4, 5], [], deployer); // ifo not started
  await mintToTx9.wait();
  const mintToTx10 = await fnftCollection10.mintTo([1, 2, 3, 4, 5], [], deployer); // ifo ongoing
  await mintToTx10.wait();
  const mintToTx11 = await fnftCollection11.mintTo([1, 2, 3, 4, 5], [], deployer); // ifo paused
  await mintToTx11.wait();
  const mintToTx12 = await fnftCollection12.mintTo([1, 2, 3, 4, 5], [], deployer); // ifo finished
  await mintToTx12.wait();
};

async function getFNFTCollectionAddress(transactionReceipt: any) {
  const abi = [
    "event VaultCreated(uint256 indexed vaultId, address curator, address vaultAddress, address assetAddress, string name, string symbol);",
  ];
  const _interface = new ethers.utils.Interface(abi);
  const topic = "0x7ba4daf113dab617fb46d5bf414c46f4e17aa717bce3c75bacbad12baef0233c";
  const receipt = await transactionReceipt.wait();
  const event = receipt.logs.find((log: any) => log.topics[0] === topic);
  return _interface.parseLog(event).args[2];
}

async function getContract(hre: HardhatRuntimeEnvironment, key: string) {
  const { deployments, getNamedAccounts } = hre;
  const { get } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  const proxyControllerInfo = await get("MultiProxyController");
  const proxyController = new ethers.Contract(
    proxyControllerInfo.address,
    proxyControllerInfo.abi,
    signer
  );
  const abi = (await get(key)).abi; // get abi of impl contract
  const address = (await proxyController.proxyMap(ethers.utils.formatBytes32String(key)))[1];
  return new ethers.Contract(address, abi, signer);
}

func.tags = ["seed"];
export default func;
