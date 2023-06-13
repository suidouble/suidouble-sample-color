# suidouble-sample-color

Very simple chat application to demonstrate [suidouble](https://github.com/suidouble/suidouble) library in action, focusing on events (fetch and subscribe)

- [check it out online](https://suidouble-color.herokuapp.com/).

Stack: Sui + suidouble + Vue. Ready to be deployed to Heroku

Code pieces to take a look at:

- smart contract: [suidouble_color.move](move/suidouble_color/sources/suidouble_color.move)
- [async suidouble+sui library component](shared/components/AsyncComponents/SuiAsync.js) 
- [connect button](shared/components/Auth/SignInWithSui.vue) 
- [sui blockchain interaction components](frontend/src/components) 
- deploy smart contract script - [deploy_contract.js](deploy_contract.js)

### running on your local

```bash
npm install
npm run dev
```

### executing integration tests:

```bash
npm run test
```
