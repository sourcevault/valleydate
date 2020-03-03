{l,SI,R,guard,noops,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

require "./validators"

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

	registry.sideEffects data, rets

	rets

registry.router.continue = (data,f) ->

	update =
		*call:null
			all:[[data.call,f]]

	update[data.call] = f

	neo = data.merge update,(merger:sim.concatArrayMerger)

	genprox-simple neo

registry.router.error = registry.router.continue

get = guard do
	(data,key) -> (key is util-inspect-custom)
	print.pretty
.when incache,incache
.when do
	(d,k) -> d.type and registry.router[k]
	validator_get
.when do
	(d,k) -> registry.basetype[k]
	validator_initial
.when do
	(d,k) -> registry.helper[k]
	unfinished "get.helper"
.any print.not_in_base_or_help


ap = guard do
	(data,args) -> registry.router[data.call]
	validator_call
.when do
	(data,args) -> (not data.validator) and (not data.type)
	validator_basetype
.when do
	(data) -> data.validator and data.type
	ap_call
.any print.noapi


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

	IS


module.exports = start!