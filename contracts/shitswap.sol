//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Shitswap is ERC20 {

    address public shitcoinTokenAddress = 0xdb239Ad38178387495ebec34B1d274952B12370c;

    constructor() ERC20("Shitswap LP Token","SSLP") {

    }

    /**
    *  @dev Returns the amount of `Crypto Dev Tokens` held by the contract
    */
    function getReserve() public view returns(uint) {
        return ERC20(shitcoinTokenAddress).balanceOf(address(this));
    }

    /**
    * @dev Adds liquidity to the exchange.
    */
    function addLiquidity(uint _amount) public payable returns(uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint tokenReserve = getReserve();
        ERC20 token = ERC20(shitcoinTokenAddress);

        if(tokenReserve == 0) {
            //transfer token from user to contract
            token.transferFrom(msg.sender, address(this), _amount);

            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        }
        else {
            uint ethReserve = ethBalance - msg.value;

            uint tokenAmount = ( msg.value * tokenReserve ) / ethReserve;

            require(_amount >= tokenAmount, "Amount of tokens sent is less than the minimum tokens required");

            token.transferFrom(msg.sender, address(this), tokenAmount);

            liquidity = ( msg.value * totalSupply() ) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    /**
    @dev Returns the amount Eth/Crypto Dev tokens that would be returned to the user
    * in the swap
    */
    function removeLiquidity(uint _amount) public returns(uint, uint) {
        require(_amount > 0, "amount should be greater than 0");

        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();

        uint ethAmount = ( _amount * ethReserve ) / _totalSupply;
        uint tokenAmount = ( _amount * getReserve() ) / _totalSupply;

        //burn the amount of LP Token sent by user
        _burn(msg.sender, _amount);

        //transfer eth to user
        payable(msg.sender).transfer(ethAmount);
        //transfer token to user
        ERC20(shitcoinTokenAddress).transfer(msg.sender, tokenAmount);

        return(ethAmount, tokenAmount);
    }

    /**
    @dev Returns the amount Eth/Crypto Dev tokens that would be returned to the user
    * in the swap
    */
    function getAmountOfToken(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns(uint) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserve");

        uint inputAmountAfterFee = inputAmount * 99;

         // so the final formulae is Δy = (y*Δx)/(x + Δx);

        uint256 numerator = outputReserve * inputAmountAfterFee;
        uint256 denominator = (inputReserve * 100) + inputAmountAfterFee;
        return numerator / denominator;
    }

   /**
     @dev Swaps Ether for Tokens
    */
    function ethToToken(uint _minTokens) public payable {
        uint tokenReserve = getReserve();

        uint tokensBought = getAmountOfToken(msg.value, address(this).balance - msg.value, tokenReserve);

        require(tokensBought >= _minTokens, "Insufficient output amount");
        // Transfer the `Crypto Dev` tokens to the user
        ERC20(shitcoinTokenAddress).transfer(msg.sender, tokensBought);
    }

    /**
    @dev Swaps Tokens for Ether
    */
    function tokenToEth(uint _tokensSold, uint _minEth) public {
        uint tokenReserve = getReserve();

        uint ethBought = getAmountOfToken(_tokensSold, tokenReserve, address(this).balance);

        require(ethBought >= _minEth, "Insufficient output Amount");

        // transfer token from user to contract 
        ERC20(shitcoinTokenAddress).transferFrom(msg.sender, address(this), _tokensSold);
        //send ethBought to user form contract
        payable(msg.sender).transfer(ethBought);
    }
}