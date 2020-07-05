{z,noops} = require "./common"

print = require "./print"

p = print.fail "test.js"

# ----------

IS = require "./main"


city = IS.array.or do
	IS.undef.cont \delhi
	IS.string.cont (x) -> [x]

V = IS.object
.on \country, IS.undef.cont \india
.on \city, city


z V {}
