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
      return (continue:false,error:true,value:x,message:"",path:[])

  | \Array =>

    [cont,unknown] = UFO

    if cont

      return (continue:true,error:false,value:x)

    else


      switch (typeof unknown)
      | \string =>
        msg = unknown
      | otherwise =>
        msg = "[#{pkgname}][error][user-supplied-validator] message has to be string."


      return {
        continue:false
        error:true
        value:x
        message:msg
        path:[]
      }


settle = (fun,x,type) ->

  [patt,F] = fun

  switch patt
  | \s   => F x
  | \f   => sanatize F,x
  | \map =>

    switch type
    | \arr =>

      [patt,G] = F

      I = 0

      In = x.length

      put = null

      arr = []

      while I < In

        put = switch patt
        | \s => G x[I]
        | \f => sanatize G,x[I]

        if put.path
          path = put.path
        else
          path = []

        if put.error
          return {
            continue:false
            error:true
            value:x
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

      for key,val of x

        put = switch patt
        | \s => G x[key]
        | \f => sanatize G,x[key]

        if put.path
          path = put.path
        else
          path = []

        if put.error
          return {
            continue:false
            error:true
            value:x
            message:put.message
            path:[key,...path]
          }

        ob[key] = put.value

      {continue:true,error:false,value:ob}

  | \on =>

    [patt1,data] = F

    switch patt1
    | \string =>

      [key,shape,G] = data

      put = switch shape
      | \s => G x[key]
      | \f => sanatize G,x[key]

      if put.path
        path = put.path
      else
        path = []

      if put.error
        return {
            continue:false
            error:true
            value:x
            message:put.message
            path:[key,...path]
        }

      x[key] = put.value

      {continue:true,error:false,value:x}

    | \array =>

      [arr,shape,G] = data

      I = 0

      In = arr.length

      while I < In

        key = arr[I]

        put = switch shape
        | \s => G x[key]
        | \f => sanatize G,x[key]

        if put.path
          path = put.path
        else
          path = []

        if put.error
          return {
            continue:false
            error:true
            value:x
            message:put.message
            path:[key,...path]
          }

        if not (put.value is undefined)
          x[key] = put.value

        I += 1

      {continue:true,error:false,value:x}

    | \object =>

      I  = 0

      In = data.length

      while I < In

        [key,shape,G] = data[I]

        put = switch shape
        | \s => G x[key]
        | \f => sanatize G,x[key]

        if put.path
          path = put.path
        else
          path = []

        if put.error
          return {
            continue:false
            error:true
            value:x
            message:put.message
            path:[key,...path]
          }

        x[key] = put.value

        I += 1

      {continue:true,error:false,value:x}


reg.tightloop = (state) -> (x) !->

  {all,type} = state

  I   = 0
  put = null
  nI  = all.length

  do

    each = all[I]

    switch I%2
    | 0 =>

      J = 0

      do

        put = settle each[J],x,type

        if put.error
          break

        J += 1

      while J < each.length

      if put.continue
        I += 2
      else
        I += 1

    | 1 =>

      J = 0

      do

        put = settle each[J],x,type

        if put.continue
          break

        J += 1
      while J < each.length

      if put.continue
        I += 1
      else
        return put

  while I < nI


  if (put.continue and state.cont)

    [patt,cont] = state.cont

    switch patt
    | \jam  =>

      plant = switch typeof cont
      | \function => cont put
      | otherwise => cont

      return {continue:false,error:true,value:put.value,message:plant}

    | \cont =>

      plant = switch typeof cont
      | \function => cont put.value
      | otherwise => cont

      return {continue:true,error:false,value:plant}

  else if (put.error and state.err)

    [patt,F] = state.err

    switch patt
    | \fix =>

      pin = switch typeof F
      | \function => F put.value,put.path
      | otherwise => F

      return {continue:true,error:false,value:pin}

    | \err =>

      put.message = switch typeof F
      | \function => F put.message,put.path
      | otherwise => F

      return put

  else return put









