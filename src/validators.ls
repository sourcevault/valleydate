{z,l,SI,R,guard,noops,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

booly = new Set ["boolean","null","undefined","number"]

local = {}

local.sanatize = (f,val,path)->

	ret = switch typeof f

	| "function" => f val,path

	| otherwise => f

	if booly.has (typeof ret)

		if ret
			return (continue:true,error:false,value:val)
		else
			return (continue:false,error:true,value:val,message:[])

# -----------------------------------------------------------------------------------

	else if (Array.isArray ret)

		[cont,unknown] = ret

		if cont
			return (continue:true,error:false,value:val)
		else
			out = (continue:false,error:true)

			switch (typeof unknown)
			| \string =>
				out.message = [unknown]
			|	otherwise =>
				out.message = ["[#{module-name}][error][user-supplied-validator] message has to be string."]

			return out

# -----------------------------------------------------------------------------------

	else

		out = (continue:false,error:true,value:val)
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

	else if data.error

		data.error ret

		return ret

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

		out.path = out.path.concat localRet.path

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


registry.unit.or = (data,funs,value) ->

	topRet = data.validator value

	if topRet.continue then return topRet

	for f in funs

		localRet = registry.sanatize f,value

		if localRet.continue then return localRet

		topRet.message.push ...localRet.message

	return topRet


registry.unit.map.array = (data,f,value) ->

	topRet = data.validator value

	if topRet.continue

		val = topRet.value

		for I,n in val

			localRet = register.sanatize f,I,n

			if localRet.error then return createError localRet,topRet.value,n

	return topRet


onn = {}
	..entry  = null
	..obja   = null
	..array  = null
	..object = null
	..number = null
	..string = null


onn.string = (pattern,result,UFO) -> 

	if (UFO is pattern) then return local.sanatize result,UFO

	(continue:true,error:false,value:UFO)

onn.number = onn.string

onn.object = (pos,f,ob) ->

	localRet = registry.sanatize f,ob[pos]

	if localRet.error then return createError localRet,ob,pos

	ob[pos] = localRet.value

	localRet

onn.array = onn.object

onn.obja = (data,[funs],UFO) ->

	topRet = data.validator UFO

	if topRet.continue

		for loc,f of funs

			localRet = onn[data.type] loc,f,topRet.value

			if localRet.error then return localRet

	topRet


onn.entry = guard do
	(data,args,UFO) -> (typeof args[0]) is 'object'
	onn.obja
.when do
	(data,args,UFO) -> args.length is 2
	(data,args,UFO) -> onn.obja data,[{"#{args[0]}":args[1]}],UFO

registry.unit.map.object = (data,f,UFO) ->

	topRet = data.validator UFO

	if topRet.continue

		for key,value of topRet.value

			localRet = registry.sanatize f,value,key

			if localRet.error then return createError localRet,topRet.value,key

	return topRet


registry.sanatize = (f,val,path) ->

	if (registry.cache.all.has f) then return f val,path

	else return local.sanatize f,val,path

create_atomic = (name) -> (UFO) ->

	Type = typeof UFO

	if (Type is name)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,message:["not a #{name}"],value:UFO)


R.forEach do
	(name) -> registry.basetype[name] = create_atomic name
	["function","boolean","number","string"]

registry.basetype.null = (UFO) ->

	if UFO is null then return (error:false,continue:true,value:UFO)
	else return (error:true,continue:false,message:["not a null"],value:UFO)

registry.basetype.undef = (UFO) ->

	Type = typeof UFO

	if (Type is \undefined)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,message:["not undefined"],value:UFO)

registry.basetype.array = (UFO) ->

	if (Array.isArray UFO) then return (error:false,continue:true,value:UFO)

	else return (error:true,continue:false,message:["not a array"],value:UFO)

registry.basetype.object = (UFO) ->

	basetype = typeof UFO

	if (basetype is "object") and not (Array.isArray UFO)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,message:["not an object"],value:UFO)


[registry.cache.all.add val for key,val in registry.basetype]
