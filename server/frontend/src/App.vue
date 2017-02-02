<template lang='pug'>
    div
        chart
</template>

<script lang='coffee'>
Chart = require './chart.vue'

module.exports =
  name: 'app'
  components:
      chart: Chart
</script>

<style>
</style>
