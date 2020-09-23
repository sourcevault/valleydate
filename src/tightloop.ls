reg = require "./registry"

{com,already_created,pkgname} = reg

{z,l,R,j} = com

main = {}

sanatize = (F,x) ->

  UFO = F x

  switch R.type UFO

  | \Boolean,\Null,\Undefined,\Number =>

    if UFO
      return (continue:true,error:false,value:x)
    else
      return (continue:false,error:true,value:x,message:"")

  | \Array =>

    [cont,unknown] = UFO

    if cont

      return (continue:true,error:false,value:x)

    else

      return {
        continue :false
        error    :true
        value    :x
        message  :unknown
      }

  | otherwise =>

    return {
      continue : false
      error    : true
      value    : x
      message  : "[#{pkgname}][typeError][user-supplied-validator] undefined return value."
    }


red = (fun,put,extra) ->

  [patt,F] = fun

  switch patt
  | \err =>

    message = switch typeof F
    | \function => F put.message,put.path,extra
    | otherwise => F

    put.message = message

    put

  | \fix =>

    put.value = switch typeof F
    | \function => F put.value,put.path,extra
    | otherwise => F

    put.continue = true
    put.error    = false

    put

  | otherwise => put




settle = (fun,put,type,extra) ->

  [patt,F] = fun

  {value}  = put

  switch patt
  | \s   => F value
  | \f   => sanatize F,value
  | \map =>

    switch type
    | \arr =>

      [patt,G] = F

      I = 0

      In = value.length

      put = null

      arr = []

      while I < In

        put = switch patt
        | \s => G value[I]
        | \f => sanatize G,value[I]

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

      [patt,G] = F

      for key,val of value

        put = switch patt
        | \s => G value[key]
        | \f => sanatize G,value[key]

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

  | \on  =>

    [patt1,data] = F

    switch patt1
    | \string =>

      [key,shape,G] = data

      put = switch shape
      | \s => G value[key]
      | \f => sanatize G,value[key]

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

      if not (put.value is undefined)

        value[key] = put.value

      {continue:true,error:false,value:value}

    | \array =>

      [arr,shape,G] = data

      I = 0

      In = arr.length

      while I < In

        key = arr[I]

        put = switch shape
        | \s => G value[key]
        | \f => sanatize G,value[key]

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

        if not (put.value is undefined)
          value[key] = put.value

        I += 1

      {continue:true,error:false,value:value}

    | \object =>

      I  = 0

      In = data.length

      while I < In

        [key,shape,G] = data[I]

        put = switch shape
        | \s => G value[key]
        | \f => sanatize G,value[key]

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

        if not (put.value is undefined)

          value[key] = put.value


        I += 1

      {continue:true,error:false,value:value}

  | \cont =>

    put.value   = switch typeof F
    | \function => F value,extra
    | otherwise => F

    put

  | \jam  =>

    put.message   = switch typeof F
    | \function   => F put.value,put.path,extra
    | otherwise   => F

    put.continue  = false

    put.error     = true

    return put

  | otherwise => put


reg.tightloop = (state) -> (x,extra) !->

  {all,type} = state

  I    = 0

  put  = {continue:true,error:false,value:x}

  nI   = all.length

  do

    each = all[I]

    switch I%2
    | 0 => # and

      J  = 0

      nJ = each.length

      do

        fun = each[J]

        if put.error
          put = red fun,put,extra
        else
          put = settle fun,put,type,extra

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

        nput = settle each[J],put,type,extra

        if nput.continue
          put = nput
          break

        J += 1
      while J < nJ

      if put.continue
        I = nI
      else
        I += 1

  while I < nI

  return put