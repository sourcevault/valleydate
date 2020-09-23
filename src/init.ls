reg = require "./registry"

{com,pkg,loopError,print}     = reg

{already_created,internal}    = reg

{z,l,R,j,hop,deep-freeze,uic} = com

{custom,dressing,define}      = internal

be = custom

# ----------------------------

props =
  [\obj \Object]
  [\arr \Array]
  [\undef \Undefined]
  [\null \Null]
  [\num \Number]
  [\str \String]
  [\fun \Function]
  [\bool \Boolean]

# ----------------------------

be.not = (F) -> be (x) -> not (F x).continue

be.maybe = (F) -> (be F).or be.undef

be.list  = (F) -> be.arr.map F

be.list[uic]  = print.inner

be.maybe[uic] = print.inner

be.not[uic]   = print.inner


# ----------------------------

for [name,type] in props

  F = define.base type

  dressing name,F

  be[name] = F

  #----------------------------

  G = define.not_base type

  dressing name,G

  be.not[name] = G

  #----------------------------

  H = define.maybe_base type

  dressing name,H

  be.maybe[name] = H


#----------------------------

show-attr = (props) ->
  """
    has to be an object with required attributes:
    .#{props.join(" .")}
  """
#----------------------------

reqError = hop.immutable
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

be.required = reqError.def ->

  props = R.flatten [...arguments]

  be.obj.on do
    props
    be.not.undef
    .err show-attr props

be.maybe.required = ->

  req = be.required ...arguments

  be.maybe req


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

maybe_boolnum = (UFO) ->

  if ((R.type UFO) in [\Undefined \Boolean \Number])

    return {continue:true,error:false,value:UFO}

  else

    return {continue:false,error:true,message:"not a number or boolean",value:UFO}


already_created.add maybe_boolnum

#-------------------------------------------------------

be.int     = be integer

be.boolnum = be boolnum

#--------------------------------------------------------

be.maybe.int = be.int.or be.undef

#--------------------------------------------------------

maybe = be.maybe

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

maybe.boolnum = be maybe_boolnum

#--------------------------------------------------------

list = be.list

list.ofstr = list be.str
.err (msg,[key]) ->
  "value at index #{key} is not of string type"

list.ofnum = list be.num
.err (msg,[key]) ->
  "value at index #{key} is not of number type"

maybe.list = {}

maybe.list.ofstr = maybe list.ofstr

maybe.list.ofnum = maybe list.ofnum

module.exports = be