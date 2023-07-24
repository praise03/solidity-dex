<template>
    <div class=" h-[50vh] flex flex-col items-center justify-center sm:h-screen">
		
        <div class="sm:w-2/4">
		<div class="flex flex-row border" >
			<button @click="currentTab = 'add'" :class="{inactive : currentTab == 'remove', active: currentTab == 'add'}">Add</button>
			<button @click="currentTab = 'remove'" :class="{active: currentTab == 'remove', inactive: currentTab == 'add'}" >Remove</button>
		</div>
		<div v-if="currentTab == 'add'">
        <div class="mt-2 px-4 py-2 border  flex flex-col">
          <!-- <span class="font-thin">-$</span> -->
          <div class="flex p-3 ml-auto">
          <button class="items-center flex mr-16 bg-gray-200 rounded-md px-4 py-1 uppercase" > <img src="coin.svg" class="mt-[1.9px] mr-1 -ml-2" alt="" width="20" height="15">ZRO</button>
			<div class="flex bg-gray-200 py-1 px-2">
		  <input 
            autocomplete="off"
            autocorrect="off"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="0.0"
            minlength="1"
            maxlength="79"
            spellcheck="false"
            class="text-right ml-auto bg-gray-200 p-1 focus:outline-none w-2/4 "
            @keyup="getProportionalEthAmount()" 
			v-model="zroAmount"
            />
			<span class="ml-auto self-center font-thin text-sm">Balance: {{UserZroBalance.toFixed(1)}} ZRO</span>
			</div>

            
          </div>
        </div>

		<span class="">
			<img src="plus.svg" class="" width="40" height="40" alt="">
		</span>		

		<div class="px-4 py-2 border  flex flex-col">
          <!-- <span class="font-thin">-$</span> -->
          <div class="flex p-3 ml-auto">
          <button class="items-center flex mr-16 bg-gray-200 rounded-md px-4 py-1  uppercase" > <img src="eth.svg" class="mr-2 -ml-1 mt-1 " alt="" width="15" height="10">ETH</button>
			<div class="flex bg-gray-200 py-1 px-2">
		  <input 
            autocomplete="off"
            autocorrect="off"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="0.0"
            minlength="1"
            maxlength="79"
            spellcheck="false"
            class="text-right ml-auto bg-gray-200 p-1 focus:outline-none w-2/4 " 
			@keyup="getProportionalZroAmount()"
			v-model="ethAmount"
            />
			<span class="ml-auto self-center font-thin text-sm">Balance: {{UserEthBalance.toFixed(1)}} ETH</span>
			</div>

            
          </div>
        </div>

		<button @click="addLiquidity(ethAmount, zroAmount)" class="w-full bg-teal-600 hover:bg-teal-700 mt-4 rounded-md py-2  text-white" >Supply</button>

      </div>

	  <div v-if="currentTab == 'remove'" class="px-4 py-2 border  flex flex-col">
			<p class="font-thin">Your Liquidity</p>
			<span class="flex">
				<p class="font-semibold text-lg mt-2">Liquidity Points: </p>
				<p class="font-semibold text-lg mt-2 ml-auto">{{UserLpTokens}} ZETH</p>
			</span>

			<div class="w-full bg-gray-200 flex p-3 mt-1 ml-auto">
          <button class="flex mr-16 px-2 self-center font-semibold  capitalize" >Percentage To Remove</button>
			<div class="flex py-1 px-2">
		  <input 
            autocomplete="off"
            autocorrect="off"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="100%"
            minlength="1"
            maxlength="3"
            spellcheck="false"
            class="text-right ml-auto bg-gray-300 p-1 focus:outline-none w-3/4 " 
			v-model="lpPercentage"
			@keyup="calculateLPReturns()"
            />
			</div>

            
          </div>

		  <span class="">
			<img src="plus.svg" class="" width="40" height="40" alt="">
		</span>	

		<div class=" w-full bg-gray-200 flex p-3 mt-1 ml-auto">
          <button class="flex mr-16 px-2 self-center font-semibold  capitalize" >You will recieve</button>
			<div class="bg-gray-300 flex py-1 px-2">
				<img src="coin.svg" class="mr-2 -ml-1 mt-1 " alt="" width="15" height="10">
		  <input 
            autocomplete="off"
            autocorrect="off"
			disabled = "true"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="0"
            minlength="1"
            maxlength="3"
            spellcheck="false"
            class="text-right ml-auto bg-gray-300  p-1 focus:outline-none w-3/4 " 
			v-model="zroReturned"
            />
			</div>

			<div class="bg-gray-300 ml-5 flex py-1 px-2">
				<img src="eth.svg" class="mr-2 -ml-1 mt-1 " alt="" width="15" height="10">
		  <input 
            autocomplete="off"
            autocorrect="off"
			disabled = "true"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="0"
            minlength="1"
            maxlength="3"
            spellcheck="false"
            class="text-right ml-auto bg-gray-300  p-1 focus:outline-none w-3/4 "
			v-model="ethReturned" 
            />
			</div>

          </div>
		
            <button @click="removeLiquidity()" class="w-full bg-teal-600 hover:bg-teal-700 mt-4 rounded-md py-2  text-white" >Remove</button>
	  </div>
		</div>
    </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { DecentralizedExchange__factory } from "../../../../types/factories/contracts/Dex.sol/DecentralizedExchange__factory"
