{z,SI,R,guard,guardjs,noops,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

require "./validators"

require "./helper"

print = require "./print"

{emit,verify} = registry

validator = {}

verify.ap.object = (data,args) ->

	switch args.length

		| 1 => ((typeof args[0]) is "object")
		| 2 =>

			if not ((typeof args[0]) in ["string","number"]) then return false

			switch data.type
			| "number","string" => Array.isArray args[1]
			| "object", "array" => (((typeof args[1]) is "function"))

		| otherwise => return false


emit.prox = (data) ->

	P = data |> handle.of |> new Proxy(noops,_)

	registry.cache.all.add P

	P

emit.get.chain = (data,key) -> 

	neo = data.set \call,key

	emit.prox neo

emit.get.basetype = (data,key) ->

	{common,all} = registry.cache

	stored = common[key]

	if not stored

		baseF = registry.basetype[key]

		neo = SI.merge data,(validator:baseF,type:key,state:\chain)

		P = new Proxy(noops,(handle.of neo))

		common[key] = P

		all.add P

		return P

	else

		return stored


emit.ap.chain = (data,args) ->

	Fns = R.flatten args

	update =
		*call:null
			validator:registry.router[data.call] data,Fns
			all:[[data.call,args]]

	neo = data.merge update,(merger:sim.concatArrayMerger)

	emit.prox neo

registry.fault.get = (data,call) -> {fault:true,call:call} |> data.merge |> emit.prox

emit.end = (data,key) -> {call:key,state:\end} |> data.merge |> emit.prox

emit.ap.resolve = (data,[val])->

	ret = data.validator val

	registry.sideEffects data,ret


emit.ap.end = (data,f) ->

	update =
		*call:null
			all:[[data.call,f]]

	update[data.call] = f[0]

	neo = data.merge update,(merger:sim.concatArrayMerger)

	emit.prox neo

# -------------------------------------------------------------------------------------------------------

verify.get.map = guard do
	(data) -> (data.type in ['array','object'])
	emit.get.chain
.any print.wrong_basetype_for_map

# -------------------------------------------------------------------------------------------------------

verify.get.on = guard do
	(data) -> registry.unit.on[data.type]
	emit.get.chain
.any print.wrong_basetype_for_on

# -------------------------------------------------------------------------------------------------------

verify.get.end = guard do
	(data,key) -> data[key]
	print.accepts_only_single_consumer_for_unit
.when do
	(data,key) -> (((key is \fix) and (data.error)) or ((key is \error) and data.fix))
	print.def_and_error
.any emit.end


verify.get.consumption_error = guardjs!
.when do
	(data,key) -> registry.basetype[key]
	print.in_consumption_mode
.when do
	(data,key) -> registry.router[key]
	print.in_consumption_mode
.any print.not_in_end

# -------------------------------------------------------------------------------------------------------

verify.get.chain = (data,key) ->

	F = switch key
	| \map     => verify.get.map
	| \on      => verify.get.on
	| \and,\or => emit.get.chain
	| \continue,\error,\fix => verify.get.end

	| otherwise => print.not_unit

	F data,key

# -------------------------------------------------------------------------------------------------------

verify.get.init = guardjs!
.when do
	(d,k) -> registry.basetype[k]
	emit.get.basetype
.when do
	(d,k) -> registry.helper[k]
	(d,k) -> registry.helper[k]
.when do
	(d,k) -> registry.router[k]
	print.unit_not_on_top
.any print.not_in_base_or_help

# -------------------------------------------------------------------------------------------------------

get = guardjs!
.when do
	(data,key) -> (key is util-inspect-custom)
	print.pretty
.any (data,key) -> 

	key = switch key
	| \cont => \continue
	| \err => \error

	| otherwise => key

	F = switch data.state
	| \init   => verify.get.init
	| \chain  => verify.get.chain
	| \end    => 

		switch key
		| \continue \error \fix => verify.get.end
		| otherwise => verify.get.consumption_error

	| \fault  => print.fix_top_error.get
	| otherwise => print.unknown_ap_call

	F data,key

# -------------------------------------------------------------------------------------------------------

verify.ap.on = guardjs!
.when do
	(data,args) -> (registry.unit.on[data.type]) and (verify.ap.object data,args)
	emit.ap.chain
.any print.wrong_type_for_object_on


verify.ap.main = guardjs!
.when do
	(data,args) ->
		Fns = R.flatten args
		for F in Fns
			if (not ((typeof F) is 'function'))
				return true
		false
	print.call_has_to_be_function 
.any emit.ap.chain

# -------------------------------------------------------------------------------------------------------

verify.ap.end = guardjs!
.when do
	(data,args) -> (1 < args.length)
	print.accepts_only_a_single_argument
.any emit.ap.end

# -------------------------------------------------------------------------------------------------------

verify.ap.def = guard do
	(data,args) -> (typeof args[0] is 'function')
	print.def_argument_is_function
.any emit.ap.end


emit.ap.custom = (data,[f]) -> 

	custom = (v) -> registry.sanatize f,v

	(type:\custom,validator:custom,state:\chain) |> data.merge |> emit.prox



verify.ap.custom = guardjs!
.when do
	(data,args) -> not ((typeof args[0]) is \function)
	print.custom_only_function
.when do
	(data,args) -> (args.length > 1)
	print.single_init_function
.any emit.ap.custom


ap = guardjs!
.when do
	(data,args) -> ((data.call is null) and (data.state in [\end,\chain]))
	emit.ap.resolve
.any (data,args) ->

		F = switch data.state
		| \chain =>

			switch data.call

			| \on => verify.ap.on

			| otherwise => verify.ap.main

		| \end      => verify.ap.end

		| \init     => verify.ap.custom

		| \fault    => print.fix_top_error.ap

		| otherwise => print.unknown_ap_call

		F data,args

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
			def:null
			fix:null
			state:\init

	all = registry.cache.all

	init = SI defData

	IS = new Proxy(noops,(handle.of init))

	registry.is = IS

	# ------------

	registry.emit.ap.fault = {state:\fault} |> init.merge |> emit.prox


	# ------------

	IS


module.exports = start!