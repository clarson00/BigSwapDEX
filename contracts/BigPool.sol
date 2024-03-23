// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./BigLiquidityToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract BigPool {

    using SafeMath for uint;
    using Math for uint;
    address public token1;
    address public token2;
    uint256 public reserve1;
    uint256 public reserve2;

    // x* y = k

    uint public constantK;
    BigLiquidityToken public liquidityToken;

    event Swap (
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut,
        address tokenIn,
        address tokenOut

    );

    constructor(address _token1, address _token2, string memory _liquidityTokenName, string memory _liquidityTokenSymbol){

        token1 = _token1;
        token2 = _token2;
        liquidityToken = new BigLiquidityToken(_liquidityTokenName, _liquidityTokenSymbol);

    }

    function addLiquidity(uint amountToken1, uint amountToken2) external {
        // Create nd send liquidity token to the liquidity provider
        uint256 liquidity;
        uint256 totalSupplyOfToken = liquidityToken.totalSupply();
        if(totalSupplyOfToken == 0 ) {

        // liquidity at initialization
        liquidity = amountToken1.mul(amountToken2).sqrt(); 
        }else{
        // amountToken1 * totalSupplyLiquididtyToken / Reserve1, amountToken2 * totalSupplyLiquididtyToken / Reserve2
        liquidity = amountToken1.mul(totalSupplyOfToken).div(reserve1).min(amountToken2.mul(totalSupplyOfToken).div(reserve2));
       }
       liquidityToken.mint(msg.sender, liquidity);
       // Transfer amount of token1 and troken2 inside this liquidity pool
       require(IERC20(token1).transferFrom(msg.sender, address(this), amountToken1), "Transfer of Token1 failed");
       require(IERC20(token2).transferFrom(msg.sender,address(this), amountToken2), "Transfer of Token2 failed");
       // update reserve1 and reserve2
       reserve1 += amountToken1;
       reserve2 += amountToken2;
       // update the contant formula   
       _updateConstantFormula();


    }

    function removeLiquidity(uint amountOfLiquidity) external {
        uint256 totalSupply = liquidityToken.totalSupply();
        require(amountOfLiquidity <= totalSupply, "Liquidity is more than total supply");
        // Burn the liquidity amount
        liquidityToken.burn(msg.sender, amountOfLiquidity);

        // transfer token1 and token2 to liquidity provider or msg.sender
        uint256 amount1 = (reserve1 * amountOfLiquidity) / totalSupply;
        uint256 amount2 = (reserve2 * amountOfLiquidity) / totalSupply;
        require(IERC20(token1).transfer(msg.sender, amount1), "Transfer of token1 failed.");
        require(IERC20(token2).transfer(msg.sender, amount2), "Transfer of token2 failed.");       

        // update reserve 1 and 2
        reserve1 -= amount1;
        reserve2 -= amount2;

        // update the contant formula
        _updateConstantFormula;


    }

    function swapTokens(address fromToken, address toToken, uint256 amountIn, uint256 amountOut) external {
        // make some checks
        require(amountIn > 0 && amountOut > 0, "Amount must be greater than 0");
        require((fromToken == token1 && toToken == token2) || (fromToken == token2 && toToken == token1), "Tokens need to be pairs of this liquidity pool");
        IERC20 fromTokenContract = IERC20(fromToken);
        IERC20 toTokenContract = IERC20(toToken);
        require(fromTokenContract.balanceOf(msg.sender)> amountIn, "Insufficent balance of tokenFrom");
        require(toTokenContract.balanceOf(address(this))> amountOut, "Insufficent balance of tokenTo");
        // verify that amount1 is <= expectedAmount after calcualtion
        uint256 expectedAmountOut;
        // amountIn token1 reserve1
        // amountOut token2 reserve2
        // amountIn / amountOut = reserve1/reserve2
        // reserve1*reserve2 = consant
        // Expected amount out == reserve2 * amountin / reserve1

        if(fromToken == token1 && toToken == token2) {
            expectedAmountOut = constantK.div(reserve1.sub(amountIn)).sub(reserve2);
        }else{
            expectedAmountOut = constantK.div(reserve2.add(amountIn)).sub(reserve1);
        }
        require(amountOut <= expectedAmountOut, "Swap does not preserve constant forumla");

        // Perform the swap, to transfer amountin from the liquidity provider and to transfer the swap initiator amountOut

        require(fromTokenContract.transferFrom(msg.sender, address(this), amountIn), "Transfer of token From failed");
        require(toTokenContract.transfer(msg.sender, expectedAmountOut), "Transfer of token To failed");
        


        // Update reserve1 and reserve 2
        if(fromToken == token1 && toToken == token2){
            reserve1 = reserve1.add(amountIn);
            reserve2 = reserve2.sub(expectedAmountOut);

        }else{
            reserve1 = reserve1.sub(expectedAmountOut);
            reserve2 = reserve2.add(amountIn);
        }

        // Check that the result it mainting the contant formula x*y = k
        require(reserve1.mul(reserve2) <= constantK, "Swap does not preserve contant formula");
        _updateConstantFormula();

        // add events
        emit Swap(msg.sender, amountIn, expectedAmountOut, fromToken, toToken);

    }

    function _updateConstantFormula() internal {
        constantK = reserve1.mul(reserve2);
        require(constantK > 0, "Constant is less ten 0");
    }

    function estimateOuputAmount(uint256 amountIn, address fromToken) public view returns(uint256 expectedAmountOut){
        require(amountIn >0,"Amount must be greater than 0");
        require(fromToken == token1 || fromToken == token2, "Needs to be a token in this pair");
        if(fromToken == token1) {
            expectedAmountOut = constantK.div(reserve1.sub(amountIn)).sub(reserve2);

        }else{

            expectedAmountOut = constantK.div(reserve2.sub(amountIn)).sub(reserve1);
        }
        
    }

    
}
    
    
