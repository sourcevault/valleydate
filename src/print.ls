
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



# print.wrong_basetype_for_unit = (data,key) ->

# 	ret = [I[0] for I in data.all]

# 	l do
# 		c.er ("[#{module-name}][error]")
# 		c.warn "map/on can only be used for basetype object and array."

# 	l help

# 	show_stack!


# print.noapi = (data,key)-> 


# 	l do
# 		c.er ("[#{module-name}][error]")
# 		c.warn "top level object is not a function."

# 	l help

# 	show_stack!


# print.not_unit = (data,key) ->

# 	ret = [I[0] for I in data.all]


# 	gap = "(..)."

# 	l do
# 		c.er ("[#{module-name}][error]")
# 		(c.ok (ret.join gap)) + (c.ok "(..)") + (c.er "." + key) + (c.warn " <<--\n")

# 	l (c.warn "#{c.er ("." + key)} is not a unit function.\n")

# 	l help

# 	show_stack!


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


# print.not_an_object = (data,prop) !->

# 	l do
# 		c.er (module-name + "[error]")
# 		(c.ok data.call) + c.er ("." + prop) + (c.warn " <<--\n")

# 	l (c.ok data.call) + (c.warn " is a function, not a object.")

# 	l help

# print.unit_not_on_top = (data,prop) !->

# 	l do
# 		c.er ("[#{module-name}][error]")
# 		c.er ("." + prop) + (c.warn " <<--\n")

# 	l (c.warn " unit function #{c.ok "." + prop} cannot be called on top level object.\n")

# 	l help

# 	show_stack!

top = (data) ->

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

# print.required_not_string = (loc) ->

# 	l do
# 		c.er ("[#{module-name}][error]")
# 		c.er ("key in position #{loc} is not string type.\n")

# 	l (c.warn "keys passed to helper function #{c.ok \.required} has to be string.\n")

# 	l help

# 	show_stack!


print.pretty = guard do
	(data,key) -> not data.type
	top
.any internal

module.exports = print