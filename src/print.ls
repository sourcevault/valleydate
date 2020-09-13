reg = require "./registry"

{com,print} = reg

{l,z,chalk,R,j,pretty-error} = com

{print} = reg

pkgname = reg.pkgname

c = {}
  ..ok    = chalk.green.bold
  ..er    = chalk.hex "FF0000"
  ..warn  = chalk.hex "FFFFCD"
  ..err   = chalk.red
  ..black = chalk.rgb(128, 128, 128).bold

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


print.route = (data) ->

  l data

print.log = ->

  all = Object.entries @

  prop = [name for [name] in all]

  str = (c.ok "[ #{pkgname} ]") + c.warn "[ "

  for I in prop

    str += c.warn (I + " ")

  str += c.warn "]"

  str



module.exports = print