import { DecentralizedExchange } from "../../../../types/contracts/Dex.sol/DecentralizedExchange"
import { Zero__factory } from "../../../../types/factories/contracts/Zero__factory"
import { Zero } from "../../../../types/contracts/Zero"
import { ethers } from "ethers";
import { useToast } from "vue-toastification";
import constants from '../constants' 


const toast = useToast()
const currentTab = ref('add');
const currentAccount = ref("");
let DEX : DecentralizedExchange;
let ZERO_Contract : Zero;
let provider;
const ethAmount = ref();
const zroAmount = ref();
const UserLpTokens = ref(0);
const UserZroBalance = ref(0);
const UserEthBalance = ref(0)
const lpPercentage = ref(0);
const ethReturned = ref("")
const zroReturned = ref("")

const loadCurrentAccount = async() => {
	if (typeof window.ethereum !== 'undefined') {
		currentAccount.value = (await window.ethereum.request({ method: 'eth_requestAccounts' }))[0];
	}
	console.log("Current Account: " + currentAccount.value);
}

const loadContract = async () => {
	await loadCurrentAccount()
	provider = new ethers.providers.Web3Provider(
      window.ethereum,
  );

	if (currentAccount.value == "") {
		DEX = DecentralizedExchange__factory.connect(
		constants.dex_address,
		provider
		);
	} else {
		DEX =  DecentralizedExchange__factory.connect(
		constants.dex_address,
		provider.getSigner(currentAccount.value)
		);
  }
}
loadContract()

const loadZEROContract = async () => {
	await loadCurrentAccount()
	provider = new ethers.providers.Web3Provider(
      window.ethereum,
    );

	if (currentAccount.value == "") {
		ZERO_Contract = Zero__factory.connect(
		constants.zro_address,
		provider
		);
	} else {
		ZERO_Contract =  Zero__factory.connect(
		constants.zro_address,
		provider.getSigner(currentAccount.value)
		);
	await getUserBalances();
	calculateLPReturns()
  }
  
  console.log("Dex ZRO balance: " + ( Number((await ZERO_Contract.balanceOf(DEX.address)).toString() ) ) )
  console.log( "Dex ETH balance: " + ethers.utils.formatEther(await provider.getBalance(DEX.address)))
  console.log("Dex ts : " + await DEX.totalSupply())
  
}
loadZEROContract()

function toDecimals(amount : number) {
	return String(amount * (10 ** 18))
}

function fromDecimals(amount :string){
	return Number(amount) / (10 ** 18);
}

const getUserBalances = async() => {
	const tx = await DEX.balanceOf(currentAccount.value);
	UserLpTokens.value = Number(tx.toString()) / 10 ** 18;

	UserEthBalance.value = Number(ethers.utils.formatEther((await provider.getBalance(currentAccount.value)).toString()))
	UserZroBalance.value = Number(await ZERO_Contract.balanceOf(currentAccount.value)) / 10 ** 18
}

