reg = require "./registry"

{com,pkg,loopError,print}     = reg

{internal,cache}              = reg

{z,l,R,j,hop,deep-freeze,uic} = com

{custom,define}  = internal

be = custom

# ------------------------------------------------------------------

props =
  [\obj \Object]
  [\arr \Array]
  [\undef \Undefined]
  [\null \Null]
  [\num \Number]
  [\str \String]
  [\fun \Function]
  [\bool \Boolean]

nonmap = R.map do
  ([name]) -> name
  R.drop 2,props

base = (type) -> (UFO) ->

  if ((R.type UFO) is type)

    {continue:true,error:false,value:UFO}

  else

    str = R.toLower "not #{type}"

    {error:true,continue:false,message:str,value:UFO}

# ------------------------------------------------------------------

not_base = (type) -> (UFO) ->

  if ((R.type UFO) is type)

    str = R.toLower "is #{type}"

    {error:true,continue:false,message:str,value:UFO}

  else

    {continue:true,error:false,value:UFO}

# ------------------------------------------------------------------

undefnull = (UFO) ->

  if ((R.type UFO) in [\Undefined \Null])

    return {continue:true,error:false,value:UFO}
  else

    return {continue:false,error:true,message:"not undefined or null",value:UFO}

cache.def.add undefnull

#--------------------------------------------------------

be.undefnull = be undefnull

#--------------------------------------------------------

F = base "Arguments"

define.basis "arg",F

be.arg = F

#--------------------------------------------------------

pop = (msg) -> msg.pop! ; msg

#--------------------------------------------------------

be.not = (F) -> be (x) -> not (F x).continue

be.maybe = (F) -> ((be F).or be.undef).err pop


be.list  = (F) -> be.arr.map F

be.not[uic]    = print.inner

be.list[uic]   = print.inner

be.maybe[uic]  = print.inner

# ------------------------------------------------------------------

for [name,type] in props

  A = base type

  base name,A

  define.basis name,A

  be[name] = A

  #----------------------------

  B = not_base type

  define.basis name,B

  be.not[name] = B

  #----------------------------

for name in nonmap

  be.maybe[name] = be.maybe be[name]

# ------------------------------------------------------------------

be.maybe.obj = be.obj.or be.undef

be.maybe.arr = be.arr.or be.undef

# ------------------------------------------------------------------

not-arrayof-str-or-num = (type) -> ->

  args = R.flatten [...arguments]

  for key in args

    if not ((R.type key) in [\String \Number])

      print.route [\resreq,[type]]

      return true

  return false

reqError = hop.wh do
  not-arrayof-str-or-num \req
  loopError

resError = hop.wh do
  not-arrayof-str-or-num \res
  loopError

reqresError = hop.wh do
  (req,res) ->

    if not (((R.type req) is "Array") and (((R.type res) is "Array")))

      print.route [\resreq,[\resreq,\prime]]

      return true

    for I in req

      if not ((R.type I) in [\String \Number])

        print.route [\resreq,[\resreq,\res]]

        return true


    for I in res

      if not ((R.type I) in [\String \Number])

        print.route [\resreq,[\resreq,\req]]

        return true


  loopError

#------------------------------------------------------

objarr = (be.obj.alt be.arr).err [\prime,"not object or array"]

be.required = reqError.def ->

  props = R.flatten [...arguments]

  ret = objarr.on props, be.not.undef.err [\req,props]


  ret


#------------------------------------------------------

restricted = (props,po) -> (obj) ->

  keys = Object.keys obj

  for I in keys

    if not po[I]

      return [false,[\res,props],I]

  true

be.restricted = resError.def ->

  props = R.flatten [...arguments]

  po = {}

  for I in props

    po[I] = true

  objarr.and restricted props,po

be.reqres = reqresError.def (req,res) ->

  po = {}

  for I in res

    po[I] = true

  objarr.on req, be.not.undef.err [\req,req]
  .and restricted res,po

#------------------------------------------------------

integer = (UFO) ->

  if not ((R.type UFO) is \Number)

    return {continue:false,error:true,message:"not an integer ( or number )",value:UFO}

  residue = Math.abs (UFO - Math.round(UFO))

  if (residue > 0)

    return {continue:false,error:true,message:"not an integer",value:UFO}

  else

    return {continue:true,error:false,value:UFO}


cache.def.add integer

#------------------------------------------------------

boolnum = (UFO) ->

  if ((R.type UFO) in [\Boolean \Number])

    return {continue:true,error:false,value:UFO}

  else

    return {continue:false,error:true,message:"not a number or boolean",value:UFO}

cache.def.add boolnum

#-------------------------------------------------------

maybe_boolnum = (UFO) ->

  if ((R.type UFO) in [\Undefined \Boolean \Number])

    return {continue:true,error:false,value:UFO}

  else

    return {continue:false,error:true,message:"not a number or boolean",value:UFO}


cache.def.add maybe_boolnum

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
.err (msg,key)->

  switch R.type key
  | \Undefined => [\prime , "not a list of string."]
  | otherwise  => [\list , "not string type at .#{key[0]}"]

list.ofnum = list be.num
.err (msg,key) ->

  switch R.type key
  | \Undefined => [\prime,"not a list of number."]
  | otherwise  => [\list,"not number type at .#{key[0]}"]

list.ofint = list be.int
.err (msg,key) ->

  switch R.type key
  | \Undefined => [\prime,"not a list of integer."]
  | otherwise  => [\list,"not integer type at .#{key[0]}"]

maybe.list = {}

maybe.list.ofstr = maybe list.ofstr

maybe.list.ofnum = maybe list.ofnum

maybe.list.ofint = maybe list.ofint

module.exports = be

