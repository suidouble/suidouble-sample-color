<template>

    <div class="colorwave_content " :class="{colorwave_content_inline: inline}">
        <h2 :style="{'-webkit-text-stroke-color': strokeColor}">sui.double</h2>
        <h2 :style="{color: backColor}">sui.double</h2>
    </div>

</template>

<style lang="css">
    .colorwave_content {
        position: relative;
        clear: both;
        height: 76px;
        margin: 0px auto;
        width: 1px;
        user-select: none;
    }

    .colorwave_content h2 {
        margin: 0;
        padding: 0;
        color: var(--q-primary);
        font-size: 60px;
        font-weight: 500;
        line-height: 60px;
        position: absolute;
        transform: translate(-50%, 0%);
    }

    .colorwave_content_inline h2 {
        transform: translate(0%, 0%);
    }
    .colorwave_content_inline {
        height: 60px;
    }

    .colorwave_content h2:nth-child(1) {
        color: transparent;
        transition: all 4s ease-in;
        -webkit-text-stroke: 1px var(--q-primary);
    }

    .colorwave_content h2:nth-child(2) {
        color: rgba(54, 54, 190, 0.082);
        transition: color 4s ease-in;
        animation: colorwave_animate 4s ease-in-out infinite;
    }

    @keyframes colorwave_animate {
        0%,
        100% {
            clip-path: polygon(
                0% 45%,
                16% 44%,
                33% 50%,
                54% 60%,
                70% 61%,
                84% 59%,
                100% 52%,
                100% 100%,
                0% 100%
            );
        }

        50% {
            clip-path: polygon(
                0% 60%,
                15% 65%,
                34% 66%,
                51% 62%,
                67% 50%,
                84% 45%,
                100% 46%,
                100% 100%,
                0% 100%
            );
        }
    }

</style>

<script>

export default {
	name: 'ColorWave',
	props: {
        inline: {
            type: Boolean,
            default: false,
        },
	},
	data() {
		return {
            color: null,
		}
	},
    emits: [],
	watch: {
		'$store.color.color': function(){
			this.checkStore();
		},
	},
	computed: {
        backColor() {
            if (this.color) {
                return this.color;
            }
            return 'rgba(54, 54, 190, 0.33)';
        },
        strokeColor() {
            if (this.color) {
                return 'var(--q-primary)';
            } else {
                return 'rgba(54, 54, 190, 0.33)';
            }
        }
	},
	components: {
	},
	methods: {
        setColor(color) {
            this.color = color;
            this.$store.color.setColor(color);
        },
        checkStore() {
            this.color = this.$store.color.color;
        },
	},
	beforeMount: function() {
	},
	mounted: async function() {
	},
}
</script>
