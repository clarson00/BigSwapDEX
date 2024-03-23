// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import "./BigPool.sol";

contract BigSwap {

    address[] public allPairs;
    mapping(address => mapping(address => BigPool)) public getPair;

    event PairCreated(address indexed token1, address indexed token2, address pair);


    function createPairs (address token1, address token2, string calldata token1Name, string calldata token2Name) external returns (address ) {
        require(token1 != token2, "Identical tokens are not allowed");
        require(address(getPair[token1][token2]) == address(0), "Pair already exists");

        string memory liquidityTokenName = string(abi.encodePacked("Liquidity-", token1Name, "-", token2Name));
        string memory liquidityTokenSymbol = string(abi.encodePacked("LP-", token1Name, "-", token2Name));

        BigPool bigPool = new BigPool(token1, token2,liquidityTokenName,liquidityTokenSymbol );

        getPair[token1][token2] = bigPool;
        getPair[token2][token1] = bigPool;
        allPairs.push(address(bigPool));


        emit  PairCreated(token1, token2, address(bigPool));

        return address(bigPool);


    }

    function allPairsLength() external view returns(uint){
        return allPairs.length;

    }

    function getPairs() external view returns(address[] memory) {
        return allPairs;
    }






}