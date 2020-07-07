{z,noops} = require "./common"

print = require "./print"

p = print.fail "test.js"

IS = require "./main"

z IS.integer(1)