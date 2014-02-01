#!/usr/bin/env node

var request = require('request');
var sprintf = require("sprintf-js").sprintf;

var url = 'http://pauth.contest.tuenti.net/';
// var key = 'aec7cc99dcd02c305a74a9d015d7278f60af0c63';

var stdin = process.openStdin();
stdin.on('data', function(line) {
  var key = line.toString().replace(/(\n|\r)+$/, '')

  proc(key, function(err, myKey){
    if (err){
      console.log('Error', err);
      process.exit(1);
    } else {
      console.log(myKey);
      process.exit(0);
    }
  });
});

function proc(key, fn){
  computeDelay(function(err, delay){
    if (err) return fn(err);

    var now = new Date();

    for (var i=-10; i<=10; i++){
      tryPass(key, now+i*1000, fn);
    }
  });
}

function computeDelay(fn){
  request.head(url, function(err, response, body){
    if (err) return fn(err);

    var now = new Date();
    var serverDate = new Date(response.headers.date);
    serverDelay = ((serverDate - now)/1000).toFixed();
    fn(serverDelay);
  });
}

function tryPass(key, time, fn){
  request.post(url, {
    form: {key: key, pass: getPassForTime(time)}
  }, function(err, response, body){
    console.log(body);
    var matches = /key: ([^;]+);/.exec(body);
    if (matches){
      fn(null, matches[1]);
    }
  });
}

function getPassForTime(time){
  
}

function getUUID(r){
  var uuid = sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
    r[0], r[1], r[2], r[3] & 0x0fff | 0x4000,
    r[4] & 0x3fff | 0x8000, r[5], r[6], r[7]);
  return uuid;
}
