{l,SI,R,guard,guardjs,noops,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

require "./validators"

require "./helper"

print = require "./print"

genprox-save = (neo,old,key) ->

	P = new Proxy(noops,(handle.of neo))

	common = registry.cache.common

	if common.has old

		current_cache = common.get old

		current_cache[key] = P

	else

		store = {}

		common.set old,store

		store[key] = P

	registry.cache.all.add P

	P

genprox-simple = (neo,old) ->

	P = new Proxy(noops,(handle.of neo))

	registry.cache.all.add P

	P

incache = (data,key)->

	found = registry.cache.common.get data

	if found then found[key]

	else false

validator_get = (data,key) -> 

	neo = data.set "call",key

	genprox-simple neo,data

validator_initial = (data,key) ->

	baseF = registry.basetype[key]

	neo = SI.merge data,(validator:baseF,type:key)

	genprox-save neo,data,key


validator_basetype = (data,args) ->

	[type,validator] = args

	v = (val) -> registry.sanatize validator,val

	neo = SI.merge data,{validator:v,type}

	genprox-simple neo,data


validator_call = (data,args) ->
	
	update =
		*call:null
			validator:registry.router[data.call] data,args
			all:[[data.call,args]]

	neo = data.merge update,(merger:sim.concatArrayMerger)

	genprox-simple neo,data

ap_call = (data,[val])->

	rets = data.validator val

	registry.sideEffects data,rets

	rets

registry.router.continue = (data,f) ->

	update =
		*call:null
			all:[[data.call,f]]

	update[data.call] = f

	neo = data.merge update,(merger:sim.concatArrayMerger)

	genprox-simple neo

registry.router.error = registry.router.continue


verify-get = guard do
	(data,key) -> (key is 'map')
	guard do
		(data) -> (data.type in ['array','object'])
		validator_get
	.any print.wrong_basetype_for_map
.when do
	(data,key) -> (key is 'on')
	guard do
		(data) -> registry.unit.on[data.type]
		validator_get
	.any print.wrong_basetype_for_on
.when do
	(data,key) -> 
		registry.router[key]
	validator_get

.any print.not_unit


get = guard do
	(data,key) -> (key is util-inspect-custom)
	print.pretty
.when incache,incache
.when do
	(d,k) -> d.type
	verify-get
.when do
	(d,k) -> registry.basetype[k]
	validator_initial
.when do
	(d,k) -> registry.helper[k]
	(d,k) -> registry.helper[k]
.when do
	(d,k) -> registry.router[k]
	print.unit_not_on_top

.any print.not_in_base_or_help

verify = {}

verify.ap = {}

verify.ap.on_object = (data,args) ->

	switch args.length

		| 1 => ((typeof args[0]) is "object")
		| 2 =>

			if not ((typeof args[0]) in ["string","number"]) then return false

			switch data.type
			| "number","string" => Array.isArray args[1]
			| "object", "array" => (((typeof args[1]) is "function"))

		| otherwise => return false


verify.ap.on_rest = (data,args) -> (typeof args[0] is 'function')

verify.ap.main = guardjs!
	.when do
		(data,args) -> ((data.call is 'on') and (registry.unit.on[data.type]))
		guardjs!
			.when verify.ap.on_object,validator_call
			.any print.wrong_type_for_object_on
	.when do
		verify.ap.on_rest
		validator_call
	.any print.call_has_to_be_function


ap = guard do
	(data,args) -> registry.router[data.call]
	verify.ap.main
.when do
	(data) -> (data.validator and data.type)
	ap_call
.when do
	(data,args) -> (not data.validator) and (not data.type) and (data.all.length is 0)
	print.top_level_is_not_function
.any print.unknown_ap_call


handle = (data) ->

	@data = data

	@

handle.prototype.get = (__,key,___)->  get @data,key

handle.prototype.apply = (__,___,args) -> ap @data,args

handle.of = (data)-> new handle(data)

start = ->

	defData =
		*all:[]
			validator:null
			type:null
			call:null
			continue:null
			error:null

	init = SI defData

	IS = new Proxy(noops,(handle.of init))

	registry.cache.common.set init,{}

	registry.cache.all.add IS

	registry.is = IS

	IS


module.exports = start!