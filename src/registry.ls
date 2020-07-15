com = require "./common"

reg = {}

  ..module-name = "valleydate"
  ..repo-url    = "https://github.com/sourcevault/valleydate"

  ..com = com

  ..cache = {}
    # ..common = {}  # simple optimization for basetype prox
    ..all = new WeakSet! # all proxs

  ..entry      = null
  ..main       = null
  ..is         = null

  ..basetype  = {}
    ..arr     = null
    ..obj     = null
    ..num     = null
    ..null    = null
    ..str     = null
    ..bool    = null
    ..fun     = null
    ..undef   = null

  # ..unit = {}
  #   ..and = null
  #   ..or = null
  #   ..map = {}
  #     ..array  = null
  #     ..object = null

  #   ..on       = {}
  #     ..array = null
  #     ..object = null


  # ..fault = {}
  #   ..ap = null
  #   ..get = null

  # ..helper = {}
  #   ..required = null
  #   ..integer = null

  ..sanatize = null

  ..sideEffects = null

  ..router = {}
    ..and      = null
    ..or       = null
    ..map      = null
    ..on       = null

  # ..verify = {}
    ..get = {}
      ..init   = null
      ..chain  = null
      ..on     = null
      ..map    = null
      ..end    = null
      ..def    = null
      ..fix    = null
      ..consumption_error = null

    ..ap  = {}
      ..chain  = null
      ..custom = null
      ..object = null
      ..end    = null
      ..on = {}
        ..entry = null
        ..types = null

  ..emit = {}
    ..prox = null
    ..get = {}
      ..chain    = null
      ..fault    = null
      ..end      = null
      ..basetype = null

    ..ap  = {}
      ..chain    = null
      ..fault    = null
      ..end      = null
      ..resolve  = null
      ..custom   = null


module.exports = reg



