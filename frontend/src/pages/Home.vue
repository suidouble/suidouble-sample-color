<template>

  <div>
    <div class="row">
        <div class="col-12 col-md-4">
            <p>Sample demo application of <a href="https://github.com/suidouble/suidouble">suidouble</a> library components for interaction with <a href="https://sui.io" target="_blank">Sui</a> blockchain.</p>

            <p>This dapp lets user switch logo color and stores the value on the blockchain, providing little NFT as a reward.</p>

            <p>Available on mainnet, devnet and testnet. You can switch the chain in wallet extension.</p>

            <p>Check out on github:</p>

            <ul>
                <li><a href="https://github.com/suidouble/suidouble-sample-color/blob/main/move/suidouble_color/sources/suidouble_color.move">Sui Move contract source code</a></li>
                <li><a href="https://github.com/suidouble/suidouble">suidouble library</a></li>
                <li><a href="https://github.com/suidouble/suidouble-sample-color">this dapp source code</a></li>
            </ul>
        </div>
        <div class="col-12 col-md-8">
            <div class="text-center">
                <ColorHome />
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
		}
	},
    watch: {
    },
	methods: {
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

</style>

