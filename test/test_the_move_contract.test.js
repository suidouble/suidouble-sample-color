'use strict'

const t = require('tap');
const { test } = t;
const path = require('path');

const { SuiTestScenario } = require('suidouble');

let testScenario = null;

test('initialization', async t => {
    testScenario = new SuiTestScenario({
        path: path.join(__dirname, '../move/suidouble_color/'),
        debug: false,
    });

    await testScenario.begin('admin');
    await testScenario.init();

    t.equal(testScenario.currentAs, 'admin');
});

test('minting a color', async t => {
	// t.plan(4); // optional to be sure everything executed inside testScenario.nextTx

    await testScenario.nextTx('somebody', async()=>{
        await testScenario.moveCall('suidouble_color', 'mint', ['test string', 255,255,255]);
        const color = testScenario.takeFromSender('Color');

        t.ok(color.address); // there should be some address
        t.ok(`${color.address}`.indexOf('0x') === 0); // adress is string starting with '0x'

        t.equal(color.fields.r, 255);
        t.equal(color.fields.g, 255);
        t.equal(color.fields.b, 255);
    });


    await testScenario.nextTx('anybody', async()=>{
        // can query a list of events
    });
});


test('finishing the test scenario', async t => {
    await testScenario.end();
});
