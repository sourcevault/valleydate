reg = require "./registry"

{com,print,sig} = reg

{l,z,R,j,hop,flat,pad,alpha-sort,esp} = com

pkgname = reg.pkgname

c = {}
  ..ok1   = (txt) -> "\x1B[38;5;2m#{txt}\x1B[39m"
  ..warn  = (txt) -> "\x1B[38;5;11m#{txt}\x1B[39m"
  ..er1   = (txt) -> "\x1B[38;5;3m#{txt}\x1B[39m"
  ..er2   = (txt) -> "\x1B[38;5;13m#{txt}\x1B[39m"
  ..er3   = (txt) -> "\x1B[91m#{txt}\x1B[39m"
  ..grey  = (txt) -> "\x1B[38;5;8m#{txt}\x1B[39m"

help =
  c.grey "[  docs] #{reg.homepage}"

# -------------------------------------------------------------------------------------------------------

show_stack = ->

  l help + "\n"

  E = esp.parse new Error!

  E = R.drop 7,E

  for I in E

    {lineNumber,fileName,functionName,columnNumber} = I

    path = fileName.split "/"

    [first,second] = path

    if ((first is \internal) and (second is \modules)) then continue

    if (functionName is \Object.<anonymous>)

      functionName = ""

    lit do
      [
        "  - "
        R.last path
        ":"
        lineNumber
        " "
        functionName
        "\n    "
        fileName + ":"
        lineNumber
        ":" + columnNumber + "\n"
      ]
      [0,c.warn,0,c.er1,0,0,0,c.black,c.er1,c.black]

# -  - - - - - - - - - - - - - - - - - - - - - - - - --  - - - - - - - - - - - - - - - - - - - - - - - - -

print.fail = (filename) -> (message) !->

  l do
    "[TEST ERROR] originating from module"
    "[#{pkgname}]"
    "\n\n- 'npm test' failed at #{filename}:"

  if message

    l "\n    #{message}\n"

  process.exitCode = 1

lit = R.pipe do
  R.zipWith (x,f) ->
    switch R.type f
    | \Function => f x
    | otherwise => x
  R.join ""
  l

print.resreq = ([cat,type]) ->

  methodname = switch cat
  | \resreq  => ".resreq"
  | \res     => ".restricted"
  | \req     => ".required"

  lit ["[#{pkgname}]","[argumentError] ",methodname],[c.er2,c.er3,c.er1]

  txt = switch cat
  | \resreq =>

    switch type
    | \prime => "  .resreq only accepts 2 argument of type Array of String / Number."
    | \res   => "  first argmuent is not a Array of String / Number."
    | \req   => "  second argmuent is not a Array of String / Number."

  | \res,\req    => "  one of the (inner) argument is not of type of String / Number."


  lit ['\n',txt,'\n'],[0,c.warn,0]


print.input_fault = ([method_name,data]) ->

  fi = @input_fault

  switch method_name
  | \on       => fi.on data
  | \map      => fi.map data
  | \custom   => fi.custom data
  | \and,\or  => fi.andor data

show_chain = ([init,last]) ->

  lit do
    ["  ",((init).join "."),("."  + last),"(xx)"," <-- error here"]
    [0,c.ok1,c.er2,c.er3,c.er2]

show_name = (name,type = "[inputError] ") ->

  lit do
    ["[#{pkgname}]",type,name]
    [c.er1,c.er3,c.warn]

print.input_fault.andor = ([type,info])->

  show_name ".#{info[1]}"

  l ""

  show_chain info

  l ""

  switch type
  | \arg_count =>

    l c.grey do
      "  no value passed."
      "\n\n"
      " minimum of 1 argument of function type is needed."


  | \not_function =>

    l c.er1 "  one of the argument is not a function."

  l ""

  l c.grey " - | type signature / information | - "

  l ""

  l c.ok1 " - :: fun|[fun,..],..,.."

  l ""


print.input_fault.custom = ([patt,loc]) ->

  show_name "custom validator"

  l ""

  switch patt
  | \arg_count =>

    l c.grey do
      "  no value passed."
      "\n\n"
      " minimum of 1 argument of function type is needed."

  | \not_function =>

    l c.er1 "  first argument has to be a function / valleydate object ."

  l ""



print.input_fault.map = ([patt,loc]) ->

  show_name ".map"

  l ""

  show_chain loc

  l ""

  switch patt
  | \arg_count    =>

    l c.grey "  only accepts 1 argument required of function type."

  | \not_function =>

    l c.grey "  first argument has to be a function."


  l ""

on_dtype = {}
  ..string = "string|number , function"
  ..object = "object{*:function} "
  ..array  = "[string|number....] , function"


print.input_fault.on = ([patt,loc])->

  eType = switch patt
  | \typeError => \typeError
  | otherwise  => \inputError


  show_name ".on","[#{eType}] "

  l ""

  show_chain loc

  l ""

  switch patt
  | \typeError,\arg_count =>

    switch patt
    | \typeError =>

      l c.er1 "  unable to pattern match on user input."

    | \arg_count =>

      l c.er1 "  minimum of 2 arguments required."

    l ""

    lit [" - | types that may match ",".on"," | -"],[c.grey,c.ok1,c.white]

    l ""


    lines = [(" - :: " + c.ok1 val) for key,val of on_dtype].join "\n\n"

    l lines


  | otherwise  =>

    dtype = on_dtype[patt]

    lit do
      [" .on"," :: ",dtype," <-- what may match"]
      [c.warn,c.white,c.ok1,c.grey]

  l ""


print.route = (data) ->

  [ECLASS,info] = data

  switch ECLASS
  | \resreq       => print.resreq info
  | \input.fault  => print.input_fault info

  show_stack!

print.log = ->

  all = Object.entries @

  prop = [name for [name] in all]

  str = c.ok1 "{.*}"

  str += c.ok1 " "

  for I in prop

    str += c.grey (I + " ")

  str


sort = (x) -> x.sort(alpha-sort.ascending)

# R.sort (a,b) -> b.length - a.length

includes = R.flip R.includes

same = includes ['and', 'or', 'cont', 'jam', 'fix', 'err','map','on','alt','auth']

myflat = hop
.wh do
  (ob) ->
    switch (R.type ob)
    | \Function,\Object => true
    | otherwise         => false

  (ob,fin = {}) ->

    keys = Object.keys ob

    for I in keys

      if not (same I)

        prop = myflat ob[I]

        fin[I] = prop

    fin

.def -> {}

print.proto = ->

  if @[sig] is undefined then return null

  props = [name for name of @]

  str = c.ok1 "{.*} "

  str += props
  |> sort
  |> R.join " "
  |> c.grey

  str


split = R.groupBy (name) -> (/\./).test name

find_len = R.reduce (accum,x) ->

  if x.length > accum

    x.length

  else accum

print.inner = ->

  props =  sort [ I for I of flat myflat @]

  ob = split props

  len = (find_len 0,props) + 4

  if (ob.true is undefined) and (ob.false is undefined)
    init-table = []
  else if ob.true
    init-table = [...ob.true,...ob.false]
  else
    init-table = ob.false

  table = [pad.padRight I, len for I in init-table]

  table = [I.join " " for I in (R.splitEvery 2,table)].join "\n"

  str = c.ok1 "{.*}\n"

  str += table
  |> c.grey

  str

module.exports = print