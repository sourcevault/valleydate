{l,SI,R,guard,noops,module-name} = require "./common"

{unfinished,sim,util-inspect-custom} = require "./common"

registry = require "./registry"

print = require "./print"

is-string = R.is String

is-number = R.is Number

noops = !->

required = (props,val) ->

	for I in props

		if (val[I] is undefined) then

			return [
				false
				"required value .#{I} is not present (or is undefined)."
			]

	return [true]


check_if_string = ->

	args = R.flatten [...arguments]

	for I,n in args

		if not ((is-string I) or (is-number I))

			print.requiredError n

			return false

	return true


registry.helper.required = guard do
	check_if_string
	->
		args = R.flatten [...arguments]
		registry.is.object.and (val) -> required args,val
.any noops


is_integer = (val) ->

	residue = Math.abs (val - Math.round(val))

	if residue > 0

		return [false,"not an integer"]

	else

		return [true]

registry.helper.integer = (val)-> (registry.is.number.and is_integer) val