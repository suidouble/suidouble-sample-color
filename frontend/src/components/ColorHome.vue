<template>

    <div class="text-center">
        <ColorWave ref="colorWave" />

        <q-btn type="button" ripple color="primary" :loading="isLoading" @click="onClickPickColor">Change Color</q-btn>

        <SignInWithSui :defaultChain="defaultChain" @wrongchain="onWrongChain" @suiMaster="onSuiMaster" ref="sui" :visible="false" />

        <q-dialog v-model="showColorDialog">
            <q-card>
                <q-card-section>
                    <q-color v-model="selectedColor" format-model="rgb" no-header no-footer style="width: 250px;" />
                    <div class="text-center">
                        <q-btn type="button" :disable="!selectedColor" ripple color="primary" :loading="isLoading" @click="onClickSetColor">Set Color</q-btn>
                    </div>
                </q-card-section>
            </q-card>
        </q-dialog>

        <q-banner class="bg-primary text-white q-mt-lg" v-if="isNotSupported">
            Unfortunately, chain {{ notSupportedChainName }} is not supported. Try to switch to different one (maybe devnet?) in your wallet.
        </q-banner>
        <div class="q-pt-md row items-start q-col-gutter-xs">
            <template v-for="(color) in colors" v-bind:key="color.address">
                <ColorHomeNFT :color="color" :suiMaster="suiMaster" />
            </template>
        </div>

    </div>

</template>

<style lang="css">

</style>

<script>
import { SignInWithSui } from 'vue-sui';
import ColorWave from '../components/ColorWave.vue';
import SuiColorModel from './SuiColorModel.js';
import ColorHomeNFT from './ColorHomeNFT.vue';

export default {
	name: 'ColorHome',
	props: {
        defaultChain: {
            default: 'sui:mainnet',
            type: String,
        },
	},
	data() {
		return {
            isLoading: true,
            suiMaster: null,
            colorModel: null,

            showColorDialog: false,
            selectedColor: null,

            colors: [],

            isNotSupported: false,
            notSupportedChainName: null,

            // defaultChain: 'sui:mainnet',
		}
	},
    emits: [],
	watch: {
	},
	computed: {
	},
	components: {
        SignInWithSui,
        ColorWave,
        ColorHomeNFT,
	},
	methods: {
        onWrongChain(tryingTo) {
            this.$q.notify('Please switch to '+this.defaultChain+' in wallet settings. Currently it is '+tryingTo);
        },
        async notifyAboutWrongConnectedChain() {
            this.$q.notify('Wrong chain name. Please switch to '+this.defaultChain+' in wallet settings');
        },
        async onSuiMaster(suiMaster) {
            console.error('suiMaster.connectedChain', suiMaster);
            if (suiMaster.connectedChain != this.defaultChain) {
                this.notifyAboutWrongConnectedChain();
                return false;
            }

            this.suiMaster = suiMaster;
            if (this.colorModel) {
                this.colorModel.unsubscribe();
            }
            this.colorModel = SuiColorModel.bySuiMaster(this.suiMaster);

            if (!this.__lastConnectedChain || this.__lastConnectedChain !== this.suiMaster.connectedChain) {
                this.__colorsAddresses = {};
                this.colors = [];
                this.__lastConnectedChain = this.suiMaster.connectedChain;
            }

            clearTimeout(this.__loadTimeout);
            this.__loadTimeout = setTimeout(()=>{
                this.load();
            }, 500);
        },
        async load() {
            this.isLoading = true;

            this.isNotSupported = !(await this.colorModel.isSupported());
            this.notSupportedChainName = this.suiMaster.connectedChain;

            if (!this.isNotSupported) {
                if (!this.__colorsAddresses) {
                    this.__colorsAddresses = {};
                }

                const colors = await this.colorModel.load();

                if (colors.length) {
                    let colorAdded = null;
                    for (const color of colors) {
                        if (!this.__colorsAddresses[color.address]) {
                            this.colors.push(color);
                            this.__colorsAddresses[color.address] = true;

                            if (!colorAdded) {
                                colorAdded = color;
                            }
                        }
                    }

                    if (colorAdded) {
                        const color = 'rgb('+colorAdded.fields.r+','+colorAdded.fields.g+','+colorAdded.fields.b+')';
                        this.$refs.colorWave.setColor(color);
                    }
                }

                await this.colorModel.subscribe((colorAdded)=>{
                    if (!this.__colorsAddresses[colorAdded.address]) {
                        this.colors.unshift(colorAdded);
                        this.__colorsAddresses[colorAdded.address] = true;
                        const color = 'rgb('+colorAdded.fields.r+','+colorAdded.fields.g+','+colorAdded.fields.b+')';

                        if (this.$refs.colorWave) {
                            this.$refs.colorWave.setColor(color);
                        }
                    }
                });
            }
            this.isLoading = false;

        },
        onClickPickColor() {
            this.selectedColor = "rgb("+Math.floor(Math.random()*255)+","+Math.floor(Math.random()*255)+","+Math.floor(Math.random()*255)+")";
            this.showColorDialog = true;
        },
        async onClickSetColor() {
            const r = parseInt(this.selectedColor.split('(')[1].split(',')[0].trim(), 10);
            const g = parseInt(this.selectedColor.split(',')[1].trim(), 10);
            const b = parseInt(this.selectedColor.split(',')[2].trim(), 10);

            let isOk = false;
            if ((r || r === 0) && (g || g === 0) && (b || b === 0)) {
                isOk = true;
            }

            if (!isOk) {
                return;
            }

            this.showColorDialog = false;
            this.selectedColor = null;

            let suiMaster = null;
            try {
                suiMaster = await this.$refs.sui.requestConnectedSuiMaster(this.defaultChain);
            } catch (e) {
                this.notifyAboutWrongConnectedChain();
                return false;
            }

            await suiMaster.initialize();
            this.suiMaster = suiMaster;
            this.colorModel = SuiColorModel.bySuiMaster(this.suiMaster);

            const added = await this.colorModel.setColor({r: r, g: g, b: b});
            console.error('added', added);

            if (added) {
                const color = 'rgb('+added.fields.r+','+added.fields.g+','+added.fields.b+')';
                console.log('setting color to ', color);
                this.$refs.colorWave.setColor(color);

                if (!this.__colorsAddresses[added.address]) {
                    this.colors.unshift(added);
                    this.__colorsAddresses[added.address] = true;
                }
            }

            // await suiMaster.initialize();
            // alert(suiMaster.connectedChain +' - '+ suiMaster.address);
        }
	},
	beforeMount: function() {
	},
	mounted: async function() {
        this.isLoading = true;
        this.$refs.sui.requestSuiMaster();
	},
}
</script>
