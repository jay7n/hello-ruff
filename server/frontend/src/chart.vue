<template lang='pug'>
    div(id='chart')
        canvas(id='chart-canvas') mycanvas
</template>

<script lang='coffee'>
    $ = require 'jquery'
    LineChart = require './linechart.coffee'

    vueComponent =
        name: 'chart'
        data: ->
            greeting: 'Hello My Chart!'
        mounted: ->
            vm = this
            url = "#{window.location.href}nursing-log"
            console.log url
            $.ajax
                type: 'GET'
                url: url
                success: (data) ->
                    ctx = $('#chart-canvas')
                    LineChart.Create(ctx, data)
                    return
            return

    module.exports = vueComponent
</script>

<style lang='sass'>
#chart
    width: 90%
    // height: 70%
    margin: 0 auto
    margin-top: 2%
</style>
