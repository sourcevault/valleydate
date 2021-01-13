reg = require "./registry"

require "./print" # [....]

require "./tightloop" # [....]

# ------------------------------------------------------------------

{com,print,tightloop,sig,cache} = reg

{z,l,R,hop,j,uic,deep_freeze,loopError} = com

# ------------------------------------------------------------------

assort = (F) ->

  if (cache.def.has F)

    [\d,F]

  else if (cache.ins.has F)

    [\i,F]

  else

    [\f,F]


cato = (arg) ->

  switch R.type arg

  | \Function,\Object => assort arg

  | \Arguments =>

    fun = []

    for I from 0 til arg.length

      F = arg[I]

      block = assort F

      fun.push block

    fun

# -------------------------------------------------------

wrap      = {}
  ..on    = null
  ..rest  = null

gaurd     = {}
  ..on    = null
  ..rest  = null

define = {}
  ..and    = null
  ..or     = null
  ..proto  = null
  ..on     = null
  ..basis  = null

validate   = {}
  ..on     = null
  ..rest   = null

#---------------------------------------------------------

props = [\and \or \alt \cont \err \jam \fix]

init-state =
  all  :[]
  type :null
  str  :[]

wrap.rest  = (type) -> -> gaurd.rest arguments,@[sig],type

wrap.on    = -> gaurd.on arguments,@[sig]

proto       = {}
  ..normal  = {}
  ..functor = null

for key,val of props

  proto.normal[val]  = wrap.rest val

proto.normal.auth    = tightloop

proto.functor        = {...proto.normal}

proto.functor.map    = wrap.rest \map

proto.functor.on     = wrap.on

proto.normal[uic]    = print.proto

proto.functor[uic]   = print.proto

#---------------------------------------------------------


handleError = (info) ->

  print.route info

  loopError!

custom = hop

.arn 1, -> handleError [\input.fault [\custom [\arg_count]]]

.whn do

  (f) ->

    ((R.type f) is \Function) or (f[sig])

  -> handleError [\input.fault [\custom [\not_function]]]

.def (F) ->

  G = cato F

  data = {
      type  : \custom
      all   : [[G]]
      str   : ["{..}"]
  }

  define.proto data

custom[uic] = print.inner

#--------------------------------------------------------------------------

define.on = (type,args,state) ->

  switch type[0]
  | \array =>

    [props,F] = args

    put = [\on,[\array,[(R.uniq props),...(cato F)]]]

  | \string =>

    [key,F] = args

    put = [\on,[\string,[key,...(cato F)]]]

    put

  | \object =>

    [ob] = args

    fun   = [[key,...(cato val)] for key,val of ob]

    put = [\on,[\object,fun]]

  | \input.fault => return handleError type

  block = define.and state,[put]

  data = {
    ...state
    ...{
      phase :\chain
      all   :block
      str   :state.str.concat \on
    }
  }

  define.proto data

#-----------------------------------------------------------------------

gaurd.on = hop.unary

.arn do

  [1,2]

  (args,state) -> handleError [\input.fault,[\on [\arg_count,[state.str,\on]]]]

.arma do

  1

  ([maybe-object],state) ->

    if ((R.type maybe-object) is \Object)

      for I,val of maybe-object

        if not (((R.type val) is \Function) or (cache.ins.has val))

          return [\input.fault [\on [\object,[state.str,\on]]]]

      return [\object]

    else

      return false

  define.on

.arma do
  2
  ([first,second],state)->

    switch R.type first

    | \Array =>

      for I in first

        if not ((R.type I) is \String)

          return [\input.fault [\on [\array,[state.str,\on]]]]

      if not (((R.type second) is \Function) or (cache.ins.has second))

        return [\input.fault [\on [\array,[state.str,\on]]]]

      return [\array]

    | \String,\Number =>

      if not (((R.type second) is \Function) or (cache.ins.has second))

        return [\input.fault [\on [\string,[state.str,\on]]]]

      return [\string]

    | otherwise => return false

  define.on

.def (args,state) ->

  handleError [\input.fault [\on [\typeError,[state.str,\on]]]]


#-----------------------------------------------------------------------

validate.rest = (funs,state,type) ->

  switch type

  | \and,\or,\alt  =>

    if (funs.length is 0)

      print.route [\input.fault,[type,[\arg_count,[state.str,type]]]]

      return false

    for F in funs

      if not (((R.type F) is \Function) or (cache.ins.has F))

        print.route [\input.fault,[type,[\not_function,[state.str,type]]]]

        return false

    return true

  | \map      =>

    if not (funs.length is 1)

      print.route [\input.fault,[type,[\arg_count,[state.str,type]]]]

      return false

    return true

    [f] = funs

    if not (((R.type f) is \Function) or (cache.ins.has F))

      print.route [\input.fault,[type,[\not_function,[state.str,type]]]]

      return false

    return true

  | \err,\fix,\cont,\jam  =>

    return true

  | otherwise => return false

#-----------------------------------------------------------------------

gaurd.rest = hop
.wh do
  validate.rest
  (args,state,type) ->

    #----------------------------------

    funs = cato args

    block = switch type
    | \and                  => define.and state,funs
    | \or                   => define.or state,funs
    | \alt                  => define.or state,[[\alt,funs]]
    | \map                  => define.and state,[[\map,funs[0]]]
    | \err,\fix,\cont,\jam  => define.and state,[[type,args[0]]]

    data = {
      ...state
      ...{
        all   :block
        str   :state.str.concat type
      }
    }

    define.proto data

.def loopError

#-----------------------------------------------------------------------

define.copy = (F,data,type = data.type) ->

  switch type
  | \obj,\arr,\arg =>

    Object.assign F,proto.functor

  | otherwise =>

    Object.assign F,proto.normal

  F[sig] = data

  cache.ins.add F



define.proto = (data,type = data.type) ->

  switch type
  | \obj,\arr,\arg =>
    put = Object.create proto.functor
  | otherwise =>
    put = Object.create proto.normal

  put[sig] = data

  cache.ins.add put

  put


define.basis = (name,F) ->

  cache.def.add F

  data = {
    ...init-state
    ...{
      type  :name
      str   :[name]
      all   :[[[\d,F]]]
    }
  }

  define.copy F,data

  void

# ------------------------------------------------------------------

define.and = (state,funs) ->

  all = state.all

  switch (all.length%2)
  | 0 =>

    all.concat [funs]

  | 1 =>

    last = R.last all

    init = R.init all

    nlast = [...last,...funs]

    block = [...init,nlast]

    block


define.or = (state,funs) ->

  all = state.all

  switch (all.length%2)
  | 0 =>

    last = R.last all

    init = R.init all

    nlast = [...last,...funs]

    block = [...init,nlast]

    block

  | 1 =>

    all.concat [funs]

#-----------------------------------------------------------------------

reg.internal = {custom,define}

pkg = require "./init" # [....]

deep_freeze pkg

module.exports = pkg