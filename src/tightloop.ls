reg = require "./registry"

{com,already_created,pkgname,sig} = reg

{z,l,R,j} = com

main = {}

sanatize = (x,UFO) ->

  switch R.type UFO

  | \Boolean,\Null,\Undefined,\Number =>

    if UFO
      return (continue:true,error:false,value:x)
    else
      return (continue:false,error:true,value:x,message:"")

  | \Array =>

    [cont,unknown,path] = UFO

    if cont

      return (continue:true,error:false,value:x)

    else

      if (Array.isArray path)
        path = path
      else
        path = []

      return {
        continue :false
        error    :true
        value    :x
        message  :unknown
        path     :path
      }

  | otherwise =>

    return {
      continue : false
      error    : true
      value    : x
      message  : "[#{pkgname}][typeError][user-supplied-validator] undefined return value."
    }


blunder = (fun,put,extra1,extra2) ->

  [patt,F] = fun

  switch patt
  | \err =>

    message = switch typeof F
    | \function => F put.message,put.path,extra1,extra2
    | otherwise => F

    put.message = message

    put

  | \fix =>

    put.value = switch typeof F
    | \function => F put.value,put.path,extra1,extra2
    | otherwise => F

    put.continue = true
    put.error    = false

    put

  | otherwise => put

apply = (type,F,val,extra1,extra2) ->

  switch type
  | \d => F val
  | \i => F.auth val,extra1,extra2
  | \f => sanatize val,(F val,extra1,extra2)

map = (dtype,fun,value,extra1,extra2) ->

  [type,F] = fun

  switch dtype
  | \arr =>

    I = 0

    In = value.length

    put = null

    arr = []

    while I < In

      put = apply type,F,value[I],I,extra1

      if put.path
        path = put.path
      else
        path = []

      if put.error
        return {
          continue:false
          error:true
          value:value
          message:put.message
          path:[I,...path]
        }

      arr.push put.value

      I += 1

    {continue:true,error:false,value:arr}

  | \obj =>

    ob = {}

    put = null

    for key,val of value

      put = apply type,F,val,key,extra1

      if put.path
        path = put.path
      else
        path = []

      if put.error
        return {
          continue:false
          error:true
          value:value
          message:put.message
          path:[key,...path]
        }

      ob[key] = put.value

    {continue:true,error:false,value:ob}

upon = ([type,fun],value,extra1,extra2) ->

  switch type
  | \string =>

    [key,shape,G] = fun

    put = apply shape,G,value[key],key,extra1

    if put.path
      path = put.path
    else
      path = []

    if put.error
      return {
        continue:false
        error:true
        value:value
        message:put.message
        path:[key,...path]
      }

    value[key] = put.value

    {continue:true,error:false,value:value}

  | \array =>

    [arr,shape,G] = fun

    I = 0

    In = arr.length

    while I < In

      key = arr[I]

      put = apply shape,G,value[key],key,extra1

      if put.path
        path = put.path
      else
        path = []

      if put.error
        return {
          continue:false
          error:true
          value:value
          message:put.message
          path:[key,...path]
        }

      value[key] = put.value

      I += 1

    {continue:true,error:false,value:value}

  | \object =>

    I  = 0

    In = fun.length

    while I < In

      [key,shape,G] = fun[I]

      apply shape,G,value[key],key,extra1

      if put.path
        path = put.path
      else
        path = []

      if put.error
        return {
          continue:false
          error:true
          value:value
          message:put.message
          path:[key,...path]
        }

      value[key] = put.value

      I += 1

    {continue:true,error:false,value:value}


settle = (fun,put,dtype,extra1,extra2) ->

  [type,F] = fun

  {value}  = put

  switch type

  | \d         => F value
  | \i         => F.auth value,extra1,extra2
  | \f         => sanatize value,(F value,extra1,extra2)

  # ------------------------------------------------------

  | \map       => map dtype,F,value,extra1,extra2
  | \on        => upon F,value,extra1,extra2
  | \cont      =>

    put.value   = switch typeof F
    | \function => F value,extra1,extra2
    | otherwise => F

    put

  | \jam       =>

    put.message  = switch typeof F
    | \function  => F value,extra1,extra2
    | otherwise  => F

    put.continue = false

    put.error    = true

    return put

  | \alt          =>

    for [type,G] in fun

      put = apply type,G,value,extra1,extra2

      if put.continue
        return put

    return put

  | otherwise => put


reg.tightloop = (x,extra1,extra2) !->

  state      = @[sig]

  {all,type} = state

  I          = 0

  put        = {continue:true,error:false,value:x}

  nI         = all.length

  do

    each = all[I]

    switch I%2
    | 0 => # and

      J  = 0

      nJ = each.length

      do

        fun = each[J]

        if put.error
          put = blunder fun,put,extra1,extra2
        else
          put = settle fun,put,type,extra1,extra2

        J += 1

      while J < nJ

      if put.error
        I += 1
      else
        I += 2

    | 1 => # or

      J    = 0

      nJ   = each.length

      do

        fun = each[J]

        [patt] = fun

        nput = settle fun,put,type,extra1,extra2

        if nput.continue and (patt is \alt)
          put = nput
          J = nJ

        else if nput.continue
          put = nput
          I = nI
          J = nJ

        else if nput.error

          J += 1

      while J < nJ


      I += 1


  while I < nI

  return put