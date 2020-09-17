reg = require "./registry"

{com,pkg,loopError,print} = reg

{z,l,R,j,hop} = com

be = pkg

internal = {}

internal.integer = (val) ->

  residue = Math.abs (val - Math.round(val))

  if residue > 0

    return [false,"not an integer"]

  else

    return [true]


pkg.int = pkg.num.and internal.integer

#--------------------------------------------------------

internal.required = (props) -> (val) ->

  I  = 0

  nI = props.length

  while I < nI

    key = props[I]

    if (val[key] is undefined)

      return [
        false
        "required value .#{I} is not present (or is undefined)."
      ]

    I += 1

  return true

#--------------------------------------------------------


pkg.required = hop

.wh do

  ->

    args = R.flatten [...arguments]

    for key in args

      if not ((R.type key) in [\String \Number])

        print.route [\required_input]

        return true

    return false

  loopError

.def ->

  props = R.flatten [...arguments]

  be.obj.and internal.required props

