'use strict';
var dosages, http, incDosage, ledLighting, leds, querystring, reset, submitReport, submitWithTimeout;

http = require('http');

querystring = require('querystring');

dosages = [30, 60, 90];

leds = ['#led-r', '#led-b', '#led-g'];

incDosage = (function() {
  var idx;
  idx = dosages.length - 1;
  return function(reset) {
    var currentDose, currentLed;
    if (reset) {
      idx = dosages.length - 1;
    } else {
      idx = (idx + 1) % dosages.length;
      currentDose = dosages[idx];
      currentLed = leds[idx];
      return [currentDose, idx];
    }
  };
})();

reset = function() {
  var j, led, len, results;
  incDosage(true);
  results = [];
  for (j = 0, len = leds.length; j < len; j++) {
    led = leds[j];
    results.push($(led).turnOff());
  }
  return results;
};

submitReport = function(dosage) {
  var req, reqstring;
  console.log("simulate dosage " + dosage + " submit");
  reqstring = querystring.stringify({
    dosage: dosage
  });
  console.log(reqstring);
  req = http.request({
    host: '192.168.78.116',
    port: '3000',
    path: '/nursing-log',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': reqstring.length
    },
    method: 'POST'
  }, function(res) {
    return res.on('data', function(chunk) {
      console.log("RES = " + chunk);
    });
  });
  req.write(reqstring);
  req.end();
  return req.on('error', function(e) {
    console.error("error: " + e.message);
  });
};

ledLighting = function(leds, idx) {
  var i, j, ref;
  for (i = j = 0, ref = leds.length - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
    if (i <= idx) {
      $(leds[i]).turnOn();
    } else {
      $(leds[i]).turnOff();
    }
  }
};

submitWithTimeout = (function() {
  var delayTime, timeoutID;
  timeoutID = null;
  delayTime = 5 * 1000;
  return function(dosage, callback) {
    if (timeoutID !== null) {
      clearTimeout(timeoutID);
    }
    return timeoutID = setTimeout(function() {
      submitReport(dosage);
      callback();
    }, delayTime);
  };
})();

$.ready(function(err) {
  var currentDose;
  if (err) {
    console.log(err);
    return;
  }
  currentDose = null;
  $('#button-blue').on('push', function() {
    var idx, ref;
    ref = incDosage(), currentDose = ref[0], idx = ref[1];
    console.log(currentDose + " at " + idx + " selected");
    ledLighting(leds, idx);
    submitWithTimeout(currentDose, function() {
      return reset();
    });
  });
});

$.end(function() {
  var j, led, len;
  for (j = 0, len = leds.length; j < len; j++) {
    led = leds[j];
    $(led).turnOff();
  }
});
