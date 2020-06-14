commonjs = require "./common"

{l,noops,unfinished,traverse} = commonjs

unfinshed_to_leaf = (x) !->

	if x is null

		@update (unfinished @path.join ".")

create_filler_function = (main) ->

	(traverse main).forEach unfinshed_to_leaf

registry = {}

	..basetype = {}
		..array = null
		..object = null
		..number = null
		..null = null
		..string = null
		..boolean = null
		..function = null
		..undefined = null

	..unit = {}
		..and = null
		..or = null
		..edit = null
		..map = {}
			..array  = null
			..object = null

		..on       = {}
			..array = null
			..object = null
			..string = null
			..number = null

		..continue = null
		..error    = null
		..tap      = null

	..cache = {}
		..common = new WeakMap! # simple optimization for basetype prox
		..all = new WeakSet! # all proxs


	..helper = {}
		..required = null
		..integer = null
		..alphanum = null

	..sanatize = null

	..sideEffects = null

	..router = {}
		..and      = null
		..or       = null
		..edit     = null
		..map      = null
		..on       = null
		..continue = null
		..error    = null
		..tap      = null

	..is = null



ALL = create_filler_function registry

module.exports = ALL



