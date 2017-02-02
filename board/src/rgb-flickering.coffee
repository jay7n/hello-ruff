'use strict'

$.ready (err) ->
    if err
        console.log err
        return

    leds = ['#led-r', '#led-b', '#led-g']
    buttonState = ['set', 'reset']
    butStateIdx = 0
    timeIntervalID = null

    $('#button').on 'push', ->
        curButState = buttonState[butStateIdx % 2]
        console.log curButState

        if curButState is 'set'
            console.log 'Button pushed'
            idx = 0
            prevLed = null
            timeIntervalID = setInterval ->
                $(prevLed).turnOff() if prevLed

                curLed = leds[idx%3]
                console.log(curLed)
                $(curLed).turnOn()
                idx++
                prevLed = curLed
                return
            , 700
        else if curButState is 'reset'
            clearInterval(timeIntervalID)
        butStateIdx++
        return

    return

$.end ->
    $(led).turnOff() for led in leds
    return
