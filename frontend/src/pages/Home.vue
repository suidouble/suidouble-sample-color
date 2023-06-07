<template>

  <div>
    <div class="row">
        <div class="col-12 col-md-4">
            <p>Sample demo application of <a href="https://github.com/suidouble/suidouble">suidouble</a> library components for interaction with <a href="https://sui.io" target="_blank">Sui</a> blockchain.</p>

            <p>This dapp lets user switch logo color and stores the value on the blockchain, providing little NFT as a reward.</p>

            <p>Also it demonstrate suidouble's SUI event subscription. Logo color is updated for all users as soon as you mint Color NFT.</p>

            <p>Available on 
                <a href="#" @click="switchTo('sui:mainnet')" :class="{active_one: (chain == 'sui:mainnet')}">mainnet</a>, 
                <a href="#" @click="switchTo('sui:devnet')"  :class="{active_one: (chain == 'sui:devnet')}">devnet</a> and 
                <a href="#" @click="switchTo('sui:testnet')"  :class="{active_one: (chain == 'sui:testnet')}">testnet</a>.</p>

            <p>Check out on github:</p>

            <ul>
                <li><a href="https://github.com/suidouble/suidouble-sample-color/blob/main/move/suidouble_color/sources/suidouble_color.move">Sui Move contract source code</a></li>
                <li><a href="https://github.com/suidouble/suidouble">suidouble library</a></li>
                <li><a href="https://github.com/suidouble/suidouble-sample-color">this dapp source code</a></li>
            </ul>
        </div>
        <div class="col-12 col-md-8">
            <div class="text-center">
                <ColorHome :defaultChain="chain" v-if="chain" />
            </div>
        </div>
    </div>



  </div>

</template>

<script>
import ColorHome from '../components/ColorHome.vue';

export default {
	name: 'Home',
    path: '/',
	props: {
	},
    components: {
        ColorHome,
    },
	data() {
		return {
            chain: 'sui:mainnet',
		}
	},
    watch: {
    },
	methods: {
        async switchTo(chainName) {
            this.chain = null;
            await new Promise((res)=>setTimeout(res, 50));
            this.chain = chainName;
        }
	},
    computed: {
    },
    beforeMount() {
    },
    mounted() {
    },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
    h6 {
        font-size: 16px;
        font-weight: bold;
        margin: 0 0 16px 0;
    }

    h5 {
        margin: 0 0 16px 0;
    }

    .active_one {
        font-weight: bold;
    }

</style>

