<template>

    <q-card class="color-home-nft-card text-left col-4" square flat>
        <q-card-section :style="{backgroundColor: background, color: textColor}">
            <div class="text-subtitle2">
                <q-btn round color="primary" size="xs" flat icon="open_in_new" style="float: right" @click="openOnExplorer" />
                {{ displayAddress }}
            </div>
            
        </q-card-section>
    </q-card>

</template>

<style lang="css">
</style>

<script>

export default {
	name: 'ColorHomeNFT',
	props: {
        suiMaster: {
            type: Object,
            default: null,
        },
        color: {
            type: Object,
            default: null,
        },
	},
	data() {
		return {
			isLoading: false,
            responses: [],
            responsesDict: {},
		}
	},
    emits: [],
	watch: {
	},
	computed: {
		displayAddress() {
			return (''+this.color.address).substr(0,6)+'...'+(''+this.color.address).substr(-4);
		},
        background: function() {
            console.log('fields', this.color.fields, this.color);
            return 'rgb('+this.color.fields.r+','+this.color.fields.g+','+this.color.fields.b+')';
        },
        textColor: function() {
            let sum = this.color.fields.r + this.color.fields.g + this.color.fields.b;
            if (sum / 3 < 127) {
                return 'white !important';
            } else {
                return 'black !important';
            }
        }
	},
	components: {
	},
	methods: {
        openOnExplorer() {
            let network = 'mainnet';
            try {
                network = (''+this.suiMaster.signer.getCurrentChain()).split('sui:').join('');
                network = network.split('localnet').join('local');
            } catch (e) {
                console.error(e);
            }

            window.open('https://suiexplorer.com/object/'+this.color.address+'?network='+network, '_blank');
        },  
	},
	beforeMount: function() {
	},
	mounted: async function() {
	},
}
</script>
