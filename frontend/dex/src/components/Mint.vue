<template>
  <div class="p-1 h-[50vh] flex items-center justify-center sm:h-screen">
    <form @submit.prevent="" class="w-full max-w-lg">
      <div class="flex flex-wrap -mx-3 mb-6">
        <div class="w-full px-3">
          <label
            class="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2"
          >
            $Zro Amount
          </label>
          <input
            v-model="amount"
            class="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
            type="number"
            min="1"
            max="1000"
            placeholder="1000"
          />
          <p class="text-gray-600 text-xs italic">
            Input the amount of tokens you'd like to mint. Max: 1000
          </p>
        </div>
      </div>
      <input
        type="submit"
        value="Mint"
        class="px-12 py-3 animate-pulse rounded-md cursor-pointer hover:bg-teal-500 bg-teal-300"
        @click="mintTokens(amount)"
      />
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import constants from "../constants";
import { Zero__factory } from "../../../../types/factories/contracts/Zero__factory";
import { Zero } from "../../../../types/contracts/Zero";
import { ethers } from "ethers";
import { useToast } from "vue-toastification";

const toast = useToast();
const currentAccount = ref("");
const amount = ref(0);
let ZERO_Contract: Zero;
let provider;

const loadCurrentAccount = async () => {
  if (typeof window.ethereum !== "undefined") {
    currentAccount.value = (
      await window.ethereum.request({ method: "eth_requestAccounts" })
    )[0];
  }
  console.log("Current Account: " + currentAccount.value);
};

const loadContract = async () => {
  await loadCurrentAccount();
  provider = new ethers.providers.Web3Provider(window.ethereum);

  if (currentAccount.value == "") {
    ZERO_Contract = Zero__factory.connect(constants.zro_address, provider);
  } else {
    ZERO_Contract = Zero__factory.connect(
      constants.zro_address,
      provider.getSigner(currentAccount.value)
    );
  }

  console.log((await ZERO_Contract.balanceOf(currentAccount.value)).toString());
};
loadContract();

const mintTokens = async (amount: number) => {
  // toast.success("Success toast");
  if (amount != 0 && currentAccount.value != "") {
    const amountinDecimals = String(amount * 10 ** 18);
    console.log(amountinDecimals);
    const mintTx = await ZERO_Contract.mint(
      currentAccount.value,
      amountinDecimals
    );
    await mintTx.wait(1);
    toast(
      "Successfully minted " +
        amount +
        " tokens to address: " +
        currentAccount.value
    );
  }
};

if (window.ethereum) {
  window.ethereum.on("accountsChanged", function () {
    loadContract();
  });
}
</script>

<style></style>
