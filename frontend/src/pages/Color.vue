<template>

    <div></div>
  
  </template>
  
  <script>
  
  export default {
      name: 'Color Page',
      path: '/color/:color',
      props: {
      },
      components: {
        //   ColorHome,
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
        document.location = '/';
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
  
  