reg = require "./registry"

require "./print"

{com} = reg

{z,l,SI,R,noop} = com

{binapi,hop} = com

data = {}

data.dirty =
  all:[]
  type:null
  continue:null
  error:null
  def:null
  fix:null
  state:\init

data.def = SI data.dirty

V = {}

map = {}

map.basetype = ([prop]) !->

  name = switch prop
  | \obj,\object      => \obj
  | \arr,\array       => \arr

  if name then return [\struct,name]

  name = switch prop
  | \str,\string      => \str
  | \null             => \null
  | \num,\number      => \num
  | \undef            => \undef
  | \fun,\function    => \fun
  | \bool,\boolean    => \bool

  if name then return [\atom,name]

map.ending = ([prop]) !->

  unit = switch prop
  | \fix              => \fix
  | \err,\erro,\error => \erro
  | \cont,\continue   => \cont

  if unit then return [\ending,unit]

map.router = ([prop]) !->

  unit = switch prop
  | \and      => \and
  | \or       => \or
  | \map      => \map
  | \on       => \on

  if unit then return [\router,unit]

map.hepler = ([prop]) !->

  prop = switch prop
  | \req,\required        => \req
  | \int,\integer         => \int
  | \reqf,\required_fuzzy => \reqf

  if prop then return [\helper,prop]


E = {} #entry

E.V = {}

E.F = {} # functions

E.H = {}

E.H.type =  hop
.ma do
  map.basetype
  map.router
  map.hepler
  map.ending
.def [\fault]

veri = {}

veri.on = hop.arwh do
  1,([user]) ->
    switch R.type user
    | \Object => []
    | otherwise =>
  noop
.u

# veri.on = (user) ->


#   z user

#   if not (user.length is 2)
#     return [\fault,\arglen]

#   [str,f] = user


  # ar = []

  # switch R.type str
  # | \String,\Number =>

  #   ar.push '',str

  # | \Array    =>
  #   for I in str
  #     switch R.type I
  #     | \String,\Number =>
  #       ar.push ['a',str]
  #     | otherwise => return  [\fault,\first]
  # | otherwise => return [\fault]

  # switch typeof f
  # | \function =>
  #   ar.push f
  # | otherwise => return [\fault,\second]

  # ['ok',user]

verify_f = (user) ->

  if not (user.length is 1)
    return [\fault,\arglen]

  switch typeof user[0]
  | \function => return ['ok',user]
  | otherwise => return [\fault,\first]

E.F.one = ([fname]) ->

  ret = E.H.type fname

  [type]  = ret

  switch type

  | \router   => [\fault,[\one,\is_router]]
  | \ending   => [\fault,[\one,\is_ending]]
  | \fault    => [\fault,[\one,\is_unknown]]
  | otherwise => [\re,ret]

E.F.two = ([base,unit],user)->

  ret = E.H.type base

  [baseT,bName] = ret

  switch baseT
  | \router,\ending   => return [\fault,[\two.base,baseT]]
  | \fault            => return [\fault,[\two.base,\is_unknown]]

  ret = E.H.type unit

  [unitT,uName] = ret

  switch unitT
  | \fault                 => return [\fault,[\two.unit,\unknown]]
  | \atom,\struct,\hepler  => return [\fault,[\two.unit,unitT]]

  switch uName
  | \map,\on =>
    switch baseT
    | \atom   => return [\fault,[\two.map_on_atom]]


  ret = switch uName
  | \on       => veri.on user
  # | otherwise => verify_f user

  # [cont,data] = ret

  # z return/

  # switch cont
  # | \fault => return [\fault,"two.input.#{arg}"]


  # return [\base.chain,[bName,uName,data]]

E.F.path = ([p,ar]) ->

  switch p.length
  | 1 => E.F.one p
  | 2 => E.F.two p,ar
  | otherwise =>  [\fault,\path_too_long]



E.main = hop.wh do
  ([p,ar,d]) -> d.state is \init
  E.F.path

be = binapi E.main,data.def


be.obj.on do
  \foo,->
  \bar,->

be.obj.on {foo:->,bar:->}

be.obj.on [\foo,\bar],->

