
{l,z,chalk,R,guard,guardjs,module-name} = require "./common"

{pretty-error,noops} = require "./common"

registry = require "./registry"

c = {}

	..ok   = chalk.green.bold
	..er   = chalk.hex "FF0000"
	..warn = chalk.hex "FFFFCD"
	..black = chalk.rgb(128, 128, 128).bold

repo-url = "https://github.com/sourcevault/valleydate"

print = {}

help =
	c.black "[      docs] #{repo-url}"

pe = (new prettyError!)

pe.skipNodeFiles!

pe.filterParsedError (Error) ->

	Error._trace = R.drop 4,Error._trace

	Error

pe.skip (traceLine,lineNumber) ->

	if traceLine.packageName is  "guard-js" then return true

	if traceLine.dir is "internal/modules/cjs" then return true

	if traceLine.what is "Object.print.stack" then return true

	if traceLine.what is "handle.fun.get.entry [as get]" then return true

	return false


pe.appendStyle do
	"pretty-error > header > title > kind":(display: "none")
	"pretty-error > header > colon":(display: "none")
	"pretty-error > header > message":(display:"none")


show_stack = !->

	E = pe.render new Error!

	l E

close = (data) ->

	l help

	show_stack!

	{state:\fault,call:\fault} |> data.merge |> registry.emit.prox


print.wrong_basetype_for_map = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("#{data.type}.#{key}") + (c.warn " <<--\n")

	l c.warn "   map can only be used for basetype object and array.\n"

	close data

gen_chain = (data) ->

	str = data.type

	if data.all.length > 0

		ret = [I[0] for I in data.all]

		str = "." + str + "." + (ret.join "(~).") + "(~)"

	return str


print.call_has_to_be_function = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok gen_chain data) + (c.er ".#{data.call}(~)") + (c.warn " <<--\n")

	l c.warn "   only functions can be passed into unit function.\n"

	close data

print.wrong_type_for_object_on = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok gen_chain data) + (c.er ".#{data.call}(..)") + (c.warn " <<--\n")

	l c.warn "   wrong type/argument for #{data.type}.on\n"

	close data

print.wrong_basetype_for_on = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("#{data.type}.#{key}") + (c.warn " <<--\n")

	l c.warn "   .on cannot be used for basetype #{data.type}.\n"

	close data



print.fail = (filename) -> (message) !->


	l do
		c.er "[TEST ERROR] originating from module"
		c.warn "[#{repo-url}]"
		c.er "\n\n- 'npm test' failed at #{filename}:"



	if ((typeof message) is \string)

		l c.er "\n   #{message}\n"


	process.exitCode = 1

print.not_unit = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ("." + key)) + (c.warn " <<--\n")

	l (c.warn "   #{(c.er ("." + key))} is not a valid unit function for basetype #{data.type}.\n")

	close data

print.single_init_function = (data) ->

	l do
		(c.er "[#{module-name}][error]")
		(c.er "<!custom validator creator!>\n")

	l do
		(c.warn "   only accepts a single initization function (argument).\n\n")
		(c.warn "  use .and .or to pass subsequent validator functions.\n")

	close data

print.custom_only_function = (data) ->

	l do
		(c.er "[#{module-name}][error]")
		(c.er "<!custom validator creator!>\n")

	l (c.warn "   only function type accepted.\n")

	close data

print.accepts_only_single_consumer_for_unit = (data,key) ->


	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ".#{key}") + (c.warn " <<--\n")

	l do
		c.er "   .#{key}"
		c.warn "defined once already.\n\n"
		c.warn "  multiple consumption path can't co-exist.\n"

	close data

print.not_in_end = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ".#{key}") + (c.warn " <<--\n")

	l do
		c.er "   .#{key}"
		c.warn "is not a valid consumption unit.\n"

	close data

print.in_consumption_mode = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ".#{key}") + (c.warn " <<--\n")

	l do
		c.warn "   chain can't be modified in consumption mode.\n"

	close data

