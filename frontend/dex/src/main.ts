import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import Toast, { PluginOptions } from "vue-toastification";
import "vue-toastification/dist/index.css";


const app = createApp(App)

app.config.globalProperties.currentAcoount = "0x";


const toastOptions: PluginOptions = {
    transition: "Vue-Toastification__bounce",
    maxToasts: 20,
    newestOnTop: true
};

app.use(Toast, toastOptions);
app.use(router)
app.mount("#app")