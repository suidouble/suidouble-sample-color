<template>

	<q-btn type="button" ripple color="primary" :loading="isLoading" @click="onClick" v-if="visible">
		<span v-if="!connectedAddress">Connect with Sui</span>
		<span v-if="connectedAddress">Connected as {{ displayAddress }} ({{ connectedChain }})</span>
	</q-btn>

    <q-dialog v-model="showAdaptersDialog" position="top">
        <q-card style="width: 50%;">
            <!-- <q-card-section>
            <div class="text-h6">Alert</div>
            </q-card-section> -->
            <q-card-section>
                <q-list>
                    <template v-for="(adapter, index) in adapters" v-bind:key="index">
                        <q-item
                            clickable
                            v-ripple
                            @click="onAdapterClick(adapter)"
                            v-if="adapter.isDefault || adapter.okForSui"
                            :class="{not_installed: (adapter.isDefault)}"
                            >
                            <q-item-section avatar><q-img :src="adapter.icon" /></q-item-section>
                            <q-item-section class="row"><span color="text-primary">{{ adapter.name }}</span></q-item-section>
                        </q-item>
                    </template>
                </q-list>
            </q-card-section>
        </q-card>
    </q-dialog>

    <SuiAsync flush :defaultChain="defaultChain" @suiMaster="onSuiMaster" @loaded="onLibsLoaded" @connected="onConnected" @disconnected="onDisconnected" v-if="libsRequested" ref="sui"/>

</template>

<style lang="css" scoped>
    .not_installed {
        opacity: 0.6;
    }
</style>

<script>
import SuiAsync from 'shared/components/AsyncComponents/SuiAsync';

export default {
	name: 'SignInWithSui',
    emits: ['suiMaster'],
	props: {
        defaultChain: {
            default: 'sui:devnet',
            type: String,
        },
        auto: {
            default: false,
            type: Boolean,
        },
        visible: {
            default: true,
            type: Boolean,
        },
	},
	data() {
		return {
			isLoading: false,
            libsRequested: false,
            showAdaptersDialog: false,

            adapters: [],
            connectedAddress: null,
            connectedChain: null,

            suiMaster: null,
		}
	},
	watch: {
	},
	computed: {
		displayAddress() {
			return (''+this.connectedAddress).substr(0,6)+'...'+(''+this.connectedAddress).substr(-4);
		},
	},
	components: {
        SuiAsync,
	},
	methods: {
        /**
         * SuiMaster instance updated
         * @param {SuiMaster} suiMaster 
         */
        onSuiMaster(suiMaster) {
            this.suiMaster = suiMaster;
            this.$emit('suiMaster', suiMaster);

            if (this.__suiMasterPromise) {
                if (this.suiMaster) {
                    this.__suiMasterPromiseResolver();
                    this.__suiMasterPromise = null;
                }
            }
            if (this.__connectedSuiMasterPromise) {
                if (this.isSuiMasterConnected()) {
                    this.__connectedSuiMasterPromiseResolver();
                    this.__connectedSuiMasterPromise = null;
                }
            }
        },
        isSuiMasterConnected(requireChainName = null) {
            if (this.suiMaster && this.suiMaster.address) {
                if (requireChainName && this.suiMaster.connectedChain != requireChainName) {
                    return false;
                }
                return true;
            } else if (this.suiMaster && this.suiMaster.signer && this.suiMaster.signer.connectedAddress) {
                // backward compatible
                if (requireChainName && this.suiMaster.signer.connectedChain != requireChainName) {
                    return false;
                }
                return true;
            }

            return false;
        },
        async onAdapterClick(adapter) {
            if (adapter.isDefault && !adapter.isInstalled) {
                window.open(adapter.getDownloadURL(), '_blank');
                return false;
            }

            this.isLoading = true;
            this.showAdaptersDialog = false;
            await this.$refs.sui.suiInBrowser.connect(adapter);
            this.isLoading = false;
        },
        async requestSuiMaster() {
            if (this.suiMaster) {
                return this.suiMaster;
            }

            await this.requestLibs();
            await new Promise((res)=>{ setTimeout(res, 200); }); // let providers check if we are already connected

            if (this.suiMaster) {
                return this.suiMaster;
            }

            if (this.__suiMasterPromise) {
                await this.__suiMasterPromise;
                
                if (this.suiMaster) {
                    return this.suiMaster;
                } else {
                    throw new Error('can not get suiMaster');
                }
            }

            this.__suiMasterPromiseResolver = null;
            this.__suiMasterPromise = new Promise((res)=>{
                this.__suiMasterPromiseResolver = res;
            });

            await this.__suiMasterPromise;

            if (this.suiMaster) {
                return this.suiMaster;
            } else {
                throw new Error('can not get suiMaster');
            }
        },
        async requestConnectedSuiMaster(requireChainName = null) {
            if (this.isSuiMasterConnected(requireChainName)) {
                return this.suiMaster;
            }

            await this.requestLibs();
            await new Promise((res)=>{ setTimeout(res, 200); }); // let providers check if we are already connected

            if (this.isSuiMasterConnected(requireChainName)) {
                return this.suiMaster;
            }

            this.isLoading = true;
            if (this.__connectedSuiMasterPromise) {
                await this.__connectedSuiMasterPromise;
                this.isLoading = false;
                
                if (this.isSuiMasterConnected(requireChainName)) {
                    return this.suiMaster;
                } else {
                    throw new Error('can not get connection');
                }
            }

            this.__connectedSuiMasterPromiseResolver = null;
            this.__connectedSuiMasterPromise = new Promise((res)=>{
                this.__connectedSuiMasterPromiseResolver = res;
            });

            this.showAdaptersDialog = true;

            await this.__connectedSuiMasterPromise;

            this.isLoading = false;

            if (this.isSuiMasterConnected(requireChainName)) {
                return this.suiMaster;
            } else {
                throw new Error('can not get connection');
            }
        },
        async onClick() {
            this.isLoading = true;
            await this.requestLibs();
            await new Promise((res)=>{ setTimeout(res, 200); }); // let providers check if we are already connected

            if (!this.connectedAddress) {
                this.showAdaptersDialog = true;
            }

            this.isLoading = false;
        },
		async initialize() {
            if (this.auto) {
                this.isLoading = true;
                await this.requestLibs();
                this.isLoading = false;
            }
		},
        async requestLibs() {
            this.libsRequested = true;
            await this.__libsRequestedPromise;
            this.adapters = this.$refs.sui.adapters;
        },
        onLibsLoaded() {
            this.__libsRequestedPromiseResolver();
        },
        onConnected() {
            this.connectedAddress = this.$refs.sui.suiInBrowser.connectedAddress;
            this.connectedChain = this.$refs.sui.suiInBrowser.connectedChain;
        },
        onDisconnected() {
            this.connectedAddress = null;
        },
	},
	beforeMount: function() {
        this.__libsRequestedPromiseResolver = null;
        this.__libsRequestedPromise = new Promise((res)=>{
            this.__libsRequestedPromiseResolver = res;
        });
	},
	mounted: async function() {
		this.initialize();
	},
}
</script>
