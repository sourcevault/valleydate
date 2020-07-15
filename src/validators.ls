{z,j,l,SI,R,guard,guardjs,noop,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

booly = new Set ["boolean","null","undefined","number"]

local = {}

local.sanatize = (f,val,path)->

	ret = f val,path

	if booly.has (typeof ret)

		if ret
			return (continue:true,error:false,value:val)
		else
			return (continue:false,error:true,value:val,message:[],path:[])

	# -----------------------------------------------------------------------------------

	else if (Array.isArray ret)

		[cont,unknown] = ret

		if cont
			return (continue:true,error:false,value:val)
		else

			out = (continue:false,error:true,value:val,path:[])

			switch (typeof unknown)
			| \string =>
				out.message = [unknown]
			|	otherwise =>
				out.message = ["[#{module-name}][error][user-supplied-validator] message has to be string."]

			return out

# -----------------------------------------------------------------------------------

	else

		out = (continue:false,error:true,value:val,path:[])

		out.message = ["[#{module-name}][error][user-supplied-validator] unknown return type."]

		return out


checkF = (ret,xf) ->

	switch typeof xf
	| \function => return xf ret
	| otherwise => return xf

registry.sideEffects = (data,ret) ->

	if (ret.continue)

		if data.continue

			ret.value = checkF ret.value,data.continue

			return ret

	# Error Handling

	else if data.error

		out = data.error ret

	else if data.fix

		val = checkF ret.value,data.fix

		return (continue:true,error:false,value:val)

	return ret


createError = (localRet,topValue,loc) ->

	out = (continue:false,error:true,value:topValue)

	if loc

		out.path = [loc]

	else

		out.path = []

	if localRet.path

		out.path.push ...localRet.path

	if localRet.message

		out.message = localRet.message

	else

		out.message = []

	out


registry.router =
	*and      :(data,funs) -> (val) -> registry.unit.and data,funs,val
		or      :(data,funs) -> (val) -> registry.unit.or data,funs,val
		map     :(data,[f]) -> (val) -> registry.unit.map[data.type] data,f,val
		on      :(data,config) -> (val) -> onn.entry data,config,val



registry.unit.and = (data,funs,value) ->

	topRet = data.validator value

	if topRet.continue

		value = topRet.value

		for f in funs

			localRet = registry.sanatize f,value

			if localRet.error then return localRet

			else

				value = localRet.value

		return (continue:true,error:false,value:value)

	return topRet


flator = (init,inner) ->

	ret = [":or"]

	if (init.length > 1) and ((init[0]) is ":or")

		init.shift!

		ret.push ...init

	else

		ret.push init

# --------------------------------------------

	if (inner.length > 1) and (inner[0] is ":or")

		inner.shift!

		ret.push ...inner

	else

		ret.push inner

	ret


registry.unit.or = (data,funs,value) ->

	topRet = data.validator value

	if topRet.continue then return topRet

# ----------------------------------------------------------------

	# topRet = {continue:false,error:true,value:value,message:.....}

	for f in funs

		localRet = registry.sanatize f,value

		if localRet.continue then return localRet

		topRet.message = flator topRet.message,localRet.message
		topRet.path.push ...localRet.path

	return topRet

# ------------------------------------


registry.unit.map.array = (data,f,value) ->

	topRet = data.validator value

	if topRet.continue

		val = topRet.value

		for value,key in val

			localRet = register.sanatize f,value,key

			if localRet.error then return createError localRet,topRet.value,key

	return topRet


onn = {}
	..entry = null
	..user_object = null
	..main = null

onn.main = (pos,f,ob) ->

	localRet = registry.sanatize f,ob[pos]

	if localRet.error

		eR = createError localRet,ob,pos

		return eR

	ob[pos] = localRet.value

	localRet

onn.user_object = (data,[funs],UFO) ->

	topRet = data.validator UFO

	if topRet.continue

		for loc,f of funs

			localRet = onn.main loc,f,topRet.value

			if localRet.error

				localRet.message = [":on",loc,localRet.message]

				return localRet

	topRet

onn.entry = guardjs!
.when do
	(data,args,UFO) -> ((typeof args[0]) is 'object')
	onn.user_object
.when do
	(data,args,UFO) -> args.length is 2
	(data,args,UFO) -> onn.user_object data,[{"#{args[0]}":args[1]}],UFO


registry.unit.map.object = (data,f,UFO) ->

	topRet = data.validator UFO

	if topRet.continue

		for key,value of topRet.value

			localRet = registry.sanatize f,value,key

			if localRet.error then

				eR = createError localRet,topRet.value,key

				return eR

	return topRet


registry.sanatize = (f,val,path) ->

	if (registry.cache.all.has f) then return f val,path

	else return local.sanatize f,val,path

create_atomic = (name) -> (UFO) ->

	Type = typeof UFO

	if (Type is name)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,value:UFO,message:["not a #{name}"],path:[])


R.forEach do
	(name) -> registry.basetype[name] = create_atomic name
	["function","boolean","number","string"]

registry.basetype.null = (UFO) ->

	if UFO is null then return (error:false,continue:true,value:UFO)
	else return (error:true,continue:false,value:UFO,message:["not a null"],path:[])

registry.basetype.undefined = (UFO) ->

	Type = typeof UFO

	if (Type is \undefined)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,value:UFO,message:["not undefined"],path:[])

registry.basetype.array = (UFO) ->

	if (Array.isArray UFO) then return (error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,value:UFO,message:["not an array"],path:[])



registry.basetype.object = (UFO) ->

	basetype = typeof UFO

	if (basetype is "object") and not (Array.isArray UFO)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,value:UFO,message:["not an object"],path:[])

[registry.cache.all.add val for key,val in registry.basetype]