const getProportionalZroAmount = async() => {
	//No existing liquidity
	if ( Number(ethers.utils.formatEther(await provider.getBalance(DEX.address))) == 0 ) {
		return
	}
	zroAmount.value = 0 
	if (ethAmount.value <= 0 || !isFinite(ethAmount.value)) {
		return;
	}
  const ethInput = ethers.utils.parseEther(String(ethAmount.value))
  const tx = await DEX.calculateLPZROAmount(ethInput);
  zroAmount.value = fromDecimals(tx.toString())
  console.log("Proportional ZRO: " + tx.toString())
}

const getProportionalEthAmount = async() => {
	if ( Number(ethers.utils.formatEther(await provider.getBalance(DEX.address))) == 0 ) {
		return
	}
	ethAmount.value = 0;
	if (zroAmount.value <= 0 || !isFinite(zroAmount.value)) {
		return;
	}
	const zroInput = zroAmount.value
	const tx = await DEX.calculateLPETHAmount(toDecimals(zroInput));
	ethAmount.value = ethers.utils.formatEther(tx.toString())
	console.log("Proportional Eth: " + tx.toString())
}

const addLiquidity = async(ethAmount: number, zroAmount : number) => {
	
	const  zroAllowance = await ZERO_Contract.allowance(currentAccount.value, DEX.address);
	const formattedzroAllowance = zroAllowance.toString()
	console.log(formattedzroAllowance)
	if(Number(formattedzroAllowance) < zroAmount){
		const approve = await ZERO_Contract.approve(DEX.address, zroAmount.toString()  );
		await approve.wait(1);
		toast.success("Approval successful.... Waiting to deposit funds")
	}

	const parsedZroAmount =  BigInt(Number(toDecimals(zroAmount))).toString();

	const ethSent = ethers.utils.parseUnits(parsedZroAmount,"ether");
	console.log("Eth sent : " + ethSent)
	const tx = await DEX.addLiquidity(toDecimals(zroAmount), { value: ethSent })
	await tx.wait(1)
	toast.success("Liquidity Added");
	console.log(tx)
	await getUserBalances()
	clearInput()
	
}

function clearInput() {
	ethAmount.value = ""
	zroAmount.value = ""
}

const removeLiquidity = async() => {
	const _lpTokenAmount = Number((await DEX.balanceOf(currentAccount.value)).toString());
	const lpTokenPercentage = (_lpTokenAmount * lpPercentage.value) / 100;
	console.log(lpTokenPercentage.toString());
	
	const tx = await DEX.removeLiquidity(lpTokenPercentage.toString())
	await tx.wait(1);
	await getUserBalances()
	lpPercentage.value = 0;
	ethReturned.value = ""
	zroReturned.value = ""
	// console.log(tx)
}

const calculateLPReturns = async() => {
	if (lpPercentage.value == 0 || !isFinite(lpPercentage.value)) {
		return;
	}
	const totalSupply = Number((await DEX.totalSupply()).toString())
	const DEX_ETHBalance = Number((await provider.getBalance(DEX.address)).toString());
	const DEX_ZROBalance = Number((await ZERO_Contract.balanceOf(DEX.address)).toString());
	const _lpTokenAmount = Number((await DEX.balanceOf(currentAccount.value)).toString());

	const lpTokenPercentage = (_lpTokenAmount * lpPercentage.value) / 100;
	// console.log(_lpTokenAmount, DEXBalance, totalSupply);

	ethReturned.value =  ethers.utils.formatEther(String((lpTokenPercentage * DEX_ETHBalance) / totalSupply))
	zroReturned.value = String(fromDecimals(String((lpTokenPercentage * DEX_ZROBalance) / totalSupply)))
	// const ethReturned = (lp)
}

if (window.ethereum) {
  window.ethereum.on("accountsChanged", async function () {
   await loadContract();
   await loadZEROContract();
  });
}

</script>

<style>
.active {
	padding-left: 4rem;
    padding-right: 4rem;
	width: 100%;
	background-color: rgb(19 78 74 / 1);
	padding-top: 0.5rem;
    padding-bottom: 0.5rem;
	color: white;
}
.inactive{
	padding-left: 6rem;
    padding-right: 6rem;
	padding-top: 0.5rem;
    padding-bottom: 0.5rem;
	background-color: #fff;
	color: black;

}
</style>