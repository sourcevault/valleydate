reg = require "./registry"

{com,pkg,loopError,print} = reg

{already_created} = reg

{z,l,R,j,hop,deep-freeze,uic} = com

be = pkg

#------------------------------------------------------

list = (F) -> be.arr.map F

maybe = (F) -> (be F).or be.undef

maybe[uic] = print.inner

list[uic]  = print.inner

be.maybe = maybe

be.list  = list

#------------------------------------------------------

required = (props) -> (UFO) ->

  I  = 0

  nI = props.length

  while I < nI

    key = props[I]

    if (UFO[key] is undefined)

      return [
          false
          "required value .#{key} is not present (or is undefined)."
      ]

    I += 1

  return [true]

#------------------------------------------------------

reqE = hop.immutable
.wh do

  ->

    args = R.flatten [...arguments]

    for key in args

      if not ((R.type key) in [\String \Number])

        print.route [\required_input]

        return true

    return false

  loopError

#------------------------------------------------------


show-attr = (props) ->
  """
    has to be an object with required attributes:
    .#{props.join(" .")}
  """

G = reqE.def ->

  props = R.flatten [...arguments]

  F = required props

  be.obj.and F
  .err show-attr props

be.required = G

#------------------------------------------------------

G = reqE.def ->

  props = R.flatten [...arguments]

  F = required props

  maybe.obj.and F
  .err show-attr props

maybe.required = G

#------------------------------------------------------

integer = (UFO) ->

  if not ((R.type UFO) is \Number)

    return {continue:false,error:true,message:"not an integer ( or number )",value:UFO}

  residue = Math.abs (UFO - Math.round(UFO))

  if (residue > 0)

    return {continue:false,error:true,message:"not an integer",value:UFO}

  else

    return {continue:true,error:false,value:UFO}


already_created.add integer

#------------------------------------------------------

boolnum = (UFO) ->

  if ((R.type UFO) in [\Boolean \Number])

    return {continue:true,error:false,value:UFO}

  else

    return {continue:false,error:true,message:"not a number or boolean",value:UFO}

already_created.add boolnum

#-------------------------------------------------------

be.int     = be integer

be.boolnum = be boolnum

#--------------------------------------------------------

maybe.int = be.int.or be.undef

#--------------------------------------------------------

maybe.int.pos  =
  maybe.int.and do
    (x) ->
      if (x >= 0)
        return true
      else
        return [false,"not a positive integer"]

#--------------------------------------------------------

maybe.int.neg  =
  maybe.int.and do
    (x) ->
      if (x <= 0)
        return true
      else
        return [false,"not a negative integer"]

#--------------------------------------------------------

maybe.boolnum = be.boolnum.or be.undef

#--------------------------------------------------------

maybe.obj = be.obj.or be.undef

#--------------------------------------------------------

maybe.arr = be.arr.or be.undef

#--------------------------------------------------------

maybe.num = be.num.or be.undef

#--------------------------------------------------------

maybe.str = be.str.or be.undef

#--------------------------------------------------------

maybe.fun = be.fun.or be.undef

#--------------------------------------------------------

maybe.bool = be.bool.or be.undef

#--------------------------------------------------------

list.str = list be.str
.err (msg,[key]) ->
  "value at index #{key} is not of string type"


list.num = list be.num
.err (msg,[key]) ->
  "value at index #{key} is not of number type"

maybe.list = {}

maybe.list.str = maybe list.str

maybe.list.num = maybe list.num
