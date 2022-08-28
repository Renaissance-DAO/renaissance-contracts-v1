//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {SimpleMockNFT} from "../../contracts/mocks/NFT.sol";
import {WETH} from "../../contracts/mocks/WETH.sol";
import {console} from "../utils/console.sol";
import {CheatCodes} from "../utils/cheatcodes.sol";

contract User is ERC721Holder, ERC1155Holder {
    // // to be able to receive funds
    receive() external payable {} // solhint-disable-line no-empty-blocks

    fallback() external payable {} // solhint-disable-line no-empty-blocks`
}
