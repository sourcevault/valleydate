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
		..undef = null

	..unit = {}
		..and = null
		..or = null
		..map = {}
			..array  = null
			..object = null

		..on       = {}
			..array = null
			..object = null

	..cache = {}
		..common = {} # simple optimization for basetype prox
		..all = new WeakSet! # all proxs

	..fault = {}
		..ap = null
		..get = null

	..helper = {}
		..required = null
		..integer = null

	..sanatize = null

	..sideEffects = null

	..router = {}
		..and      = null
		..or       = null
		..map      = null
		..on       = null

	..verify = {}
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

	..genprox = null

	..is = null

ALL = create_filler_function registry

module.exports = ALL



