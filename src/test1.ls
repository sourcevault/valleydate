{l,noops} = require "./common"

print = require "./print"

p = print.fail "test.js"

IS = require "./main"

address = IS.required \city
.on \city,IS.string
.on \country,IS.string.def \France

V = IS.required \address,\name,\age
.on \address,address
.on \name,IS.string
.on \age,IS.number











