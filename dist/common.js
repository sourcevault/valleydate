// Generated by LiveScript 1.6.0
(function(){
  var z, l, R, chalk, showOb, SI, sim, prettyError, binapi, hoplon;
  z = console.log;
  l = console.log;
  R = require("ramda");
  chalk = require("chalk");
  showOb = require("json-stringify-pretty-compact");
  SI = require("seamless-immutable");
  sim = require("seamless-immutable-mergers");
  prettyError = require("pretty-error");
  binapi = require("binapi");
  hoplon = require("hoplon");
  module.exports = {
    z: z,
    l: l,
    noop: function(){},
    chalk: chalk,
    binapi: binapi,
    hop: hoplon,
    SI: SI,
    j: function(j){
      return console.log(showOb(j));
    },
    R: R,
    sim: sim,
    prettyError: prettyError
  };
}).call(this);
