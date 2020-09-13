z                = console.log

l                = console.log

R                = require "ramda"

chalk            = require "chalk"

hoplon           = require "hoplon"

pretty-error     = require "pretty-error"

jspc             = require "@aitodotai/json-stringify-pretty-compact"

if (typeof window is "undefined") and (typeof module is "object")

  util = require "util"

  util_inspect_custom = util.inspect.custom

else

  util_inspect_custom = Symbol.for "nodejs.util.inspect.custom"

j = (x) -> l jspc do
  x
  {
    maxLength:30
    margins:true
  }


module.exports =
  *z:z
   j:j
   l:l
   R:R
   chalk:chalk
   hop:hoplon
   uic:util_inspect_custom
   pretty-error:pretty-error
