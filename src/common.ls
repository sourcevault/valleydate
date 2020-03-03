l = console.log

R = require "ramda"

chalk  = require "chalk"

util  = require "util"

render = require "json-stringify-pretty-compact"

SI = require "seamless-immutable"

guardjs = require "guard-js"

sim = require "seamless-immutable-mergers"

traverse = require "traverse"

pretty-error = require "pretty-error"

noops = !->

if (typeof window is "undefined") and (typeof module is "object")

	util = require "util"

	util-inspect-custom = util.inspect.custom

	noops[util-inspect-custom] = -> @[util-inspect-custom]

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
	*l:l
		chalk:chalk
		guard:guard
		unfinished:unfinished
		SI:SI
		j:(j)-> console.log render j 
		R:R
		immutable:SI["static"]
		sim:sim
		util-inspect-custom:util-inspect-custom
		noops:noops
		module-name:module-name
		traverse:traverse
		pretty-error:pretty-error

