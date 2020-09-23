reg = require "./registry"

require "./print" # [....]

require "./tightloop" # [....]

# ------------------------------------------------------------------

{com,print,pkgname,tightloop,already_created} = reg

{z,l,R,hop,j,uic,deep-freeze} = com

# ------------------------------------------------------------------

init = {}

init.state =
  all      :[]
  type     :null
  str      :[]

# ------------------------------------------------------------------

init.props =
  [\obj \Object]
  [\arr \Array]
  [\undef \Undefined]
  [\null \Null]
  [\num \Number]
  [\str \String]
  [\fun \Function]
  [\bool \Boolean]

# ------------------------------------------------------------------

loopError = ->

  noop  = ->
  apply = -> new Proxy(noop,{apply:apply,get:get})
  get   = -> new Proxy(noop,{apply:apply,get:get})

  new Proxy(noop,{apply:apply,get:get})

reg.loopError = loopError

# ------------------------------------------------------------------

define = {}

# ------------------------------------------------------------------

cato = (arg) ->

  switch R.type arg

  | \Function =>

    switch already_created.has arg
    | false => [\f,arg]
    | true  => [\s,arg]

  | \Arguments =>

    fun = []

    for I from 0 til arg.length

      F = arg[I]

      block = switch already_created.has F

      | false => [\f,F]
      | true  => [\s,F]

      fun.push block

    fun

# ------------------------------------------------------------------

define.base = (type) -> (UFO) ->

  if ((R.type UFO) is type)

    {continue:true,error:false,value:UFO}

  else

    str = R.toLower "not #{type}"

    {error:true,continue:false,message:str,value:UFO}

# ------------------------------------------------------------------

define.not_base = (type) -> (UFO) ->

  if ((R.type UFO) is type)

    str = R.toLower "is #{type}"

    {error:true,continue:false,message:str,value:UFO}

  else

    {continue:true,error:false,value:UFO}

# ------------------------------------------------------------------

define.maybe_base = (type) -> (UFO) ->

  if (R.type UFO) in [\Undefined,type]

    return {continue:true,error:false,value:UFO}

  else

    str = R.toLower "not #{type}"

    {error:true,continue:false,message:str,value:UFO}


# ------------------------------------------------------------------

custom = hop
.arn 1, -> print.route [\input.fault [\custom [\arg_count]]] ; loopError!

.whn do

  (f) -> ((R.type f) is \Function)

  -> print.route [\input.fault [\custom [\not_function]]] ; loopError!

.def (F) ->

  G = cato F

  data = {
    ...init.state
    ...{
      type  : \custom
      all   : [[G]]
      str   : ["{..}"]
    }
  }

  define.forward data


custom[uic] = print.inner

main_wrap = (type,state) -> -> main type,state,arguments

define.forward = (data,fun)->

  if fun

    forward       = fun

  else

    forward       = tightloop data

  forward[uic]    = print.log

  forward.and     = main_wrap \and,data

  forward.or      = main_wrap \or,data

  forward.cont    = main_wrap \cont,data

  forward.jam     = main_wrap \jam,data

  forward.fix     = main_wrap \fix,data

  forward.err     = main_wrap \err,data

  if data.type in [\obj,\arr]

    forward.map   = main_wrap \map,data

    forward.on    = main_wrap \on,data

  already_created.add forward

  forward

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

# ------------------------------------------------------------------


verify = {}

verify.on = hop.unary

.arn [1,2],(args,state) -> [\input.fault [\on [\arg_count,[state.str,\on]]]]

.arma do
  1
  ([maybe-object],state) ->

    if ((R.type maybe-object) is \Object)

      for I,val of maybe-object

        if not ((R.type val) is \Function)

          return [\input.fault [\on [\object,[state.str,\on]]]]

      return [\object]

    else

      false

.arma do
  2
  ([maybe-array,maybe-function],state)->

    if ((R.type maybe-array) is \Array)

      for I in maybe-array

        if not ((R.type I) is \String)

          return [\input.fault [\on [\array ,[state.str,\on]]]]

      if not ((R.type maybe-function) is \Function)

          return [\input.fault [\on [\array,[state.str,\on]]]]

      return [\array]

    else

      return false

  ([maybe-string,maybe-function],state) ->

    if not ((R.type maybe-string) is \String)

      return false

    if not ((R.type maybe-function) is \Function)

      return [\input.fault [\on [\string,[state.str,\on]]]]

    return [\string]

.def (args,state)-> [\input.fault [\on [\typeError,[state.str,\on]]]]


verify.rest = (type,state,funs) ->

  switch type
  | \and \or  =>

    if (funs.length is 0)

      print.route [\input.fault,[type,[\arg_count,[state.str,type]]]]

      return false

    for F in funs

      if not ((R.type F) is \Function)

        print.route [\input.fault,[type,[\not_function,[state.str,type]]]]

        false

    true

  | \map      =>

    if not (funs.length is 1)

      print.route [\input.fault,[type,[\arg_count,[state.str,type]]]]

      return false

    [f] = funs

    if not ((R.type f) is \Function)

      print.route [\input.fault,[type,[\not_function,[state.str,type]]]]

      return false

    return true

  | \err,\fix,\cont,\jam  =>

    return true

  | otherwise => return false


define.on = (type,state,args) ->

  switch type
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

  block = define.and state,[put]

  data = {
    ...state
    ...{
      phase :\chain
      all   :block
      str   :state.str.concat \on
    }
  }

  define.forward data

# -----------------------------------------------------------------------

main = hop

.wh do
  (type) -> type is \on

  (type,state,args) ->

    patt = verify.on args,state

    [type] = patt

    switch type
    | \input.fault =>

      print.route patt

      return loopError!

    define.on type,state,args

.wh do
  verify.rest
  (type,state,args) ->

    # ----------------------------------

    funs = cato args

    block = switch type
    | \and                  => define.and state,funs
    | \or                   => define.or  state,funs
    | \map                  => define.and state,[[\map,funs[0]]]
    | \err,\fix,\cont,\jam  => define.and state,[[type,args[0]]]

    data = {
      ...state
      ...{
        all   :block
        str   :state.str.concat type
      }
    }

    define.forward data


.def loopError

# ------------------------------------------------------------------

dressing = (name,F) ->

  already_created.add F

  data = {
    ...init.state
    ...{
      type :name
      str  :[name]
      all  :[[[\s,F]]]
    }
  }

  define.forward data,F

  void

reg.internal = {custom,dressing,define}

pkg = require "./init" # [....]

deep-freeze pkg

module.exports = pkg