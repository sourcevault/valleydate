z                = console.log

l                = console.log

R                = require "ramda"

flat             = require "flat"

hoplon           = require "hoplon"

dot-prop         = require "dot-prop"

cc               = require "cli-color"

deep-freeze      = require "deep-freeze"

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
   cc:cc
   flat:flat
   hop:hoplon
   dot-prop:dot-prop
   deep-freeze:deep-freeze
   uic:util_inspect_custom
   pretty-error:pretty-error

