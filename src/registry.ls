com = require "./common"

reg = {}

  ..com = com

  ..pkgname    = \valleydate
  ..homepage   = \https://github.com/sourcevault/valleydate

  ..print = {}
  ..already_created = new Set!

  ..cache = {}
    ..def = new Set!
    ..ins = new Set!

  ..tightloop = null

  ..loopError = null

  ..pkg = null

  ..sig = Symbol "self"


module.exports = reg



