
{l,chalk,R,guard,module-name} = require "./common"

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

print.wrong_basetype_for_map = (data,key) !->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("#{data.type}.#{key}") + (c.warn " <<--\n")

	l c.warn "   map can only be used for basetype object and array.\n"

	l help

	show_stack!

gen_chain = (data) ->

	str = ""

	if data.type

		str = data.type + "." + str

	if data.all.length > 0

		ret = [I[0] for I in data.all]

		str = str + (ret.join "(~~).") + "(~~)"

		if data.call

			str = str + "."

	if data.call

		str = str + data.call


	return str


print.call_has_to_be_function = (data,key) !->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok gen_chain data) + (c.er "(~~)") + (c.warn " <<--\n")

	l c.warn "   only functions can be passed into unit function.\n"

	l help

	show_stack!

print.wrong_type_for_object_on = (data,key) !->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok gen_chain data) + (c.er "(...)") + (c.warn " <<--\n")

	l c.warn "   wrong type/argument for #{data.type}.on\n"

	l help

	show_stack!

print.wrong_basetype_for_on = (data,key) !->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("#{data.type}.#{key}") + (c.warn " <<--\n")

	l c.warn "   on cannot be used for basetype #{data.type}.\n"

	l help

	show_stack!


print.fail = (num) !->

	l do
		c.er "[TEST ERROR] originating from module"
		c.warn "[#{repo-url}]"
		c.er "\n\n\t - 'npm test' failed at TEST #{num}. \n"

	process.exitCode = 1

print.not_unit = (data,key) ->

	l do
		c.er ("[#{module-name}][error]")
		(c.ok (gen_chain data)) + (c.er ("." + key)) + (c.warn " <<--\n")

	l (c.warn "   #{(c.er ("." + key))} is not a valid unit function for basetype #{data.type}.\n")

	l help

	show_stack!


print.not_in_base_or_help = (data,key) !->

	ret = [I[0] for I in data.all]

	if data.type

		ret.unshift data.type

	if data.call

		ret.unshift data.call

	l do
		c.er "[#{module-name}][error]"
		(c.ok (ret.join ".")) + (c.er "." + key) + (c.warn " <<--\n")
	
	l (c.warn "   #{c.er ("." + key)} is not part of module.\n")

	l help

	show_stack!


print.not_an_object = (data,prop) !->

	l do
		c.er (module-name + "[error]")
		(c.ok data.call) + c.er ("." + prop) + (c.warn " <<--\n")

	l (c.ok data.call) + (c.warn " is a function, not a object.")

	l help


print.top_level_is_not_function = (data,prop) !->

	l do
		c.er ("[#{module-name}][error] validator chain is empty.\n")

	l c.warn "   top level object is not a function that can be called.\n"

	l help

	show_stack!



print.unknown_ap_call = (data,prop) !->

	l do
		c.er ("[#{module-name}][error]\n")

	l c.warn "   Error not defined, please contact author or raise an issue.\n"


	l help

	show_stack!


print.unit_not_on_top = (data,prop) !->

	l do
		c.er ("[#{module-name}][error]")
		c.er ("." + prop) + (c.warn " <<--\n")

	l c.warn " unit function #{c.ok "." + prop} cannot be called on top level object.\n"

	l c.warn " only basetypes and helper are allowed.\n\n"

	l help

	show_stack!


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

	chain = []

	for I in data.all
		chain.push (c.warn (I[0] + " (" + I[1].length + ")"))

	inn = []

	if data.call

		inn.push "call:#{data.call}"

	if data.continue

		inn.push "continue"

	if data.error

		inn.push "error"

	if inn.length > 0

		inn = "(" + (inn.join ",") + ") "

	str =
		[
			c.ok "| #{data.type} #{inn}| "
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


print.pretty = guard do
	(data,key) -> not data.type
	top
.any internal

module.exports = print