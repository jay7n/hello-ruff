moment = window.moment = require 'moment' # lousy & tricky workaround
ChartClass = require 'chartjs'

moment.locale('zh-cn')

ChartClass.pluginService.register
    beforeRender: (chart) ->
        if chart.config.options.showAllTooltips
            # create an array of tooltips
            # we can't use the chart tooltip because there is only one tooltip per chart
            chart.pluginTooltips = []
            chart.config.data.datasets.forEach (dataset, i) ->
                chart.getDatasetMeta(i).data.forEach (sector, j) ->
                    chart.pluginTooltips.push new (Chart.Tooltip)({
                        _chart: chart.chart
                        _chartInstance: chart
                        _data: chart.data
                        _options: chart.options.tooltips
                        _active: [ sector ]
                    }, chart)
                    return
                return
            # turn off normal tooltips
            chart.options.tooltips.enabled = false
        return
    afterDraw: (chart, easing) ->
        if chart.config.options.showAllTooltips
            # we don't want the permanent tooltips to animate, so don't do anything till the animation runs atleast once
            if !chart.allTooltipsOnce
                if easing != 1
                    return
                chart.allTooltipsOnce = true
            # turn on tooltips
            chart.options.tooltips.enabled = true
            Chart.helpers.each chart.pluginTooltips, (tooltip) ->
                tooltip.initialize()
                tooltip.update()
                # we don't actually need this since we are not animating tooltips
                tooltip.pivot()
                tooltip.transition(easing).draw()
                return
            chart.options.tooltips.enabled = false
        return

GetLineChartOption = (liveOpt) ->
    title:
        display: true
        # text: moment(liveOpt.date).format 'YYYY-M-D Do'
        text: '喂养记录'

    tooltips:
        callbacks:
            title: (tooltipItem)->
                console.log tooltipItem[0].xLabel
                tooltipItem[0].xLabel.format 'ddd HH:mm'
            label: (tooltipItem, data)->
                tooltipItem.yLabel + 'ml'

    showAllTooltips: true

    scales:
        xAxes: [
            type: 'time'
            # scaleLabel:
            #     display: false
            time:
                # min: moment 'Monday', 'll ddd'
                # max: moment 'Sunday', 'll ddd'
                unit: 'hour'
                displayFormats:
                    day: 'll ddd'
        ]
        yAxes: [
            ticks:
                min: 0
                max: 100
        ]

_convertData = (data)->
    newdata = []
    for d in data
        newdata.push
            x: moment(d.date)
            y: d.dosage

    return newdata

Create = (ctx, data)->
    data = _convertData data
    console.log data
    chart = new ChartClass ctx,
        type: 'line'
        data:
            datasets: [
                label: '奶粉'
                data: data
                # data: [
                #     x: moment('01:27', 'h:mm')
                #     y: 30
                # ,
                #     x: moment('12:30', 'h:mm')
                #     y: 60
                # ,
                #     x: moment('15:30', 'h:mm')
                #     y: 30
                # ]
                backgroundColor: 'rgba(255, 99, 132, 0.2)'
                borderColor: 'red'
            ]
        options: GetLineChartOption()

module.exports =
    Create: Create
