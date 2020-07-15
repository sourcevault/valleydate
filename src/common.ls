z            = console.log

l            = console.log

R            = require "ramda"

chalk        = require "chalk"

util         = require "util"

show-ob      = require "json-stringify-pretty-compact"

SI           = require "seamless-immutable"

guardjs      = require "guard-js"

sim          = require "seamless-immutable-mergers"

traverse     = require "traverse"

pretty-error = require "pretty-error"

noop = !->

if (typeof window is "undefined") and (typeof module is "object")

	util = require "util"

	util-inspect-custom = util.inspect.custom

	noop[util-inspect-custom] = -> @[util-inspect-custom]

else

	util-inspect-custom = Symbol "spam"


c = {}
	..ok   = chalk.green.bold
	..er   = chalk.hex "FF0000"
	..warn = chalk.hex "FFFFCD"

module-name = "valleydate"

unfinished = (name)-> !-> l " <| #{name} |>"

guard = (whn,fn) -> (guardjs!).when whn,fn

module.exports =
	*z:z
		l:l
		chalk:chalk
		guard:guard
		guardjs:guardjs
		unfinished:unfinished
		SI:SI
		j:(j)-> console.log show-ob j
		R:R
		immutable:SI["static"]
		sim:sim
		util-inspect-custom:util-inspect-custom
		noop:noop
		module-name:module-name
		traverse:traverse
		pretty-error:pretty-error

