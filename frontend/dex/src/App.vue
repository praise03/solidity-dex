<template>
  <div>
    <nav
      class="bg-white border-gray-200 px-2 sm:px-4 py-2.5 rounded dark:bg-gray-900"
    >
      <div
        class="container flex flex-wrap justify-between items-center mx-auto"
      >
        <a href="#" class="p-2 flex items-center">
          <img src="/vite.svg" class="mr-3 h-6 sm:h-9" alt="Logo" />
          <span
            @click="router.push('/')"
            class="self-center text-xl font-semibold whitespace-nowrap dark:text-white"
            >ZSWAP</span
          >
        </a>
        <div class="flex md:order-2">
          <button
            @click="router.push('/mint/' + currentAccount)"
            v-if="currentAccount !== null"
            type="button"
            class="text-white bg-teal-300 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-3 md:mr-0 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            {{ currentAccount }}
          </button>
          <button
            v-else
            @click="connectWallet"
            type="button"
            class="text-white bg-teal-500 hover:bg-teal-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-3 md:mr-0 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Connect
          </button>
        </div>
        <div
          class="justify-between items-center w-full md:flex md:w-auto md:order-1"
          id="navbar-cta"
        >
          <ul
            class="flex flex-col p-4 mt-4 bg-gray-50 rounded-lg border border-gray-100 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700"
          >
            <li>
              <a
                @click="router.push('/')"
                href="#"
                class="block py-2 pr-4 pl-1 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 md:dark:hover:text-white dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700"
                >Mint</a
              >
            </li>
            <li>
              <a
                @click="router.push('/dex')"
                href="#"
                class="block py-2 pr-4 pl-1 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 md:dark:hover:text-white dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700"
                >Swap</a
              >
            </li>
            <li>
              <a
                @click="router.push('/liquidity')"
                href="#"
                class="block py-2 pr-4 pl-1 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 md:dark:hover:text-white dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700"
                >Liquidity</a
              >
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <router-view></router-view>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { utils } from "ethers";
import { useToast } from "vue-toastification";

const toast = useToast()

const router = useRouter();
const currentAccount = ref("");
const accountConnected = ref(false);

//sepolia
const targetNetworkId = "0xaa36a7";

const connectWallet = async () => {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      toast.error("Please install metamask to use full features");
      return;
    }
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    console.log(accounts[0] + "connected");
    currentAccount.value = utils.getAddress(accounts[0]);
  } catch (error) {
    console.log(error);
  }
};

const checkIfAccountConnected = async () => {
  try {
    const { ethereum } = window;
    if (!ethereum) {
      toast.error("Please install metamask to use full features");
      return;
    }

    if (!await checkNetwork()) {
    	toast.error("You need to switch to the Sepolia Testnet");
    	switchNetwork();
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });

    if (accounts.length !== 0) {
      currentAccount.value = utils.getAddress(accounts[0]);

      accountConnected.value = true;
    } else {
      accountConnected.value = false;
    }
  } catch (error) {
    console.log(error);
  }
};

const checkNetwork = async () => {
  if (window.ethereum) {
    const currentChainId = await window.ethereum.request({
      method: "eth_chainId",
    });

    if (currentChainId == targetNetworkId) return true;
    return false;
  }
};

const switchNetwork = async () => {
  await window.ethereum.request({
    method: "wallet_switchEthereumChain",
    params: [{ chainId: targetNetworkId }],
  });
  window.location.reload();
};

if (window.ethereum) {
  window.ethereum.on("accountsChanged", function () {
    checkIfAccountConnected();
  });
}
if (window.ethereum) {
  window.ethereum.on("chainChanged", function () {
    checkIfAccountConnected();
  });
}

checkIfAccountConnected();
</script>
