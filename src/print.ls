reg = require "./registry"

{com,print} = reg

{l,z,cc,R,j,pretty-error} = com

{print} = reg

pkgname = reg.pkgname

c = {}
  ..ok    = cc.greenBright
  ..ok2   = cc.xterm 8
  ..warn  = cc.xterm 209
  ..er    = cc.xterm 196
  ..er2   = cc.magentaBright
  ..er3   = cc.redBright
  ..black = cc.xterm 244

help =
  c.black "[  docs] #{reg.homepage}"

# -------------------------------------------------------------------------------------------------------

pe = (new prettyError!)

pe.skipNodeFiles!

pe.filterParsedError (Error) ->

  Error._trace = R.takeLast 5,Error._trace

  Error

pe.skip (traceLine,lineNumber) ->

  if traceLine.dir is "internal/modules/cjs" then return true

  return false


pe.appendStyle do
  "pretty-error > header > title > kind":(display: "none")
  "pretty-error > header > colon":(display: "none")
  "pretty-error > header > message":(display:"none")

# -  - - - - - - - - - - - - - - - - - - - - - - - - --  - - - - - - - - - - - - - - - - - - - - - - - - -

show_stack = !->

  l help

  E = pe.render new Error!

  l E

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

print.required_input = ->

  lit ["[#{pkgname}]","[typeError]"],[c.er,c.e3]

  lit ['\n',"  .required only accepts string and number.",'\n'],[0,c.e2,0]

  show_stack!

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
    [0,c.ok,c.er2,c.er3,c.er]


show_name = (name,type = "[inputError] ") ->

  lit do
    ["[#{pkgname}]",type,name]
    [c.er,c.er2,c.er]

print.input_fault.andor = ([type,info])->


  show_name ".#{info[1]}"

  l ""

  show_chain info

  l ""


  switch type
  | \arg_count =>

    l c.ok2 do
      "  no value passed."
      "\n\n"
      " minimum of 1 argument of function type is needed."


  | \not_function =>

    l c.er "  one of the argument is not a function."

  l ""

  l c.ok2 " - | type signature / information | - "

  l ""

  l c.ok " - :: fun|[fun,..],..,.."

  l ""


print.input_fault.custom = ([patt,loc])->

  show_name "custom validator"

  l ""

  switch patt
  | \arg_count =>

    l c.ok2 do
      "  no value passed."
      "\n\n"
      " minimum of 1 argument of function type is needed."


  | \not_function =>

    l c.er "  first argument has to be a function."

  l ""



print.input_fault.map = ([patt,loc]) ->

  show_name ".map"

  l ""

  show_chain loc

  l ""

  switch patt
  | \arg_count    =>

    l c.ok2 "  only accepts 1 argument required of function type."

  | \not_function =>

    l c.ok2 "  first argument has to be a function."


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

      l c.er "  unable to pattern match on user input."

    | \arg_count =>

      l c.er "  minimum of 2 arguments required."

    l ""

    lit [" - | types that may match ",".on"," | -"],[c.ok2,c.ok,c.white]

    l ""


    lines = [(" - :: " + c.ok val) for key,val of on_dtype].join "\n\n"

    l lines


  | otherwise  =>

    dtype = on_dtype[patt]

    lit do
      [" .on"," :: ",dtype," <-- what may match"]
      [c.warn,c.white,c.ok,c.black]

  l ""


print.route = (data) ->

  [ECLASS,info] = data

  switch ECLASS
  | \required_input => print.required_input!
  | \input.fault    => print.input_fault info

  show_stack!

print.log = ->

  all = Object.entries @

  prop = [name for [name] in all]

  str = (c.ok "[ #{pkgname} ]") + c.warn "[ "

  for I in prop

    str += c.warn (I + " ")

  str += c.warn "]"

  str



module.exports = print