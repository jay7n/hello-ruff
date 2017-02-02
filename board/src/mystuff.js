'use strict';
$.ready(function(err) {
  var butStateIdx, buttonState, leds, timeIntervalID;
  if (err) {
    console.log(err);
    return;
  }
  leds = ['#led-r', '#led-b', '#led-g'];
  buttonState = ['set', 'reset'];
  butStateIdx = 0;
  timeIntervalID = null;
  $('#button').on('push', function() {
    var curButState, idx, prevLed;
    curButState = buttonState[butStateIdx % 2];
    console.log(curButState);
    if (curButState === 'set') {
      console.log('Button pushed');
      idx = 0;
      prevLed = null;
      timeIntervalID = setInterval(function() {
        var curLed;
        if (prevLed) {
          $(prevLed).turnOff();
        }
        curLed = leds[idx % 3];
        console.log(curLed);
        $(curLed).turnOn();
        idx++;
        prevLed = curLed;
      }, 700);
    } else if (curButState === 'reset') {
      clearInterval(timeIntervalID);
    }
    butStateIdx++;
  });
});

$.end(function() {
  var i, led, len;
  for (i = 0, len = leds.length; i < len; i++) {
    led = leds[i];
    $(led).turnOff();
  }
});
