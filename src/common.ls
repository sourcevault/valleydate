vendor           = require "./vendor"

z                = console.log

l                = console.log

flat             = vendor.flat

advanced-pad     = vendor.pad

R                = require "ramda"

hoplon           = require "hoplon"

jspc             = vendor.stringify

deep-freeze      = vendor.deepFreeze

alpha-sort       = vendor.alpha_sort

esp              = require "error-stack-parser"

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
