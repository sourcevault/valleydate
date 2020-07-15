z            = console.log

l            = console.log

R            = require "ramda"

chalk        = require "chalk"

show-ob      = require "json-stringify-pretty-compact"

SI           = require "seamless-immutable"

sim          = require "seamless-immutable-mergers"

pretty-error = require "pretty-error"

binapi       = require "binapi"

hoplon       = require "hoplon"

module.exports =
  *z:z
   l:l
   noop:->
   chalk:chalk
   binapi:binapi
   hop:hoplon
   SI:SI
   j:(j)-> console.log show-ob j
   R:R
   sim:sim
   pretty-error:pretty-error

