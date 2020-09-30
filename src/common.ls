z                = console.log

l                = console.log

R                = require "ramda"

flat             = require "flat"

hoplon           = require "hoplon"

cc               = require "cli-color"

alpha-sort       = require "alpha-sort"

deep-freeze      = require "deep-freeze"

pretty-error     = require "pretty-error"

advanced-pad     = require "advanced-pad"

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
   cc:cc
   flat:flat
   hop:hoplon
   pad:advanced-pad
   loopError:loopfault
   alpha-sort:alpha-sort
   deep-freeze:deep-freeze
   uic:util_inspect_custom
   pretty-error:pretty-error

