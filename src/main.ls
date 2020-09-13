reg = require "./registry"

require "./print" # [....]

require "./tightloop" # [....]

# ------------------------------------------------------------------

{com,print,pkgname,tightloop,already_created} = reg

{z,l,R,hop,j,uic} = com

init-state =
  all     :[]
  type    :null
  cont    :null
  err     :null
  phase   :\init
  str     :[]

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

define.base = (name) -> (UFO) ->

  ut = R.type UFO

  if (ut is name)

    {continue:true,error:false,value:UFO}

  else

    str = R.toLower "not #{name}"

    {error:true,continue:false,message:str,value:UFO}


define.notbase = (name) -> (UFO) ->

  ut = R.type UFO

  if (ut is name)

    str =  R.toLower "is #{name}"

    {error:true,continue:false,message:str,value:UFO}

  else

    {continue:true,error:false,value:UFO}


custom = hop
.arn 1, -> print.route [[\fault \custom \arg_count]] ; loopError!

.whn do

  (f) -> ((R.type f) is \Function)

  -> print.route [[\fault \custom \not_function]] ; loopError!

.def (F) ->

  neo = Object.assign do
    {}
    init-state
    {
      type     :\custom
      all      :[[(cato F)]]
      phase    :\chain
      str      :[pkgname]
    }

  define.forward \custom,neo


main_wrap = (type,state) -> -> main type,state,arguments

define.forward = (type,neo,fun)->

  if fun

    forward       = fun

  else

    forward       = tightloop neo

  forward[uic]    = print.log

  forward.and     = main_wrap \and,neo

  forward.or      = main_wrap \or,neo

  forward.cont    = main_wrap \cont,neo

  forward.jam     = main_wrap \jam,neo

  forward.fix     = main_wrap \fix,neo

  forward.err     = main_wrap \err,neo

  if type in [\obj,\arr]

    forward.map   = main_wrap \map,neo

    forward.on    = main_wrap \on,neo

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


verify_on = hop
.arn [1,2],[\fault \on \arg_count]
.arma do
  1
  (maybe-object) ->

    if ((R.type maybe-object) is \Object)

      for I,val of maybe-object

        if not ((R.type val) is \Function)

          return [\fault \on \object \not_function]

      return [\object]

    else

      false

.arma do
  2
  (maybe-array,maybe-function)->

    if ((R.type maybe-array) is \Array)

      for I in maybe-array

        if not ((R.type I) is \String)

          return [\fault \on \array]

      if not ((R.type maybe-function) is \Function)

          return [\fault \on \array]

      return [\array]

    else

      return false

  (maybe-string,maybe-function) ->

    if not ((R.type maybe-string) is \String)

      return false

    if not ((R.type maybe-function) is \Function)

      return [\fault \on \string]

    return [\string]

.def [\fault \on \typeError]

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


  neo = Object.assign do
    {}
    state
    {
      phase :\chain
      all   :block
      str   :state.str.concat \on
    }


  define.forward state.type,neo


main = hop
.wh do

  (type,state,args) -> (type in [\cont,\jam]) and (state.phase is \chain)

  (type,state,[f]) ->

    neo = Object.assign do
      {}
      state
      {
        phase:\end
        cont:[type,f]
        str:state.str.concat type
      }

    forward      = tightloop neo

    forward.fix  = main_wrap \fix,neo

    forward.err  = main_wrap \err,neo

    forward[uic] = print.log

    already_created.add forward

    forward

.wh do

  (type,state,args) -> (type in [\err,\fix]) and (state.phase is \chain)

  (type,state,[f]) ->

    neo = Object.assign do
      {}
      state
      {
        phase:\end
        str:state.str.concat type
      }

    neo.err       = [type,f]

    forward       = tightloop neo

    forward.cont  = main_wrap \cont,neo

    forward.jam  = main_wrap \jam,neo

    forward[uic]    = print.log

    already_created.add forward

    forward


.wh do

  (type,state,args) -> state.phase is \end

  (type,state,[f]) ->

    neo = Object.assign state,{}

    switch type

    | \err,\fix =>

      neo.err = [type,f]

    | \cont,\jam =>

      neo.cont = [type,f]

    F = tightloop neo

    already_created.add F

    F

.wh do
  (type) -> type is \on

  (type,state,args) ->

    patt = verify_on ...args

    [type] = patt

    switch type
    | \fault =>

      print.route [patt,[state.str,\on]]

      return loopError!

    define.on type,state,args

.wh do

  (type,state,funs) ->

    switch type
    | \and \or  =>

      for F in funs

        if not ((R.type F) is \Function)

          print.route [[\fault , type , \not_function],[state.str,type]]

          false

      true

    | \map      =>

      if not (funs.length is 1)

        print.route [[\fault,type,\arg_count],[state.str,type]]

        return false

      [f] = funs

      if not ((R.type f) is \Function)

        print.route [[\fault,type,\not_function],[state.str,type]]

        return false

      return true

    | otherwise => return false


  (type,state,args) ->

    # ----------------------------------

    funs = cato args

    block = switch type
    | \and => define.and state,funs
    | \or  => define.or state,funs
    | \map => define.and state,[[\map,funs[0]]]


    neo = Object.assign do
      {}
      state
      {
        phase :\chain
        all   :block
        str   :state.str.concat type
      }

    define.forward state.type,neo


.def loopError

# ------------------------------------------------------------------

props =
  [\obj \Object]
  [\arr \Array]
  [\undef \Undefined]
  [\null \Null]
  [\num \Number]
  [\str \String]
  [\fun \Function]

boot = ->

  for [name,type] in props

    F = define.base type

    already_created.add F

    neo = Object.assign do
        {}
        init-state
        {
          type:name
          all:[[[\s,F]]]
          phase:\chain
          str:[name]
        }

    define.forward name,neo,F

    custom[name] = F


  # -------------------------------

  custom.not = {}

  # -------------------------------

  for [name,type] in props

    F = define.notbase type

    already_created.add F

    neo = Object.assign do
        {}
        init-state
        {
          type:name
          all:[[[\s,F]]]
          phase:\chain
          str:[name]
        }

    define.forward name,neo,F

    custom.not[name] = F


  custom

reg.pkg = boot!

require "./helper" # [....]

module.exports = reg.pkg