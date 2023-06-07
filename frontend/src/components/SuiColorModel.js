class SuiColorModel extends EventTarget {
    constructor(params = {}) {
        super();

        this.suiMaster = params.suiMaster;
        if (!this.suiMaster) {
            throw new Error('suiMaster is required');
        }

        this.isInitialized = false;

        this.pkg = null,
        this.objectStorage = null,
        this.topResponses = [];
        this.topMessages = {};

        this.packagesOnChains = {
            'sui:localnet': '0xb151b521dc50e4859b60f7f8e750a82592c995c5286514e29c0604c7c405a78f',
            'sui:devnet': '0x44ff454f5c49adfcc045fefaa6c93c21e36adc0b7cdb948836657a4078d872d5',
            'sui:testnet': '0x363a697a7977df8c3cf6272c47ea5df4e94749f92bc703861945b3290c5c0455',
            'sui:mainnet': '0x1e5eac6391bdcdf45d32a6f84de1778f98926585d69c871a6c2fa8f24d604e7c',
        };
    }

    static __instances = {};
    static bySuiMaster(suiMaster) {
        const suiMasterInstanceN = suiMaster.instanceN;
        if (SuiColorModel.__instances[suiMasterInstanceN]) {
            return SuiColorModel.__instances[suiMasterInstanceN];
        } else {
            const suiColorModel = new SuiColorModel({
                suiMaster: suiMaster,
            });
            SuiColorModel.__instances[suiMasterInstanceN] = suiColorModel;
            return suiColorModel;
        }
    }

    async setColor(params = {}) {
        const r = params.r;
        const g = params.g;
        const b = params.b;

        await this.initialize();
        if (!this.pkg) {
            return false;
        }

        const module = await this.pkg.getModule('suidouble_color');

        let method = 'mint';
        let moveParams = ['test', r, g, b];

        try {
            let result = await module.moveCall(method, moveParams);
            for (const item of result.created) {
                if (item.typeName == 'Color') {
                    if (item.fields.r === undefined) {
                        // it's ok on chain. We may get them from next block?
                        item.fields.r = r;
                        item.fields.g = g;
                        item.fields.b = b;
                    }

                    return item;
                }
            }
        } catch (e) {
            console.error(e);
        }

        return false;
    }

    async load() {
        await this.initialize();
        if (!this.pkg) {
            return [];
        }

        const module = await this.pkg.getModule('suidouble_color');
        const eventsResponse = await module.fetchEvents({eventTypeName: 'ColorCreated', order: 'descending'});

        const ret = [];
        for (const ev of eventsResponse.data) {
            if (ev.parsedJson && ev.parsedJson.id) {
                ret.push({
                    address: ev.parsedJson.id,
                    fields: {
                        r: ev.parsedJson.r,
                        g: ev.parsedJson.g,
                        b: ev.parsedJson.b,
                    }
                });
            }
        }

        return ret;
    }

    async isSupported() {
        await this.initialize();
        if (!this.pkg) {
            return false;
        }

        const module = await this.pkg.getModule('suidouble_color');
        if (!module) {
            return false;
        }

        return true;
    }

    async initialize() {
        if (this.isInitialized) {
            return true;
        }

        const currentChain = this.suiMaster.signer.getCurrentChain();
        const packageId = this.packagesOnChains[currentChain];

        if (!packageId) {
            this.isInitialized = true;
            this.emit('clear', {supported: false, currentChain: currentChain});
            return false;
        } else {
            this.emit('clear', {supported: true});
        }

        const pkg = this.suiMaster.package({
            id: packageId,
        });
        this.pkg = pkg;

        // try {

        // } catch (e) {
        //     console.error(e);
        // }
    }

	emit(eventType, data) {
		try {
			this.dispatchEvent(new CustomEvent(eventType, { detail: data }));
		} catch (e) {
			console.error(e);
		}
	}
}

module.exports = SuiColorModel;