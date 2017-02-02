'use strict'

http = require 'http'
querystring = require 'querystring'

dosages = [30, 60, 90]
leds = ['#led-r', '#led-b', '#led-g']

incDosage = do ->
    idx = dosages.length - 1
    (reset) ->
        if reset
            idx = dosages.length - 1
            return
        else
            idx = (idx+1) % dosages.length
            currentDose = dosages[idx]
            currentLed = leds[idx]
            [currentDose, idx]

reset = ->
    incDosage(true)
    $(led).turnOff() for led in leds

getDate = ->
    #     new Date().toISOString()
    # > '2012-11-04T14:51:06.157Z'
    # So just cut a few things out, and you're set:
    #
    # new Date().toISOString().
    #   replace(/T/, ' ').      // replace T with a space
    #   replace(/\..+/, '')     // delete the dot and everything after
    # > '2012-11-04 14:55:45'

    # date = new Date().toLocaleString()
    # date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
    date = new Date().toISOString()

submitReport = (dosage)->
    reqstring = querystring.stringify
        dosage: dosage
        date: getDate()

    console.log("preparing for submitting the querying data #{reqstring}")

    req = http.request
        host: 'liruffstuff.leanapp.cn'
        # host: '192.168.78.116'
        # port: '3000'
        path: '/nursing-log'
        headers:
            'Content-Type': 'application/x-www-form-urlencoded'
            'Content-Length': reqstring.length
        method: 'POST'
        , (res) -> res.on 'data', (chunk)->
            console.log("RES = #{chunk}")
            return

    req.write reqstring
    req.end()

    req.on 'error', (e) ->
        console.error("error: #{e.message}")
        return

submitWithTimeout = do ->
    timeoutID = null
    # delayTime = 10 * 60 * 1000 # 10 min for production
    delayTime = 5 * 1000 # 5 sec for test

    (dosage, callback) ->
        if timeoutID isnt null
            clearTimeout timeoutID

        timeoutID = setTimeout ->
            submitReport dosage
            callback()
            return
        ,delayTime

ledLighting = (leds, idx)->
    for i in [0..leds.length-1]
        if i <= idx
            $(leds[i]).turnOn()
        else
            $(leds[i]).turnOff()
    return

$.ready (err) ->
    if err
        console.log err
        return

    currentDose = null
    $('#button-blue').on 'push', ->
        [currentDose, idx] = incDosage()
        console.log "#{currentDose} at #{idx} selected"
        ledLighting leds, idx

        submitWithTimeout currentDose, ->
            reset()
        return
    return


$.end ->
    $(led).turnOff() for led in leds
    return
