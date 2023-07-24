<template>
  <div>
    <div class="p-1 h-[50vh] flex flex-col items-center justify-center sm:h-screen">
     <div>
     <div class="">
        <span class="font-thin">Sell</span>
        <div class="px-4 py-2 border rounded-md flex flex-col">
          <span class="font-thin">-$</span>
          <div class="flex">

          <input 
            autocomplete="off"
            autocorrect="off"
            type="text"
            pattern="^[0-9]*[.,]?[0-9]*$"
            placeholder="0.0"
            minlength="1"
            maxlength="79"
            spellcheck="false"
            class="mr-24 focus:outline-none w-3/4 " 
			@keyup="getOutputAmount()"
			v-model="inputAmount"
            />

            <button class="flex bg-gray-200 rounded-md px-4 py-1 uppercase" > <img v-if="token == 'eth'" class="-ml-2 mr-2" src="eth.svg" width="15" height="10" alt="" srcset=""> <img v-if="token == 'zro'" src="coin.svg" class="mt-[1.9px] mr-1 -ml-2" alt="" width="20" height="15">  {{token}}</button>
          </div>
        </div>
      </div>

      <button @click="switchPair" class="p-1 ml-[50%] rounded-sm text-2xl my-8 text-white"> <img src="swap.svg" width="20" height="20"  alt=""> </button>

        <div class="">
            <span class="font-thin">Buy</span>
            <div class="px-4 py-2 border rounded-md flex flex-col">
            <span class="font-thin">-$</span>
            <div class="flex">

            <input 
                autocomplete="off"
                disabled="true"
                autocorrect="off"
                type="text"
                pattern="^[0-9]*[.,]?[0-9]*$"
                placeholder="0.0"
                minlength="1"
                maxlength="79"
                spellcheck="false"
                class="mr-24 focus:outline-none w-3/4 " 
				v-model="output"
                />
                <button class="flex bg-gray-200 rounded-md px-4 py-1 uppercase" > <img v-if="token == 'zro'" class="-ml-2 mr-2" src="eth.svg" width="15" height="12" alt="" srcset=""> <img v-if="token == 'eth'" src="coin.svg" class="mt-[1.9px] mr-1 -ml-2" alt="" width="20" height="15">
                 {{token == 'zro' ? 'eth' : 'zro'}}</button>
        

            </div>
            </div>
        </div>
        <button @click="swapTokens()" class="w-full bg-teal-600 hover:bg-teal-700 mt-4 rounded-md py-2  text-white" >Swap</button>
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
import { parse } from 'dotenv';


const toast = useToast()
const currentAccount = ref("");
let DEX : DecentralizedExchange;
let ZERO_Contract : Zero;
let provider;
const token = ref('zro');
const inputAmount = ref(0);
const output = ref("")

const switchPair = () => {
    token.value == 'zro' ? token.value = 'eth' : token.value = 'zro'
}

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
  }
  
  console.log("Dex ZRO balance: " + ( Number((await ZERO_Contract.balanceOf(DEX.address)).toString() ) ))
  console.log( "Dex ETH balance: " + (ethers.utils.formatEther(await provider.getBalance(DEX.address))))
  
}
loadZEROContract()

function toDecimals (amount:number) {
	return String(amount * (10 ** 18));
}

function fromDecimals(amount :string){
	return Number(amount) / (10 ** 18);
}


const getOutputAmount = async() => {
	if (inputAmount.value == 0 || !isFinite(inputAmount.value)) {
		return;
	}
	if (token.value == 'zro') {
		const parsedInput = toDecimals((inputAmount.value))
		const inputReserve = String(Number(await ZERO_Contract.balanceOf(DEX.address)));
		// console.log(inputReserve)
		const outputReserve = await provider.getBalance(DEX.address)
		const outputAmount = await DEX.forecastOutputAmountfromSwap(parsedInput, inputReserve, outputReserve)
		output.value = ethers.utils.formatEther(outputAmount)	
	}
	else{
		const parsedInput = ethers.utils.parseEther(inputAmount.value.toString())
		const inputReserve = await provider.getBalance(DEX.address);
		// console.log(parsedInput)
		const outputReserve = String(Number(await ZERO_Contract.balanceOf(DEX.address)));
		const outputAmount = await DEX.forecastOutputAmountfromSwap(parsedInput, inputReserve, outputReserve)
		output.value = String(fromDecimals(outputAmount.toString()))
	}
	
}

const swapTokens = async() => {
	if (inputAmount.value == 0 || !isFinite(inputAmount.value)) {
		return;
	}
	if (token.value == "zro") {
		const parsedInput = toDecimals(inputAmount.value)
		// console.log(parsedInput)
		const tx = await DEX.swapZROtoETH(parsedInput)
		await tx.wait(1)	
	}else{
		const parsedInput = ethers.utils.parseEther(inputAmount.value.toString())
		// console.log(parsedInput)
		const tx = await DEX.swapETHtoZRO({value: parsedInput})
		await tx.wait(1)
	}
	toast.success('Swap Successful');
	console.log("Dex ZRO balance after swap: " + ( Number((await ZERO_Contract.balanceOf(DEX.address)).toString() ) ))
 	console.log( "Dex ETH balance after swap: " + (ethers.utils.formatEther(await provider.getBalance(DEX.address))))
	inputAmount.value = 0
	output.value = "";
}

if (window.ethereum) {
  window.ethereum.on("accountsChanged", async function () {
   await loadContract();
   await loadZEROContract();
  });
}

</script>
