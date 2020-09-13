com = require "./common"

reg = {}

  ..com = com

  ..pkgname    = \valleydate
  ..homepage   = \https://github.com/sourcevault/valleydate

  ..print = {}
  ..already_created = new Set!
  ..tightloop = null

  ..loopError = null

  ..pkg = null


module.exports = reg



