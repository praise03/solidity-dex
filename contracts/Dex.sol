// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DecentralizedExchange is ERC20 {
    
    ERC20 zroToken;

    constructor (address tokenAddress) ERC20("ZERO/ETH", "ZETH") {
        require(tokenAddress != address(0), "Token address is zero address");
        zroToken = ERC20(tokenAddress);
    }

    function addLiquidity(uint256 tokenAmount) public payable returns(uint256) {
        require(msg.value > 0, "No ETH Supplied");
        uint256 proportionalZETHRecieved;
        uint256 _EthReserve = getTokenReserve();

        // Initial Liquidity, we dont have to mantain a defined ratio
        if (_EthReserve == 0 ) {
            (bool success) = zroToken.transferFrom(msg.sender, address(this), tokenAmount);
            require(success, "Failed to transfer ZRO");

            proportionalZETHRecieved = address(this).balance;

            _mint(msg.sender, proportionalZETHRecieved); 
        }
        else{
            _EthReserve = (address(this).balance) - msg.value;
            uint256 _tokenReserve = getTokenReserve();
            
            /*
            Liquitidy Ratio: inputZro/ZroReserve = msg.value/EthReserve
                        : inputZro = (msg.vakue * zroReserve) / EthReserve
            */

            uint256 proportionalTokenAmount = (msg.value * _tokenReserve) / _EthReserve;
            require(tokenAmount >= proportionalTokenAmount, "Incorrect ratio of tokens provided");
            
            (bool success) = zroToken.transferFrom(msg.sender, address(this), tokenAmount);
            require(success, "Failed to transfer ZRO");

            // same formula as Liquidity ratio
            proportionalZETHRecieved = (totalSupply() * msg.value) / _EthReserve;
            _mint(msg.sender, proportionalZETHRecieved);
        }
        return proportionalZETHRecieved;

    }

    function removeLiquidity(uint256 _lpTokenAmount) public returns(uint256, uint256) {
        /*
            : EthReturned / EthReserve = lpTokenAmount/LpTotalSupply;
            : EthReturned = (lpTokenAmount * EthReserve)/LpTotalSupply;
        */
        uint256 proportionalETHReturned = (_lpTokenAmount * address(this).balance) / totalSupply();
        payable(msg.sender).transfer(proportionalETHReturned);

        /*
            : ZROReturned / ZROReserve = lpTokenAmount/LpTotalSupply;
            : ZROReturned = (lpTokenAmount * ZROReserve)/LpTotalSupply;
        */

        uint256 proportionalZROReturned = (_lpTokenAmount * getTokenReserve()) / totalSupply();

        //remove user lp tokens from supply, do not need to transfer since supply is infinite;
        _burn(msg.sender, _lpTokenAmount);

        (bool success) = zroToken.transfer(msg.sender, proportionalZROReturned);
        require(success, "Failed to transfer ZRO");

        return (proportionalETHReturned, proportionalZROReturned);
        
    }

    //swap functions

    /* 
        @params: input = token to swap , output = token to be recieved 
    */
    function forecastOutputAmountfromSwap(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        require(inputReserve > 0  && outputReserve > 0, "Dex reserves have to be greater than zero");

        // outputAmount = (outputReserve * inputAmount) / (inputReserve + inputAmount)
        //5% fee
        uint256 outputAmount = (outputReserve * (95 * inputAmount) ) / ( (100 * inputReserve) + ( 95 * inputAmount) );
        return outputAmount;
    }

    function swapZROtoETH(uint256 zroAmount) public {
        uint256 ETHAmountRecieved = forecastOutputAmountfromSwap (
            zroAmount,
            getTokenReserve(),
            address(this).balance
        );

        zroToken.transferFrom(msg.sender, address(this), zroAmount);

        payable(msg.sender).transfer(ETHAmountRecieved);

    }

    function swapETHtoZRO() public payable {
        uint256 zroAmountRecieved = forecastOutputAmountfromSwap(
            msg.value,
            (address(this).balance - msg.value),
            getTokenReserve()
        );

        zroToken.transfer(msg.sender, zroAmountRecieved);
    }
    
    //Pure function to calcute swap amounts;

    function getEthReserve() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenReserve() public view returns (uint256) {
        return zroToken.balanceOf(address(this));
    }

    function calculateLPZROAmount(uint256 ethAmount) public view returns(uint256) {
        uint256 _tokenReserve = zroToken.balanceOf(address(this));
        uint256 _EthReserve = address(this).balance;
        return ( (ethAmount * _tokenReserve) / _EthReserve );
    }

    function calculateLPETHAmount(uint256 zroAmount) public view returns(uint256) {
        uint256 _tokenReserve = zroToken.balanceOf(address(this));
        uint256 _EthReserve = address(this).balance;
        return ( (zroAmount * _EthReserve) / _tokenReserve );
    }
}
