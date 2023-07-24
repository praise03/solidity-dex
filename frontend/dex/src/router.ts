import { createWebHistory, createRouter } from "vue-router";
import Mint from "./components/Mint.vue";
import Dex from "./components/Dex.vue";
import Liquidity from "./components/Liquidity.vue"

const routes = [
    {
        path: '/pathMatch(.*)*',
        name: 'Error',
        component: Error
    },
    {
        path: "/",
        name: 'Mint',
        component: Mint
    },
    {
        path: "/dex",
        name: 'DEX',
        component: Dex
    },
    {
        path: "/liquidity",
        name: "Liquidity",
        component: Liquidity
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router