print.multi_error = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ".#{key}") + (c.warn " <<--\n")

	l do
		c.warn "  .error/.err, .dispatch/.dis or .fix can't exist in the same validation chain\n"
		c.warn " .dispatch/.dis and .fix is a substitute for error path.\n\n"


	close data

print.def_argument_is_function = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok ((gen_chain data) + "." + data.call)) + (c.er "(~)") + (c.warn " <<--\n")

	l do
		c.warn "  argument for .def can't be a function, use .error for functions.\n"

	close data


print.fix_top_error = {}

print.fix_top_error.ap = (data,args)->

	l do
		c.er "↑ ↑ .. [upstream fault in validator chain].. ↑ ↑\n"


	if data.call

		{state:\fault,call:null} |> data.merge |> registry.emit.prox

	else
		{continue:false,error:true,value:null,message:"fault in validator chain"}



print.fix_top_error.get = (data,key)->

	l do
		c.er "↑ ↑ .. [upstream fault in validator chain].. ↑ ↑\n"

	{state:\fault,call:key} |> data.merge |> registry.emit.prox


print.accepts_only_a_single_argument = (data,args) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ".#{data.call}(~)") + (c.warn " <<--\n")

	l do
		c.warn "    too many arguments for function"
		c.er ".#{data.call}"
		c.warn "only single argument accepted.\n"

	close data,args


print.not_in_base_or_help = (data,key) ->

	ret = [I[0] for I in data.all]

	if data.type

		ret.unshift data.type

	if data.call

		ret.unshift data.call

	l do
		c.er "[#{module-name}][error]"
		(c.ok (ret.join ".")) + (c.er "." + key) + (c.warn " <<--\n")

	l (c.warn "   #{c.er ("." + key)} is not part of module.\n")

	close data


print.not_an_object = (data,prop) ->

	l do
		c.er (module-name + "[error]")
		(c.ok data.call) + c.er ("." + prop) + (c.warn " <<--\n")

	l (c.ok data.call) + (c.warn " is a function, not a object.")

	close data

print.top_level_is_not_function = (data,prop) ->

	l do
		c.er ("[#{module-name}][error] validator chain is empty.\n")

	l c.warn "   top level object is not a function that can be called.\n"

	close data


print.unknown_ap_call = (data,prop) ->

	l do
		c.er ("[#{module-name}][error]\n")

	l c.warn "   Error not defined, please contact author or raise an issue.\n"

	close data

print.unit_not_on_top = (data,prop) ->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("." + prop) + (c.warn " <<--\n")

	l c.warn " unit function #{c.ok "." + prop} cannot be called on top level object.\n"

	l c.warn " only basetypes and helper are allowed.\n\n"

	close data


top = ->

	help = Object.keys registry.helper
	base = Object.keys registry.basetype

	str =
		[
			c.ok module-name
			c.ok " - assorted list of module routinues.\n"
			c.ok "[  basetype] "
			c.warn base.join (c.ok "|")
			"\n"
			c.ok "[    helper] "
			c.warn help.join (c.ok "|")
		]


	str.join ""


internal = (data) ->

	if (data.type is null)
		return "||"

	chain = []

	for I in data.all
		chain.push (c.warn (I[0] + " (" + I[1].length + ")"))

	inn = []

	if inn.length > 0

		inn = "(" + (inn.join ",") + ") "

	str =
		[
			"| #{data.type} #{inn}| "
			chain.join (c.ok " > ")
		]

	str.join ""

print.requiredError = (loc) ->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("key in position #{loc} is not string type.\n")

	l (c.warn "keys passed to helper function #{c.ok '\.required'} has to be string or number.\n")

	l help

	show_stack!

print.fault = (data,key) ->

	c.er ("<! fault !> " + internal data)

print.pretty = (data,key) ->
	switch data.state
	| \init => top data,key
	| \fault => print.fault data,key
	| otherwise => internal data,key


module.exports = print

