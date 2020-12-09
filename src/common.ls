z                = console.log

l                = console.log

R                = require "ramda"

flat             = require "flat"

hoplon           = require "hoplon"

alpha-sort       = require "alpha-sort"

deep-freeze      = require "deep-freeze"

advanced-pad     = require "advanced-pad"

esp              = require "error-stack-parser"

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

loopfault = ->

  loopError  = ->
  apply = -> new Proxy(loopError,{apply:apply,get:get})
  get   = -> new Proxy(loopError,{apply:apply,get:get})

  new Proxy(loopError,{apply:apply,get:get})

module.exports =
  *z:z
   j:j
   l:l
   R:R
   esp:esp
   flat:flat
   hop:hoplon
   pad:advanced-pad
   loopError:loopfault
   alpha-sort:alpha-sort
   deep-freeze:deep-freeze
   uic:util_inspect_custom
