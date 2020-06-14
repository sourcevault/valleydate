{l,SI,R,guard,noops,module-name} = require "./common"

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
			return (continue:false,error:true,value:val)

	else if (Array.isArray ret)

		[cont,message] = ret

		if cont
			return (continue:true,error:false,value:val)
		else
			return (continue:false,error:true,value:val,message:message)

	else

		out = (continue:false,error:true,value:val)
		out.message = "#{module-name}[error] unknown return type from user supplied validator."

		return out


registry.sideEffects = (data,ret) ->

	if ret.continue and data.continue

		for f in data.continue

			f ret.value

	else if data.error

			for f in data.error

				f ret.value

	if data.tap

		for f in data.tap

			f ret.value


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

		out.message = ""

	out


registry.router =
	*and      :(data,funs) -> (val) -> registry.unit.and data,funs,val
		or      :(data,funs) -> (val) -> registry.unit.or data,funs,val
		edit    :(data,[f]) -> (val) -> registry.unit.edit data,f,val
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

	if topRet.continue
		return
			*continue:true
				error:false
				value:topRet.value


	messages = [topRet.message]

	for f in funs

		localRet = registry.sanatize f,value

		if localRet.continue
			return
				*continue:true
					error:false
					value:localRet.value

		messages.push localRet.message

	return
		*continue:false
			error:true
			value:value
			message:messages.join " or "


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


registry.unit.edit = (data,f,UFO) ->

	topRet = data.validator UFO

	if topRet.continue

		return
			*continue:true
				error:false
				value:f topRet.value

	return topRet


registry.sanatize = (f,val,path) ->

	if (registry.cache.all.has f) then return f val,path

	else return local.sanatize f,val,path

create_atomic = (name) -> (UFO) ->

	Type = typeof UFO

	if (Type is name)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,message:"not a #{name}")


R.forEach do
	(name) -> registry.basetype[name] = create_atomic name
	["function","boolean","number","string","undefined"]

registry.basetype.null = (UFO) ->

	if UFO is null then return (error:false,continue:true,value:UFO)
	else return (error:true,continue:false,message:"not a null")

registry.basetype.array = (UFO) ->

	if (Array.isArray UFO) then return (error:false,continue:true,value:UFO)

	else return (error:true,continue:false,message:"not a array")

registry.basetype.object = (UFO) ->

	basetype = typeof UFO

	if (basetype is "object") and not (Array.isArray UFO)

		(error:false,continue:true,value:UFO)

	else

		(error:true,continue:false,message:"not an object")


[registry.cache.all.add val for key,val in registry.basetype]
